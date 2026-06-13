// Datei: lib/services/llm/llm_service.dart
//
// ZWECK: OpenAI-kompatibler HTTP-Client.
//        Funktioniert mit Ollama, LM Studio, OpenRouter — alle nutzen /v1/chat/completions.
//
// FEATURES:
//   chatCompletion()     – Einzelner Chat-Request, gibt JSON-String zurück
//   fetchOpenRouterModels() – Lädt Modell-Liste von OpenRouter (/api/v1/models)
//   testConnection()     – Einfacher Ping um zu prüfen ob der Endpoint erreichbar ist
//
// FEHLERBEHANDLUNG:
//   LlmException wird für alle bekannten Fehlertypen geworfen.
//   Unbekannte Fehler als LlmException.unknown weitergeleitet.
// PHASE: 3

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'llm_profile.dart';

// ── Exceptions ────────────────────────────────────────────────────────────────

class LlmException implements Exception {
  final String message;
  final LlmErrorType type;

  const LlmException(this.message,
      {this.type = LlmErrorType.unknown});

  factory LlmException.noProfile() => const LlmException(
        'Kein KI-Profil konfiguriert. Bitte unter Einstellungen → KI einrichten.',
        type: LlmErrorType.noProfile,
      );

  factory LlmException.timeout() => const LlmException(
        'Zeitüberschreitung. Ist das Modell geladen?',
        type: LlmErrorType.timeout,
      );

  factory LlmException.connectionRefused(String url) => LlmException(
        'Verbindung zu $url abgelehnt. Läuft Ollama/LM Studio?',
        type: LlmErrorType.connectionRefused,
      );

  @override
  String toString() => 'LlmException: $message';
}

enum LlmErrorType {
  noProfile,
  timeout,
  connectionRefused,
  authError,
  modelNotFound,
  invalidResponse,
  unknown,
}

// ── OpenRouter Modell-Info ────────────────────────────────────────────────────

class OpenRouterModel {
  final String id;
  final String name;
  final bool isFree;
  final double? pricePerMTokenIn;  // USD pro Million Input-Tokens
  final double? pricePerMTokenOut;

  const OpenRouterModel({
    required this.id,
    required this.name,
    required this.isFree,
    this.pricePerMTokenIn,
    this.pricePerMTokenOut,
  });

  String get priceLabel {
    if (isFree) return 'Free';
    if (pricePerMTokenIn == null) return '?';
    return '\$${(pricePerMTokenIn! * 1000).toStringAsFixed(3)}/1K';
  }
}

// ── Service ───────────────────────────────────────────────────────────────────

class LlmService {
  final LlmProfile profile;
  final String? apiKey;

