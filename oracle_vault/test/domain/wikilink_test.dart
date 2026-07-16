// Tests für den Wiki-Link-Parser.

import 'package:flutter_test/flutter_test.dart';
import 'package:oracle_vault/domain/wikilink/wikilink.dart';

void main() {
  group('parseWikiLinks', () {
    test('einfacher Tabellen-Link', () {
      final links = parseWikiLinks('Siehe [[Encounters]] für mehr.');
      expect(links, hasLength(1));
      final l = links.single;
      expect(l.kind, WikiLinkKind.link);
      expect(l.target, 'Encounters');
      expect(l.entry, isNull);
      expect(l.alias, isNull);
      expect(l.raw, '[[Encounters]]');
      expect('Siehe [[Encounters]] für mehr.'.substring(l.start, l.end),
          '[[Encounters]]');
    });

    test('Link auf Eintrag [[Table#Entry]]', () {
      final l = parseWikiLinks('[[Monster#Goblin]]').single;
      expect(l.target, 'Monster');
      expect(l.entry, 'Goblin');
      expect(l.alias, isNull);
    });

    test('Alias [[Table|Anzeige]]', () {
      final l = parseWikiLinks('[[Monster|die Bestien]]').single;
      expect(l.target, 'Monster');
      expect(l.entry, isNull);
      expect(l.alias, 'die Bestien');
    });

    test('kombiniert [[Table#Entry|Alias]]', () {
      final l = parseWikiLinks('[[Monster#Goblin|der Kobold]]').single;
      expect(l.target, 'Monster');
      expect(l.entry, 'Goblin');
      expect(l.alias, 'der Kobold');
    });

    test('Embed ![[img.png]]', () {
      final l = parseWikiLinks('Karte: ![[battlemap_01.png]]').single;
      expect(l.kind, WikiLinkKind.embed);
      expect(l.isEmbed, isTrue);
      expect(l.target, 'battlemap_01.png');
      expect(l.raw, '![[battlemap_01.png]]');
    });

    test('mehrere Links in Reihenfolge', () {
      final links = parseWikiLinks('[[A]] Text [[B#x]] und ![[c.png]]');
      expect(links.map((l) => l.target).toList(), ['A', 'B', 'c.png']);
      expect(links.map((l) => l.kind).toList(),
          [WikiLinkKind.link, WikiLinkKind.link, WikiLinkKind.embed]);
      // Offsets sind monoton steigend.
      expect(links[0].start < links[1].start, isTrue);
      expect(links[1].start < links[2].start, isTrue);
    });

    test('trimmt Whitespace in target/entry/alias', () {
      final l = parseWikiLinks('[[  Monster  #  Goblin  |  Kobold  ]]').single;
      expect(l.target, 'Monster');
      expect(l.entry, 'Goblin');
      expect(l.alias, 'Kobold');
    });

    test('ignoriert leere Ziele', () {
      expect(parseWikiLinks('[[]]'), isEmpty);
      expect(parseWikiLinks('[[   ]]'), isEmpty);
      expect(parseWikiLinks('[[#Entry]]'), isEmpty);
      expect(parseWikiLinks('[[ | alias ]]'), isEmpty);
    });

    test('kein Link ohne doppelte Klammern', () {
      expect(parseWikiLinks('[single] und (paren)'), isEmpty);
      expect(parseWikiLinks('Text ohne Links'), isEmpty);
    });

    test('überspannt keine unbalancierten/verschachtelten Klammern', () {
      // Innerer Teil darf keine eckigen Klammern enthalten.
      expect(parseWikiLinks('[[a [[b]] c]]').map((l) => l.target),
          ['b']);
    });

    test('Zeilenumbruch beendet einen Link (kein Match über Zeilen)', () {
      expect(parseWikiLinks('[[a\nb]]'), isEmpty);
    });

    test('nur erstes # trennt Eintrag, weitere # bleiben im Eintrag', () {
      final l = parseWikiLinks('[[T#a#b]]').single;
      expect(l.target, 'T');
      expect(l.entry, 'a#b');
    });
  });
}
