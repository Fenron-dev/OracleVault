// Datei: lib/services/llm/llm_profile.dart
//
// ZWECK: Modell für LLM-Provider-Profile.
//        Ein Profil = ein Endpoint + optionaler API-Key + Standardmodell + Parameter.
//        Alle Provider (Ollama, LM Studio, OpenRouter) teilen das OpenAI-kompatible
//        /v1/chat/completions Interface — deshalb reicht ein einziger HTTP-Client.
//
// API-KEYS werden NICHT im Profil selbst gespeichert, sondern im Keychain via
// [LlmProfileStore.saveKey] / [LlmProfileStore.loadKey].
// Das Profil enthält nur einen opaken [keyRef] (z. B. 'profile_<id>_apikey')
// zur Identifikation des Key-Eintrags.
// PHASE: 3

enum ProviderKind { ollama, lmstudio, openrouter, custom }

/// Ein KI-Provider-Profil.
class LlmProfile {
  final String id;
  final String name;
  final String baseUrl;        // z. B. 'http://localhost:11434/v1'
  final ProviderKind kind;
  final String defaultModel;
  final double temperature;
  final int maxTokens;
  final bool hasApiKey;        // true wenn ein Key im Keychain hinterlegt ist

  const LlmProfile({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.kind,
    required this.defaultModel,
    this.temperature = 0.7,
    this.maxTokens = 2048,
    this.hasApiKey = false,
  });

  String get keyRef => 'llm_profile_${id}_apikey';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'base_url': baseUrl,
        'kind': kind.name,
        'default_model': defaultModel,
        'temperature': temperature,
        'max_tokens': maxTokens,
        'has_api_key': hasApiKey,
      };

  factory LlmProfile.fromJson(Map<String, dynamic> j) => LlmProfile(
        id: j['id'] as String,
        name: j['name'] as String,
        baseUrl: j['base_url'] as String,
        kind: ProviderKind.values.byName(
            (j['kind'] as String?) ?? 'custom'),
        defaultModel: j['default_model'] as String,
        temperature: (j['temperature'] as num?)?.toDouble() ?? 0.7,
        maxTokens: (j['max_tokens'] as int?) ?? 2048,
        hasApiKey: (j['has_api_key'] as bool?) ?? false,
      );

  LlmProfile copyWith({
    String? name,
    String? baseUrl,
    ProviderKind? kind,
    String? defaultModel,
    double? temperature,
    int? maxTokens,
    bool? hasApiKey,
  }) =>
      LlmProfile(
        id: id,
        name: name ?? this.name,
        baseUrl: baseUrl ?? this.baseUrl,
        kind: kind ?? this.kind,
        defaultModel: defaultModel ?? this.defaultModel,
        temperature: temperature ?? this.temperature,
        maxTokens: maxTokens ?? this.maxTokens,
        hasApiKey: hasApiKey ?? this.hasApiKey,
      );

  // ── Vorausgefüllte Vorlagen ──────────────────────────────────────────────

  static LlmProfile ollamaDefault(String id) => LlmProfile(
        id: id,
        name: 'Lokal (Ollama)',
        baseUrl: 'http://localhost:11434/v1',
        kind: ProviderKind.ollama,
        defaultModel: 'llama3.2',
        temperature: 0.7,
      );

  static LlmProfile lmStudioDefault(String id) => LlmProfile(
        id: id,
        name: 'Lokal (LM Studio)',
        baseUrl: 'http://localhost:1234/v1',
        kind: ProviderKind.lmstudio,
        defaultModel: 'local-model',
        temperature: 0.7,
      );

  static LlmProfile openRouterDefault(String id) => LlmProfile(
        id: id,
        name: 'OpenRouter',
        baseUrl: 'https://openrouter.ai/api/v1',
        kind: ProviderKind.openrouter,
        defaultModel: 'meta-llama/llama-3.2-3b-instruct:free',
        temperature: 0.7,
        hasApiKey: true,
      );
}

/// Aufgaben-spezifische Modell-Zuweisung.
/// Jede Aufgabe kann ein eigenes Profil nutzen (oder null = Fallback auf default).
class LlmTaskAssignment {
  final String? parsingProfileId;     // Tabellen-Parsing aus messy Text
  final String? taggingProfileId;     // Tag/Genre-Vorschläge
  final String? generationProfileId;  // Einträge generieren
  final String? translationProfileId; // Übersetzen

  const LlmTaskAssignment({
    this.parsingProfileId,
    this.taggingProfileId,
    this.generationProfileId,
    this.translationProfileId,
  });

  Map<String, dynamic> toJson() => {
        'parsing': parsingProfileId,
        'tagging': taggingProfileId,
        'generation': generationProfileId,
        'translation': translationProfileId,
      };

  factory LlmTaskAssignment.fromJson(Map<String, dynamic> j) =>
      LlmTaskAssignment(
        parsingProfileId: j['parsing'] as String?,
        taggingProfileId: j['tagging'] as String?,
        generationProfileId: j['generation'] as String?,
        translationProfileId: j['translation'] as String?,
      );
}