  const LlmService({required this.profile, this.apiKey});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (apiKey != null && apiKey!.isNotEmpty)
          'Authorization': 'Bearer $apiKey',
        // OpenRouter braucht HTTP-Referer
        if (profile.kind == ProviderKind.openrouter) ...{
          'HTTP-Referer': 'https://oraclevault.app',
          'X-Title': 'OracleVault',
        },
      };

  // ── Chat Completion ────────────────────────────────────────────────────────

  /// Sendet eine Chat-Anfrage und gibt den Antwort-String zurück.
  ///
  /// [jsonMode] aktiviert response_format: {type: json_object} — nicht alle
  /// Modelle unterstützen das. Bei Fehler wird es ohne json_mode nochmal versucht.
  Future<String> chatCompletion({
    required String systemPrompt,
    required String userPrompt,
    String? model,
    bool jsonMode = false,
    double? temperature,
  }) async {
    final body = <String, dynamic>{
      'model': model ?? profile.defaultModel,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userPrompt},
      ],
      'temperature': temperature ?? profile.temperature,
      'max_tokens': profile.maxTokens,
      if (jsonMode) 'response_format': {'type': 'json_object'},
    };

    try {
      final response = await http
          .post(
            Uri.parse('${profile.baseUrl}/chat/completions'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 120));

      return _extractContent(response);
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('Connection refused') ||
          msg.contains('SocketException')) {
        throw LlmException.connectionRefused(profile.baseUrl);
      }
      if (msg.contains('TimeoutException')) {
        throw LlmException.timeout();
      }
      throw LlmException('Fehler: $e');
    }
  }

  String _extractContent(http.Response response) {
    if (response.statusCode == 401) {
      throw const LlmException('API-Key ungültig oder fehlend.',
          type: LlmErrorType.authError);
    }
    if (response.statusCode == 404) {
      throw const LlmException(
          'Modell nicht gefunden. Bitte in den KI-Einstellungen prüfen.',
          type: LlmErrorType.modelNotFound);
    }
    if (response.statusCode != 200) {
      throw LlmException(
          'HTTP ${response.statusCode}: ${response.body.substring(0, 200.clamp(0, response.body.length))}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = data['choices']?[0]?['message']?['content'] as String?;
    if (content == null) {
      throw const LlmException('Leere Antwort vom Modell.',
          type: LlmErrorType.invalidResponse);
    }
    return content;
  }

  // ── Verbindungstest ────────────────────────────────────────────────────────

  /// Einfacher Ping — wirft [LlmException] bei Fehler, gibt true zurück bei Erfolg.
  Future<bool> testConnection() async {
    if (profile.kind == ProviderKind.ollama) {
      try {
        final r = await http
            .get(
              Uri.parse(
                  '${profile.baseUrl.replaceAll('/v1', '')}/api/tags'),
              headers: _headers,
            )
            .timeout(const Duration(seconds: 10));
        if (r.statusCode != 200) {
          throw LlmException('HTTP ${r.statusCode}: ${r.body.substring(0, 200.clamp(0, r.body.length))}');
        }
        return true;
      } on LlmException {
        rethrow;
      } catch (e) {
        throw LlmException('Verbindungsfehler: $e');
      }
    }

    // OpenAI-kompatibel (OpenRouter, LM Studio, Custom): Mini-Completion
    await chatCompletion(
      systemPrompt: 'Reply with exactly the word ok.',
      userPrompt: 'ok',
      temperature: 0,
    );
    return true;
  }

  // ── OpenRouter: Modell-Liste ───────────────────────────────────────────────

  /// Lädt alle verfügbaren Modelle von OpenRouter.
  /// Gibt leere Liste zurück wenn kein Key oder Timeout.
  static Future<List<OpenRouterModel>> fetchOpenRouterModels(
      String apiKey) async {
    try {
      final r = await http
          .get(
            Uri.parse('https://openrouter.ai/api/v1/models'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'HTTP-Referer': 'https://oraclevault.app',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (r.statusCode != 200) return [];
      final data = jsonDecode(r.body) as Map<String, dynamic>;
      final list = (data['data'] as List?) ?? [];

      return list.map((m) {
        final pricing = m['pricing'] as Map<String, dynamic>?;
        final priceIn =
            double.tryParse(pricing?['prompt']?.toString() ?? '');
        final isFree = m['id'].toString().endsWith(':free') ||
            (priceIn != null && priceIn == 0);
        return OpenRouterModel(
          id: m['id'] as String,
          name: (m['name'] as String?) ?? m['id'] as String,
          isFree: isFree,
          pricePerMTokenIn: priceIn != null ? priceIn * 1_000_000 : null,
        );
      }).toList()
        ..sort((a, b) {
          // Free zuerst, dann nach Preis aufsteigend.
          if (a.isFree && !b.isFree) return -1;
          if (!a.isFree && b.isFree) return 1;
          final aP = a.pricePerMTokenIn ?? double.infinity;
          final bP = b.pricePerMTokenIn ?? double.infinity;
          return aP.compareTo(bP);
        });
    } catch (_) {
      return [];
    }
  }
}
