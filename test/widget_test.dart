// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:pi_lj/app.dart';
import 'package:pi_lj/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('Renderiza splash screen na abertura', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    final image = tester.widget<Image>(find.byType(Image).first);
    final provider = image.image;
    expect(provider, isA<AssetImage>());
    expect((provider as AssetImage).assetName, 'assets/images/image_loader.png');

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
