import 'package:bvo_matematica/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('arranca en la pantalla de bienvenida', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BvoApp()));
    await tester.pumpAndSettle();
    expect(find.text('Prepara tus pruebas'), findsOneWidget);
    expect(find.text('Comenzar'), findsOneWidget);
  });
}
