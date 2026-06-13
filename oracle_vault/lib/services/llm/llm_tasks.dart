// Datei: lib/services/llm/llm_tasks.dart
//
// ZWECK: Aufgaben-spezifische Methoden die LlmService verwenden.
//        Jede Funktion kapselt Prompt-Engineering + JSON-Parsing für eine Aufgabe.
//
// AUFGABEN:
//   suggestTagsAndGenre()  – Tags, Genre, Thema für eine Tabelle vorschlagen
//   generateEntries()      – N neue Einträge aus Prompt generieren
//   extendTable()          – Bestehende Tabelle um N Einträge erweitern
//   normalizeImport()      – Rohe Einträge bereinigen + Konfidenz-Score
//   translateEntries()     – Einträge in Zielsprache übersetzen
//
// AUSGABE: strukturiertes JSON (parsed in Dart-Klassen).
// PHASE: 3

import 'dart:convert';

import 'llm_service.dart';

// ── Ergebnis-Typen ────────────────────────────────────────────────────────────

class AiTagSuggestions {
  final List<String> tags;
  final String? genre;
  final String? theme;
  final String? language;

  const AiTagSuggestions({
    this.tags = const [],
    this.genre,
    this.theme,
    this.language,
  });
}

class AiGeneratedEntry {
  final String content;
  final double confidence;
  final int? rollMin;
  final int? rollMax;

  const AiGeneratedEntry({
    required this.content,
    this.confidence = 1.0,
    this.rollMin,
    this.rollMax,
  });
}

class AiGenerationResult {
  final String name;
  final String oracleType;
  final String? diceExpr;
  final List<AiGeneratedEntry> entries;
  final List<String> suggestedTags;
  final String? genre;
  final String? language;

  const AiGenerationResult({
    required this.name,
    required this.oracleType,
    required this.entries,
    this.diceExpr,
    this.suggestedTags = const [],
    this.genre,
    this.language,
  });
}

class AiTableCandidate {
  final String name;
  final List<String> entries;
  const AiTableCandidate({required this.name, required this.entries});
}

class AiTableEnrichment {
  final String? name;
  final String? description;
  final List<String> tags;
  final String? genre;
  final String? theme;

  const AiTableEnrichment({
    this.name,
    this.description,
    this.tags = const [],
    this.genre,
    this.theme,
  });
}

// ── Task-Implementierungen ────────────────────────────────────────────────────

class LlmTasks {
  final LlmService service;

  const LlmTasks(this.service);

  // ── Tag/Genre-Vorschläge ──────────────────────────────────────────────────

  Future<AiTagSuggestions> suggestTagsAndGenre({
    required String tableName,
    required List<String> sampleEntries,
    required String language,
  }) async {
    const system = 'Du bist ein Assistent für RPG-Tabellen-Verwaltung. '
        'Antworte NUR mit gültigem JSON, keine weiteren Erklärungen.';

    final user = '''
Analysiere folgende RPG-Würfeltabelle und schlage Tags, Genre und Thema vor.

Tabellenname: "$tableName"
Beispiel-Einträge (erste ${sampleEntries.length}):
${sampleEntries.map((e) => '- $e').join('\n')}

Antworte mit diesem JSON-Format (alle Felder auf $language):
{
  "tags": ["tag1", "tag2", "tag3"],
  "genre": "Fantasy",
  "theme": "Orte",
  "language": "$language"
}

Regeln:
- tags: 3-6 lowercase Schlagwörter, kein # Präfix
- genre: z.B. Fantasy, SciFi, Horror, Modern, Historisch
- theme: Thematische Kategorie (Orte, Kreaturen, Items, Ereignisse, NSCs, ...)
- language: ISO 639-1 Sprachcode der Einträge
''';

    final raw = await service.chatCompletion(
        systemPrompt: system, userPrompt: user, jsonMode: true);

    try {
      final j = _parseJson(raw);
      return AiTagSuggestions(
        tags: List<String>.from(j['tags'] as List? ?? []),
        genre: j['genre'] as String?,
        theme: j['theme'] as String?,
        language: j['language'] as String?,
      );
    } catch (_) {
      return const AiTagSuggestions();
    }
  }

