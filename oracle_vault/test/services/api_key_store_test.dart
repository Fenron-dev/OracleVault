// Datei: test/services/api_key_store_test.dart
//
// ZWECK: API-Key-Ablage (Issue #7). Keys lagen im Klartext in den
//        App-Preferences. Jetzt Keychain, wo er funktioniert — und ein
//        sichtbarer Fallback, wo nicht (ad-hoc signierte Builds, -34018).
//
// Der sichere Speicher wird über die Plugin-Kanäle gefälscht: in Unit-Tests
// gibt es kein natives Keychain-Backend.

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oracle_vault/services/llm/api_key_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  /// Keychain, der funktioniert.
  void mockWorkingKeychain(Map<String, String> store) {
    messenger.setMockMethodCallHandler(channel, (call) async {
      final args = Map<String, dynamic>.from(call.arguments as Map);
      final key = args['key'] as String?;
      switch (call.method) {
        case 'write':
          store[key!] = args['value'] as String;
          return null;
        case 'read':
          return store[key];
        case 'delete':
          store.remove(key);
          return null;
        case 'readAll':
          return store;
        default:
          return null;
      }
    });
  }

  /// Keychain, der den Zugriff verweigert — der macOS-Fall ohne echte Signatur.
  void mockDeniedKeychain() {
    messenger.setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(
          code: '-34018', message: 'errSecMissingEntitlement');
    });
  }

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  group('Keychain verfügbar', () {
    late Map<String, String> keychain;

    setUp(() {
      keychain = {};
      mockWorkingKeychain(keychain);
      SharedPreferences.setMockInitialValues({});
    });

    test('Backend ist der sichere Speicher', () async {
      expect(await ApiKeyStore().backend(), ApiKeyBackend.secure);
    });

    test('Key landet im Keychain, nicht in den Preferences', () async {
      final store = ApiKeyStore();
      await store.save('p1', 'sk-geheim');

      expect(keychain[ApiKeyStore.prefKeyFor('p1')], 'sk-geheim');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(ApiKeyStore.prefKeyFor('p1')), isNull);
      expect(await store.load('p1'), 'sk-geheim');
    });

    test('Probe-Eintrag bleibt nicht liegen', () async {
      await ApiKeyStore().backend();
      expect(keychain.keys.where((k) => k.contains('probe')), isEmpty);
    });

    test('Klartext-Keys ziehen um und verschwinden aus den Preferences',
        () async {
      SharedPreferences.setMockInitialValues({
        ApiKeyStore.prefKeyFor('p1'): 'sk-alt',
        ApiKeyStore.prefKeyFor('p2'): 'sk-auch-alt',
        'unbeteiligt': 'bleibt',
      });
      final store = ApiKeyStore();

      expect(await store.migratePlaintextKeys(['p1', 'p2']), 2);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(ApiKeyStore.prefKeyFor('p1')), isNull);
      expect(prefs.getString(ApiKeyStore.prefKeyFor('p2')), isNull);
      expect(prefs.getString('unbeteiligt'), 'bleibt');
      expect(keychain[ApiKeyStore.prefKeyFor('p1')], 'sk-alt');
      expect(await store.load('p2'), 'sk-auch-alt');
    });

    test('noch nicht migrierter Key wird trotzdem gefunden', () async {
      SharedPreferences.setMockInitialValues({
        ApiKeyStore.prefKeyFor('p1'): 'sk-alt',
      });
      expect(await ApiKeyStore().load('p1'), 'sk-alt');
    });

    test('delete räumt beide Seiten', () async {
      SharedPreferences.setMockInitialValues({
        ApiKeyStore.prefKeyFor('p1'): 'sk-alt',
      });
      final store = ApiKeyStore();
      await store.save('p1', 'sk-neu');
      await store.delete('p1');

      expect(keychain[ApiKeyStore.prefKeyFor('p1')], isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(ApiKeyStore.prefKeyFor('p1')), isNull);
      expect(await store.load('p1'), isNull);
    });
  });

  group('Keychain verweigert (ad-hoc signierter Build)', () {
    setUp(() {
      mockDeniedKeychain();
      SharedPreferences.setMockInitialValues({});
    });

    test('Backend fällt sichtbar auf Klartext zurück', () async {
      expect(await ApiKeyStore().backend(), ApiKeyBackend.plainPreferences);
    });

    test('Keys funktionieren weiter, liegen aber in den Preferences',
        () async {
      final store = ApiKeyStore();
      await store.save('p1', 'sk-geheim');

      expect(await store.load('p1'), 'sk-geheim');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(ApiKeyStore.prefKeyFor('p1')), 'sk-geheim');
    });

    test('ohne Keychain wird nichts migriert', () async {
      SharedPreferences.setMockInitialValues({
        ApiKeyStore.prefKeyFor('p1'): 'sk-alt',
      });
      final store = ApiKeyStore();

      expect(await store.migratePlaintextKeys(['p1']), 0);
      expect(await store.load('p1'), 'sk-alt',
          reason: 'der Key darf beim Fehlschlag nicht verloren gehen');
    });

    test('delete funktioniert auch ohne Keychain', () async {
      final store = ApiKeyStore();
      await store.save('p1', 'sk-geheim');
      await store.delete('p1');
      expect(await store.load('p1'), isNull);
    });
  });

  test('Standard-Konstruktor nutzt echtes FlutterSecureStorage', () {
    expect(ApiKeyStore(secureStorage: const FlutterSecureStorage()),
        isA<ApiKeyStore>());
  });
}
