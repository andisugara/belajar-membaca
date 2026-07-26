import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  test('Verify word audio assets load correctly', () async {
    // We must initialize the test binding to use services
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Let's check some specific assets
    final assetsToTest = [
      'assets/audio/words/Konsonan/halaman 1/ma.mp3',
      'assets/audio/words/Konsonan/halaman 2/bo.mp3',
      'assets/audio/words/Konsonan/Halaman 11/akar.mp3',
      'assets/audio/words/Sengau/halaman 1/mangga.mp3',
    ];

    for (var asset in assetsToTest) {
      try {
        final byteData = await rootBundle.load(asset);
        expect(byteData.lengthInBytes, greaterThan(0));
        print('Successfully loaded asset: $asset');
      } catch (e) {
        fail('Failed to load asset: $asset. Error: $e');
      }
    }
  });
}