  // ── Tabelle generieren ─────────────────────────────────────────────────────

  Future<AiGenerationResult> generateTable({
    required String prompt,
    required int count,
    required String language,
    String oracleType = 'uniform',
  }) async {
    final isNumbered = oracleType == 'dice';

    const system =
        'Du bist ein kreativer RPG-Assistent. Erstelle Würfeltabellen '
        'für Pen-&-Paper- und Solo-RPGs. Antworte NUR mit gültigem JSON.';

    final user = '''
Erstelle eine RPG-Würfeltabelle mit $count Einträgen.

Aufgabe: $prompt
Sprache der Einträge: $language
Tabellentyp: $oracleType${isNumbered ? ' (mit rollMin/rollMax)' : ''}

Antworte mit diesem JSON-Format:
{
  "name": "Tabellenname",
  "oracle_type": "$oracleType",
  ${isNumbered ? '"dice_expr": "1d$count",' : ''}
  "entries": [
    {"content": "Eintrag 1"${isNumbered ? ', "roll_min": 1, "roll_max": 5' : ''}},
    {"content": "Eintrag 2"${isNumbered ? ', "roll_min": 6, "roll_max": 10' : ''}}
  ],
  "suggested_tags": ["tag1", "tag2"],
  "genre": "Fantasy",
  "language": "$language"
}

Regeln:
- Genau $count Einträge, alle auf $language
- Jeder Eintrag: konkret, kreativ, direkt nutzbar im Spiel
- Kein Meta-Text, keine Nummerierung im content-Feld
- suggested_tags: 3-5 passende Tags ohne # Präfix
''';

    final raw = await service.chatCompletion(
      systemPrompt: system,
      userPrompt: user,
      jsonMode: true,
      temperature: 0.9,
    );

    try {
      final j = _parseJson(raw);
      final entries = (j['entries'] as List? ?? [])
          .map((e) => AiGeneratedEntry(
                content: (e['content'] as String? ?? '').trim(),
                confidence: 1.0,
                rollMin: e['roll_min'] as int?,
                rollMax: e['roll_max'] as int?,
              ))
          .where((e) => e.content.isNotEmpty)
          .toList();

      return AiGenerationResult(
        name: (j['name'] as String?) ?? prompt.substring(0, 40.clamp(0, prompt.length)),
        oracleType: (j['oracle_type'] as String?) ?? oracleType,
        diceExpr: j['dice_expr'] as String?,
        entries: entries,
        suggestedTags: List<String>.from(j['suggested_tags'] as List? ?? []),
        genre: j['genre'] as String?,
        language: (j['language'] as String?) ?? language,
      );
    } catch (e) {
      throw LlmException('Ungültige KI-Antwort: $e',
          type: LlmErrorType.invalidResponse);
    }
  }

  // ── Tabelle erweitern ──────────────────────────────────────────────────────

  Future<List<AiGeneratedEntry>> extendTable({
    required String tableName,
    required List<String> existingEntries,
    required int addCount,
    required String language,
  }) async {
    const system =
        'You are a creative RPG assistant. Respond ONLY with valid JSON, '
        'no explanations, no markdown, just the raw JSON object.';

    final sample = existingEntries.take(10).toList();
    final user = '''
Add $addCount new entries to this RPG table.

Table: "$tableName"
Existing entries (sample):
${sample.map((e) => '- $e').join('\n')}

Return ONLY this JSON structure (no other text):
{"entries":["entry one","entry two","entry three"]}

Rules:
- Exactly $addCount entries in language "$language"
- No duplicates of existing entries
- Match the style and theme of the table
- Short and direct, no meta-text
''';

    final raw = await service.chatCompletion(
      systemPrompt: system,
      userPrompt: user,
      jsonMode: false, // json_mode zwingt manche Modelle zu schlechtem Format
      temperature: 0.85,
    );

    // ── Robustes Parsing ───────────────────────────────────────────────────
    // Versucht mehrere JSON-Strukturen zu lesen:
    //   {"entries": ["text", ...]}              ← bevorzugtes Format
    //   {"entries": [{"content": "text"}, ...]} ← Object-Format
    //   {"entries": [{"": "text"}, ...]}        ← kaputtes Object-Format
    //   ["text", ...]                           ← direkte Array-Antwort
    final list = _extractEntries(raw);
    if (list.isEmpty) {
      throw LlmException(
          'Keine Einträge generiert. Antwort: ${raw.substring(0, 300.clamp(0, raw.length))}',
          type: LlmErrorType.invalidResponse);
    }
    return list.map((t) => AiGeneratedEntry(content: t)).toList();
  }

