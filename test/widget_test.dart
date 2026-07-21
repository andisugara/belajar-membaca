import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:belajar_membaca/main.dart';
import 'package:belajar_membaca/screens/splash_screen.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Set screen size to landscape for game-style testing
    await tester.binding.setSurfaceSize(const Size(1024, 768));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verifikasi bahwa SplashScreen ditampilkan saat pertama kali boot
    expect(find.byType(SplashScreen), findsOneWidget);

    // Biarkan timer splash screen selesai berjalan
    await tester.pump(const Duration(seconds: 3));
  });
}
