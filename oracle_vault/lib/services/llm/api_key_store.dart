// Datei: lib/services/llm/api_key_store.dart
//
// ZWECK: Ablage der LLM-API-Keys. Keychain/Keystore wenn möglich,
//        SharedPreferences nur als Notnagel.
//
// WARUM NICHT EINFACH KEYCHAIN?
// flutter_secure_storage braucht auf macOS eine gültige Signatur. Ad-hoc
// signierte Builds — also genau die, die dieses Projekt lokal und in CI baut —
// scheitern mit -34018 (errSecMissingEntitlement). Ein harter Umstieg würde die
// KI-Funktionen dort komplett lahmlegen. Deshalb prüft [ApiKeyStore] einmal pro
// Sitzung, ob der sichere Speicher tatsächlich funktioniert, und weicht sonst
// aus. Sobald echtes Code-Signing da ist (#8), greift automatisch der Keychain
// und vorhandene Klartext-Keys wandern beim Start dorthin.
//
// WICHTIG: Der Key darf nirgends sonst landen — nicht im Vault, nicht in
// Profilen (LlmProfile speichert nur has_api_key), nicht in Logs. Er geht
// ausschließlich als Authorization-Header raus.
// PHASE: 3

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wo die Keys tatsächlich liegen.
enum ApiKeyBackend {
  /// Keychain (macOS/iOS), Keystore (Android), libsecret (Linux), DPAPI (Windows).
  secure,

  /// Klartext in den App-Preferences — nur, wenn [secure] nicht verfügbar ist.
  plainPreferences,
}

class ApiKeyStore {
  ApiKeyStore({FlutterSecureStorage? secureStorage})
      : _secure = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secure;

  static const _prefix = '_llm_apikey_';
  static const _probeKey = '_llm_keychain_probe';

  ApiKeyBackend? _backend;

  static String prefKeyFor(String profileId) => '$_prefix$profileId';

  /// Ermittelt einmalig, ob der sichere Speicher benutzbar ist.
  ///
  /// Geprüft wird durch tatsächliches Schreiben und Lesen — ob der Keychain
  /// den Zugriff verweigert, zeigt sich erst dabei, nicht an der Plattform.
  Future<ApiKeyBackend> backend() async {
    if (_backend != null) return _backend!;
    try {
      await _secure.write(key: _probeKey, value: 'ok');
      final echo = await _secure.read(key: _probeKey);
      await _secure.delete(key: _probeKey);
      _backend = echo == 'ok'
          ? ApiKeyBackend.secure
          : ApiKeyBackend.plainPreferences;
    } catch (_) {
      // PlatformException (-34018), MissingPluginException (Tests), …
      _backend = ApiKeyBackend.plainPreferences;
    }
    return _backend!;
  }

  Future<void> save(String profileId, String key) async {
    if (await backend() == ApiKeyBackend.secure) {
      await _secure.write(key: prefKeyFor(profileId), value: key);
      // Falls von früher noch ein Klartext-Rest liegt: weg damit.
      await _removeFromPrefs(profileId);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKeyFor(profileId), key);
  }

  Future<String?> load(String profileId) async {
    if (await backend() == ApiKeyBackend.secure) {
      final key = await _secure.read(key: prefKeyFor(profileId));
      if (key != null && key.isNotEmpty) return key;
      // Noch nicht migriert (z. B. erster Start nach dem Umstieg).
      return _loadFromPrefs(profileId);
    }
    return _loadFromPrefs(profileId);
  }

  Future<void> delete(String profileId) async {
    // Immer beide Seiten räumen — ein Rest im Klartext wäre genau das, was
    // dieses Ticket abstellen soll.
    try {
      await _secure.delete(key: prefKeyFor(profileId));
    } catch (_) {
      // Kein sicherer Speicher verfügbar: dort liegt ohnehin nichts.
    }
    await _removeFromPrefs(profileId);
  }

  /// Holt Klartext-Keys aus den Preferences in den sicheren Speicher und
  /// löscht sie dort. Gibt zurück, wie viele umgezogen sind.
  ///
  /// Läuft bei jedem Start: solange der Keychain nicht verfügbar ist, passiert
  /// nichts — sobald er es ist, räumt der erste Start auf.
  Future<int> migratePlaintextKeys(Iterable<String> profileIds) async {
    if (await backend() != ApiKeyBackend.secure) return 0;

    final prefs = await SharedPreferences.getInstance();
    var moved = 0;
    for (final id in profileIds) {
      final plain = prefs.getString(prefKeyFor(id));
      if (plain == null || plain.isEmpty) continue;
      await _secure.write(key: prefKeyFor(id), value: plain);
      // Erst nach erfolgreichem Schreiben löschen, sonst ist der Key weg.
      if (await _secure.read(key: prefKeyFor(id)) == plain) {
        await prefs.remove(prefKeyFor(id));
        moved++;
      }
    }
    return moved;
  }

  Future<String?> _loadFromPrefs(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString(prefKeyFor(profileId));
    return (key == null || key.isEmpty) ? null : key;
  }

  Future<void> _removeFromPrefs(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefKeyFor(profileId));
  }
}