  /// Robustes Extrahieren von String-Einträgen aus verschiedenen JSON-Strukturen.
  static List<String> _extractEntries(String raw) {
    final results = <String>[];
    try {
      // Versuche JSON zu parsen — toleriert auch Markdown-Blöcke.
      final decoded = _decodeFlexible(raw);
      if (decoded == null) return results;

      List<dynamic>? items;
      if (decoded is Map) {
        // {"entries": [...]} oder {"items": [...]} oder irgendein Array-Wert
        final val = decoded['entries'] ?? decoded['items'] ??
            decoded.values.whereType<List>().firstOrNull;
        if (val is List) items = val;
      } else if (decoded is List) {
        items = decoded;
      }

      for (final item in (items ?? [])) {
        if (item is String && item.trim().isNotEmpty) {
          results.add(item.trim());
        } else if (item is Map) {
          // {"content": "..."} oder {"":"text"} oder erster String-Wert
          final content = item['content'] as String? ??
              item.values.whereType<String>().firstOrNull ?? '';
          if (content.trim().isNotEmpty) results.add(content.trim());
        }
      }
    } catch (_) {
      // Fallback: Zeilenweise Strings aus dem Rohtext extrahieren
      final lines = raw
          .split('\n')
          .map((l) => l.replaceAll(RegExp(r'^[\s\-\*\d\.\)]+'), '').trim())
          .where((l) => l.length > 3 && !l.startsWith('{') && !l.startsWith('"entries'))
          .toList();
      results.addAll(lines);
    }
    return results;
  }

  static dynamic _decodeFlexible(String raw) {
    try {
      var text = raw.trim();
      final codeBlock = RegExp(r'```(?:json)?\s*([\s\S]*?)```');
      final m = codeBlock.firstMatch(text);
      if (m != null) text = m.group(1)!.trim();
      final start = text.indexOf('{');
      final startArr = text.indexOf('[');
      if (startArr >= 0 && (start < 0 || startArr < start)) {
        return jsonDecode(text.substring(startArr));
      }
      if (start >= 0) return jsonDecode(text.substring(start));
      return jsonDecode(text);
    } catch (_) {
      return null;
    }
  }

  // ── Import-Normalisierung ─────────────────────────────────────────────────

  /// Bereinigt Rohtext-Einträge und gibt strukturierte Einträge mit Konfidenz zurück.
  Future<List<AiGeneratedEntry>> normalizeEntries({
    required List<String> rawEntries,
    required String language,
  }) async {
    const system =
        'Du bist ein Daten-Bereinigungsassistent für RPG-Tabellen. '
        'Antworte NUR mit gültigem JSON.';

    final user = '''
Bereinige diese Roheinträge einer RPG-Tabelle.

Einträge (${rawEntries.length} Stück):
${rawEntries.take(30).toList().asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}

Antworte mit diesem JSON:
{
  "entries": [
    {"content": "Bereinigter Eintrag", "confidence": 0.9},
    {"content": "Unsicherer Eintrag", "confidence": 0.5}
  ]
}

Regeln:
- Einen Ausgabe-Eintrag pro Eingabe-Eintrag (gleiche Reihenfolge)
- Bereinigung: Nummerierung entfernen, Whitespace normalisieren, offensichtliche Tippfehler korrigieren
- confidence: 0.0-1.0 (< 0.7 = unsicher, z.B. unvollständig, unverständlich)
- Einträge auf $language lassen (nicht übersetzen)
''';

    final raw = await service.chatCompletion(
      systemPrompt: system,
      userPrompt: user,
      jsonMode: true,
      temperature: 0.2,
    );

    try {
      final j = _parseJson(raw);
      return (j['entries'] as List? ?? [])
          .map((e) => AiGeneratedEntry(
                content: (e['content'] as String? ?? '').trim(),
                confidence:
                    (e['confidence'] as num?)?.toDouble() ?? 1.0,
              ))
          .where((e) => e.content.isNotEmpty)
          .toList();
    } catch (_) {
      return rawEntries
          .map((e) => AiGeneratedEntry(content: e))
          .toList();
    }
  }

