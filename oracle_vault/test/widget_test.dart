// Datei: test/widget_test.dart
//
// ZWECK: Rauch-Test — prüft ob die App ohne Absturz startet und
//        den VaultPickerScreen rendert.
// PHASE: 0 – Grundgerüst.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oracle_vault/app.dart';

void main() {
  testWidgets('App startet und zeigt VaultPickerScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: OracleVaultApp()),
    );
    await tester.pump();

    // Der VaultPickerScreen zeigt den App-Titel.
    expect(find.text('OracleVault'), findsOneWidget);
  });
}
