// Datei: lib/domain/wikilink/wikilink.dart
//
// ZWECK: Datenmodell + Parser für Wiki-Links in content/body_md.
//        Unterstützte Formen:
//          [[Table]]              → Link auf eine Tabelle
//          [[Table#Entry]]        → Link auf einen Eintrag einer Tabelle
//          [[Table|Anzeigetext]]  → Link mit abweichendem Anzeigetext (Alias)
//          [[Table#Entry|Alias]]  → kombiniert
//          ![[img.png]]           → Einbettung (Embed) eines Media-Assets
//
//        Reine Dart-Logik ohne Flutter/DB-Abhängigkeit — der Rohtext bleibt
//        unangetastet, der Parser liefert nur die gefundenen Referenzen samt
//        Zeichen-Offsets (für spätere Highlighting/Autocomplete-Nutzung).
// PHASE: 5

/// Art eines Wiki-Links.
enum WikiLinkKind {
  /// `[[…]]` — Verweis (Navigation/Backlink).
  link,

  /// `![[…]]` — Einbettung eines Media-Assets.
  embed,
}

/// Ein im Text gefundener Wiki-Link.
class WikiLink {
  /// [WikiLinkKind.link] oder [WikiLinkKind.embed].
  final WikiLinkKind kind;

  /// Ziel: Tabellenname bzw. Dateiname (bei Embeds).
  final String target;

  /// Eintragsname bei `[[Table#Entry]]`, sonst null.
  final String? entry;

  /// Abweichender Anzeigetext bei `[[…|Alias]]`, sonst null.
  final String? alias;

  /// Offset des ersten Zeichens (`[` bzw. `!`) im Quelltext.
  final int start;

  /// Offset direkt hinter dem schließenden `]]`.
  final int end;

  /// Exakt gematchter Teilstring (inkl. Klammern).
  final String raw;

  const WikiLink({
    required this.kind,
    required this.target,
    required this.start,
    required this.end,
    required this.raw,
    this.entry,
    this.alias,
  });

  bool get isEmbed => kind == WikiLinkKind.embed;

  @override
  String toString() =>
      'WikiLink(${kind.name}, target: "$target"'
      '${entry != null ? ', entry: "$entry"' : ''}'
      '${alias != null ? ', alias: "$alias"' : ''})';

  @override
  bool operator ==(Object other) =>
      other is WikiLink &&
      other.kind == kind &&
      other.target == target &&
      other.entry == entry &&
      other.alias == alias &&
      other.start == start &&
      other.end == end;

  @override
  int get hashCode => Object.hash(kind, target, entry, alias, start, end);
}

/// Matcht `[[…]]` und `![[…]]`. Der Inhalt darf keine eckigen Klammern
/// enthalten, wodurch unbalancierte/verschachtelte Klammern nicht überspannt
/// werden. Führendes `!` markiert einen Embed.
final _wikiLinkPattern = RegExp(r'(!?)\[\[([^\[\]\n]+?)\]\]');

/// Findet alle Wiki-Links in [text] in Reihenfolge ihres Auftretens.
///
/// Leere Ziele (`[[]]`, `[[  ]]`, `[[#Entry]]`) werden ignoriert.
List<WikiLink> parseWikiLinks(String text) {
  final links = <WikiLink>[];

  for (final m in _wikiLinkPattern.allMatches(text)) {
    final isEmbed = m.group(1) == '!';
    final inner = m.group(2)!;

    // Aufteilung: target#entry|alias  (Alias bindet am weitesten außen).
    String rest = inner;
    String? alias;
    final pipe = rest.indexOf('|');
    if (pipe >= 0) {
      alias = rest.substring(pipe + 1).trim();
      rest = rest.substring(0, pipe);
      if (alias.isEmpty) alias = null;
    }

    String target = rest;
    String? entry;
    final hash = rest.indexOf('#');
    if (hash >= 0) {
      entry = rest.substring(hash + 1).trim();
      target = rest.substring(0, hash);
      if (entry.isEmpty) entry = null;
    }

    target = target.trim();
    if (target.isEmpty) continue; // z. B. [[#Entry]] oder [[]]

    links.add(WikiLink(
      kind: isEmbed ? WikiLinkKind.embed : WikiLinkKind.link,
      target: target,
      entry: entry,
      alias: alias,
      start: m.start,
      end: m.end,
      raw: m.group(0)!,
    ));
  }

  return links;
}