  // ── Übersetzung ───────────────────────────────────────────────────────────

  /// Übersetzt Tabelleneinträge in [targetLanguage] (ISO 639-1).
  /// Gibt die übersetzten Texte in gleicher Reihenfolge zurück.
  Future<List<String>> translateEntries({
    required List<String> entries,
    required String targetLanguage,
    String? sourceLanguage,
    String? tableContext,
  }) async {
    const system =
        'Du bist ein professioneller Übersetzer für RPG-Tabellen. '
        'Antworte NUR mit gültigem JSON, keine weiteren Erklärungen.';

    final langLabel = switch (targetLanguage) {
      'de' => 'Deutsch',
      'en' => 'Englisch',
      'fr' => 'Französisch',
      'es' => 'Spanisch',
      'it' => 'Italienisch',
      _ => targetLanguage,
    };

    // Zeilenumbrüche im Prompt-Text kollabieren — importierte Einträge können
    // mehrzeilig sein und würden sonst das nummerierte Format brechen.
    final promptTexts = entries
        .map((e) => e.replaceAll(RegExp(r'[\r\n\t]+'), ' ').trim())
        .toList();

    final user = '''
Übersetze diese RPG-Tabellen-Einträge nach $langLabel.

${tableContext != null ? 'Kontext (Tabellenname): "$tableContext"\n' : ''}Einträge (${entries.length} Stück):
${promptTexts.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}

Antworte mit diesem JSON:
{
  "entries": [
    "Übersetzter Eintrag 1",
    "Übersetzter Eintrag 2"
  ]
}

Regeln:
- Einen Ausgabe-Eintrag pro Eingabe-Eintrag (gleiche Reihenfolge)
- RPG-typische Begriffe (z. B. Magie, Würfeltypen, Klassen) sinngemäß übertragen
- Kurz und prägnant bleiben — kein Meta-Text
''';

    final raw = await service.chatCompletion(
      systemPrompt: system,
      userPrompt: user,
      jsonMode: true,
      temperature: 0.3,
    );

    try {
      final j = _parseJson(raw);
      final list = (j['entries'] as List?)
          ?.map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (list == null || list.isEmpty) {
        throw LlmException(
          'Keine Einträge in der Übersetzungsantwort. '
          'Antwort: ${raw.substring(0, 200.clamp(0, raw.length))}',
          type: LlmErrorType.invalidResponse,
        );
      }
      return list;
    } catch (e) {
      if (e is LlmException) rethrow;
      throw LlmException(
        'Übersetzungs-Antwort konnte nicht gelesen werden: $e',
        type: LlmErrorType.invalidResponse,
      );
    }
  }

  // ── Multi-Tabellen-Extraktion ─────────────────────────────────────────────

