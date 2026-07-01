import 'package:flutter_test/flutter_test.dart';

import 'package:caja_herramientas/main.dart';

void main() {
  testWidgets('La app carga y muestra el menu principal', (WidgetTester tester) async {
    await tester.pumpWidget(const CajaHerramientasApp());
    await tester.pump();

    // El titulo de la caja de herramientas debe estar visible.
    expect(find.text('Caja de Herramientas'), findsWidgets);
    // Debe existir la tarjeta de "Acerca de".
    expect(find.text('Acerca de'), findsOneWidget);
  });
}
