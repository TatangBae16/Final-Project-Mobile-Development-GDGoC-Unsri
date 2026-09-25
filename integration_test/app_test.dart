import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// 👇 Ganti 'md_midtermproject' dengan nama packagemu jika berbeda
import 'package:md_midtermproject/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  // 1. Inisialisasi Integration Test Binding
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('GearShift End-to-End (E2E) Test 🚀', () {

    testWidgets('Skenario: User Login Manual dan Mengecek Riwayat Transaksi', (WidgetTester tester) async {
      // 1. Jalankan aplikasi
      app.main();

      // 👇 PERBAIKAN: Paksa robot diam menunggu 5 detik
      // Agar Splash Screen dan inisialisasi Supabase benar-benar selesai
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      print('Membersihkan sesi lama...');
      try {
        await Supabase.instance.client.auth.signOut();
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      } catch (_) {}

      // Tunggu lagi sebentar setelah sesi dibersihkan
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // ==========================================
      // FASE 1: PENGUJIAN HALAMAN LOGIN
      // ==========================================
      print('Mencari halaman Login...');

      // Memastikan kita berada di halaman Login
      expect(find.text('GearShift Login'), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);

      // Mencari kolom input (TextField) berdasarkan urutannya
      // Index 0 biasanya adalah Email, Index 1 adalah Password
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).at(1);
      final loginButton = find.text('MASUK');

      // Memastikan kolom input dan tombol ditemukan di layar
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(loginButton, findsOneWidget);

      // Robot mengetikkan email dan password ke dalam kolom
      print('Mengetikkan kredensial login...');
      await tester.enterText(emailField, 'test123@gmail.com'); // 👈 Pastikan ini email valid
      await tester.enterText(passwordField, 'test123'); // 👈 Pastikan ini password valid

      // 👇 TAMBAHAN BARU 1: Tutup keyboard virtual agar layar bawah terlihat
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // 👇 TAMBAHAN BARU 2: Paksa robot men-scroll layar ke arah tombol "MASUK"
      await tester.ensureVisible(loginButton);
      await tester.pumpAndSettle();

      // Cek apakah tombol Face ID / Fingerprint (Biometrik) muncul
      // expect(find.byIcon(Icons.fingerprint), findsOneWidget);
      // expect(find.byIcon(Icons.face_retouching_natural), findsOneWidget);

      // Robot menekan tombol "MASUK"
      print('Menekan tombol MASUK...');
      await tester.tap(loginButton);

      // Tunggu proses loading login BLoC / Supabase selesai (bisa memakan waktu beberapa detik)
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ==========================================
      // FASE 2: PENGUJIAN HALAMAN UTAMA & RIWAYAT
      // ==========================================
      print('Memeriksa navigasi ke Halaman Utama...');

      // Jika login berhasil, Snackbar sukses biasanya muncul
      // expect(find.text('✅ Login Berhasil!'), findsOneWidget);
      // (Opsional: Di-comment karena snackbar cepat hilang)

      // Memastikan robot sudah masuk ke MainPage
      // Robot akan menekan tab "Riwayat" di BottomNavigationBar
      final riwayatTab = find.text('Riwayat');
      if (riwayatTab.evaluate().isNotEmpty) {
        print('Menavigasi ke tab Riwayat...');
        await tester.tap(riwayatTab);
        await tester.pumpAndSettle();
      }

      // Memastikan Halaman Order History Page terbuka dengan mencari judul AppBar-nya
      print('Memverifikasi Halaman Riwayat Transaksi...');
      expect(find.text('Riwayat Transaksi'), findsOneWidget);

      // Tes selesai dengan sukses!
      print('🎉 Skenario E2E Selesai dan Berhasil! 🎉');
    });

  });
}