  /// Erkennt mehrere Oracle-Tabellen in einem Fließtext via LLM.
  /// Fallback wenn die Muster-Erkennung (TextAdapter.splitByHeaders) < 2 Tabellen findet.
  Future<List<AiTableCandidate>> extractMultipleTables({
    required String text,
  }) async {
    const system =
        'You are a structured data extraction assistant for RPG oracle/random tables. '
        'Respond ONLY with valid JSON, no other text.';

    final snippet = text.length > 4000 ? text.substring(0, 4000) : text;

    final user = '''
Extract all oracle/random tables from the following RPG document text.
Each table is a numbered or labeled list with a heading.
For each table return its name and the list of entries WITHOUT dice numbers.

Return this JSON (no other text):
{
  "tables": [
    {"name": "Table Name", "entries": ["entry text 1", "entry text 2"]},
    {"name": "Another Table", "entries": ["entry a", "entry b"]}
  ]
}

Rules:
- Remove leading numbers/dice prefixes from entries (e.g. "1 dog" → "dog")
- Keep entry text complete and clean
- Section headings/questions become table names
- Minimum 2 entries per table; skip headers without entries

Document text:
$snippet
''';

    final raw = await service.chatCompletion(
      systemPrompt: system,
      userPrompt: user,
      jsonMode: true,
      temperature: 0.1,
    );

    try {
      final j = _parseJson(raw);
      final list = (j['tables'] as List? ?? []);
      return list
          .map((t) => AiTableCandidate(
                name: (t['name'] as String? ?? 'Tabelle').trim(),
                entries: List<String>.from(
                    (t['entries'] as List? ?? [])
                        .map((e) => e.toString().trim())
                        .where((e) => e.isNotEmpty)),
              ))
          .where((t) => t.entries.length >= 2)
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Tabellen-Anreicherung ─────────────────────────────────────────────────

  /// Schlägt Titel, Beschreibung, Tags, Genre und Thema für eine Tabelle vor.
  Future<AiTableEnrichment> enrichTable({
    required String currentName,
    required List<String> sampleEntries,
    required String language,
  }) async {
    const system =
        'Du bist ein Assistent für RPG-Tabellen-Verwaltung. '
        'Antworte NUR mit gültigem JSON, keine weiteren Erklärungen.';

    final langLabel = switch (language) {
      'de' => 'Deutsch',
      'en' => 'Englisch',
      _ => language,
    };

    final user = '''
Analysiere diese RPG-Würfeltabelle und erstelle passende Metadaten.

Aktueller Name: "$currentName"
Beispiel-Einträge (erste ${sampleEntries.length}):
${sampleEntries.map((e) => '- $e').join('\n')}

Antworte mit diesem JSON (alle Texte auf $langLabel):
{
  "name": "Optimierter Tabellenname",
  "description": "2-3 Sätze: was enthält die Tabelle, wann nutzt man sie, besonderes Merkmal",
  "tags": ["tag1", "tag2", "tag3"],
  "genre": "Fantasy",
  "theme": "Charakterhintergrund"
}

Regeln:
- name: präzise, RPG-üblich, max 60 Zeichen
- description: konkret und nützlich, kein Meta-Text wie "Diese Tabelle enthält..."
- tags: 3-6 lowercase Schlagwörter ohne # Präfix
- genre: Fantasy | SciFi | Horror | Modern | Historisch | Universal
- theme: Orte | Kreaturen | Items | Ereignisse | NSCs | Charaktere | Encounter | Atmosphäre | Sonstiges
''';

    final raw = await service.chatCompletion(
      systemPrompt: system,
      userPrompt: user,
      jsonMode: true,
      temperature: 0.7,
    );

    try {
      final j = _parseJson(raw);
      return AiTableEnrichment(
        name: j['name'] as String?,
        description: j['description'] as String?,
        tags: List<String>.from(j['tags'] as List? ?? []),
        genre: j['genre'] as String?,
        theme: j['theme'] as String?,
      );
    } catch (_) {
      return const AiTableEnrichment();
    }
  }

  // ── Hilfsmethoden ─────────────────────────────────────────────────────────

  /// Parst JSON aus LLM-Antwort — toleriert Markdown-Code-Blöcke.
  static Map<String, dynamic> _parseJson(String raw) {
    var text = raw.trim();
    // Markdown-Code-Block entfernen (```json ... ```)
    final codeBlock = RegExp(r'```(?:json)?\s*([\s\S]*?)```');
    final match = codeBlock.firstMatch(text);
    if (match != null) text = match.group(1)!.trim();
    // JSON-Start suchen falls Preamble vorhanden
    final start = text.indexOf('{');
    if (start > 0) text = text.substring(start);
    return jsonDecode(text) as Map<String, dynamic>;
  }
}
