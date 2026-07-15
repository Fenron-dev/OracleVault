// Datei: lib/features/library/collection_icon.dart
//
// ZWECK: Einheitliches Icon pro Collection-Typ. Wird von Sidebar und
//        Collection-Dialog gemeinsam genutzt, damit ein Typ überall gleich
//        aussieht.
// PHASE: 4

import 'package:flutter/material.dart';

import '../../domain/collection_type.dart';

/// Material-Icon für den gespeicherten Collection-Typ-Wire-Wert.
IconData collectionIconFor(String? typeWire) =>
    switch (CollectionType.fromWire(typeWire)) {
      CollectionType.deck => Icons.style_outlined,
      CollectionType.supplement => Icons.menu_book_outlined,
      CollectionType.battlemap => Icons.map_outlined,
      CollectionType.tokens => Icons.casino_outlined,
      CollectionType.generic => Icons.folder_special_outlined,
    };
