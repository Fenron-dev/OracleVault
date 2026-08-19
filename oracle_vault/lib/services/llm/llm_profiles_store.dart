// Datei: lib/services/llm/llm_profiles_store.dart
//
// ZWECK: Persistenz für LLM-Profile und Aufgaben-Zuweisungen.
//        Profile-Metadaten → SharedPreferences (kein Sicherheitsproblem;
//        LlmProfile speichert vom Key nur das Flag has_api_key).
//        API-Keys → ApiKeyStore (Keychain/Keystore, Fallback siehe dort).
// PHASE: 3

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'api_key_store.dart';
import 'llm_profile.dart';

const _uuid = Uuid();

// ── Riverpod-Provider ─────────────────────────────────────────────────────────

final llmProfilesProvider =
    NotifierProvider<LlmProfilesNotifier, LlmProfilesState>(
        LlmProfilesNotifier.new);

// ── State ─────────────────────────────────────────────────────────────────────

class LlmProfilesState {
  final List<LlmProfile> profiles;
  final String? defaultProfileId;
  final LlmTaskAssignment taskAssignment;
  final bool aiEnabled;

  /// Wo die API-Keys liegen (null = noch nicht ermittelt). Die AI-Einstellungen
  /// zeigen es an, damit ein Klartext-Fallback nicht unbemerkt bleibt.
  final ApiKeyBackend? keyBackend;

  const LlmProfilesState({
    this.profiles = const [],
    this.defaultProfileId,
    this.taskAssignment = const LlmTaskAssignment(),
    this.aiEnabled = true,
    this.keyBackend,
  });

  /// Gibt das Profil für eine Aufgabe zurück (oder das Default-Profil).
  LlmProfile? profileForTask(LlmTask task) {
    final id = switch (task) {
      LlmTask.parsing => taskAssignment.parsingProfileId,
      LlmTask.tagging => taskAssignment.taggingProfileId,
      LlmTask.generation => taskAssignment.generationProfileId,
      LlmTask.translation => taskAssignment.translationProfileId,
    };
    return _findById(id) ?? _findById(defaultProfileId);
  }

  LlmProfile? _findById(String? id) {
    if (id == null) return null;
    try {
      return profiles.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  LlmProfilesState copyWith({
    List<LlmProfile>? profiles,
    String? defaultProfileId,
    LlmTaskAssignment? taskAssignment,
    bool? aiEnabled,
    ApiKeyBackend? keyBackend,
  }) =>
      LlmProfilesState(
        profiles: profiles ?? this.profiles,
        defaultProfileId: defaultProfileId ?? this.defaultProfileId,
        taskAssignment: taskAssignment ?? this.taskAssignment,
        aiEnabled: aiEnabled ?? this.aiEnabled,
        keyBackend: keyBackend ?? this.keyBackend,
      );
}

enum LlmTask { parsing, tagging, generation, translation }

// ── Notifier ──────────────────────────────────────────────────────────────────

class LlmProfilesNotifier extends Notifier<LlmProfilesState> {
  static const String _kProfiles = 'llm_profiles';
  static const String _kDefault = 'llm_default_profile';
  static const String _kTask = 'llm_task_assignment';
  static const String _kAiEnabled = 'llm_ai_enabled';

  /// Zugriff auf die Keys — entscheidet selbst zwischen Keychain und
  /// Klartext-Fallback und migriert Altbestände.
  final ApiKeyStore _keys = ApiKeyStore();



  @override
  LlmProfilesState build() {
    _load();
    return const LlmProfilesState();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kProfiles) ?? [];
    final profiles = raw
        .map((s) {
          try {
            return LlmProfile.fromJson(
                jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<LlmProfile>()
        .toList();

    final defaultId = prefs.getString(_kDefault);
    final taskRaw = prefs.getString(_kTask);
    final taskAssignment = taskRaw != null
        ? LlmTaskAssignment.fromJson(
            jsonDecode(taskRaw) as Map<String, dynamic>)
        : const LlmTaskAssignment();
    final aiEnabled = prefs.getBool(_kAiEnabled) ?? true;

    state = LlmProfilesState(
      profiles: profiles,
      defaultProfileId: defaultId,
      taskAssignment: taskAssignment,
      aiEnabled: aiEnabled,
    );

    // Sobald der Keychain verfügbar ist (echtes Code-Signing), wandern beim
    // ersten Start alle Klartext-Keys dorthin und verschwinden aus den
    // Preferences. Vorher passiert hier nichts.
    final backend = await _keys.backend();
    await _keys.migratePlaintextKeys(profiles.map((p) => p.id));
    state = state.copyWith(keyBackend: backend);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kProfiles,
      state.profiles.map((p) => jsonEncode(p.toJson())).toList(),
    );
    if (state.defaultProfileId != null) {
      await prefs.setString(_kDefault, state.defaultProfileId!);
    }
    await prefs.setString(
        _kTask, jsonEncode(state.taskAssignment.toJson()));
    await prefs.setBool(_kAiEnabled, state.aiEnabled);
  }

  // ── Profile CRUD ───────────────────────────────────────────────────────────

  Future<LlmProfile> addProfile(LlmProfile profile) async {
    final updated = state.profiles.toList()..add(profile);
    state = state.copyWith(
      profiles: updated,
      // Erstes Profil wird automatisch Default.
      defaultProfileId:
          state.defaultProfileId ?? profile.id,
    );
    await _persist();
    return profile;
  }

  Future<void> updateProfile(LlmProfile profile) async {
    final updated = state.profiles.map((p) =>
        p.id == profile.id ? profile : p).toList();
    state = state.copyWith(profiles: updated);
    await _persist();
  }

  Future<void> deleteProfile(String id) async {
    final updated =
        state.profiles.where((p) => p.id != id).toList();
    final newDefault =
        state.defaultProfileId == id ? null : state.defaultProfileId;
    state = state.copyWith(profiles: updated, defaultProfileId: newDefault);
    await _keys.delete(id);
    await _persist();
  }

  Future<void> setDefault(String id) async {
    state = state.copyWith(defaultProfileId: id);
    await _persist();
  }

  Future<void> setAiEnabled(bool enabled) async {
    state = state.copyWith(aiEnabled: enabled);
    await _persist();
  }

  // ── API-Key ────────────────────────────────────────────────────────────────

  Future<void> saveApiKey(String profileId, String key) async {
    await _keys.save(profileId, key);
    final profile = state.profiles.firstWhere((p) => p.id == profileId);
    await updateProfile(profile.copyWith(hasApiKey: true));
  }

  Future<String?> loadApiKey(String profileId) => _keys.load(profileId);

  Future<void> deleteApiKey(String profileId) async {
    await _keys.delete(profileId);
    final profile = state.profiles.firstWhere((p) => p.id == profileId);
    await updateProfile(profile.copyWith(hasApiKey: false));
  }

  // ── Vorlagen ───────────────────────────────────────────────────────────────

  Future<LlmProfile> addOllamaTemplate() =>
      addProfile(LlmProfile.ollamaDefault(_uuid.v4()));

  Future<LlmProfile> addLmStudioTemplate() =>
      addProfile(LlmProfile.lmStudioDefault(_uuid.v4()));

  Future<LlmProfile> addOpenRouterTemplate() =>
      addProfile(LlmProfile.openRouterDefault(_uuid.v4()));
}
