import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 👇 Ganti sesuai dengan nama package proyekmu
import 'package:md_midtermproject/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Modul 1: Autentikasi (Auth Flow) 🔐', () {
    testWidgets('Skenario: Register (Auto-Login), Logout User, dan Login Admin', (WidgetTester tester) async {
      app.main();

      // 1. Persiapan: Tunggu aplikasi menyala dan bersihkan sesi lama
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      try {
        await Supabase.instance.client.auth.signOut();
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      } catch (_) {}

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      print('Mencari halaman Login...');
      expect(find.text('GearShift Login'), findsOneWidget);

      // ==========================================
      // FASE 1: REGISTER AKUN BARU (Otomatis masuk/Auto-login)
      // ==========================================
      print('Masuk ke halaman Register...');
      final registerLink = find.text('Belum punya akun? Daftar di sini');
      await tester.ensureVisible(registerLink);
      await tester.tap(registerLink);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 👇 INGAT: Jika mau ngetes untuk kedua kalinya, ubah angka di email ini! (misal: tester_tetap3)
      final String staticEmail = 'tester_tetap6@gearshift.com';
      final String testPassword = 'password123';

      print('Mengisi form pendaftaran dengan email: $staticEmail');

      await tester.enterText(find.byType(TextField).at(0), 'Robot Tester');
      await tester.enterText(find.byType(TextField).at(1), staticEmail);
      await tester.enterText(find.byType(TextField).at(2), testPassword);

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      print('Menekan tombol DAFTAR...');
      final btnDaftar = find.text('DAFTAR SEKARANG');
      await tester.ensureVisible(btnDaftar);
      await tester.tap(btnDaftar);

      // Tunggu proses register selesai.
      // Karena aplikasi auto-login, kita tunggu agak lama agar layar Utama (MainPage) terbuka.
      print('Menunggu proses registrasi dan auto-login selesai...');
      await tester.pumpAndSettle(const Duration(seconds: 6));

      // ==========================================
      // FASE 2: NAVIGASI PROFIL & LOGOUT USER
      // ==========================================
      print('Mencari Tab Profil...');
      final profilTab = find.text('Profil');
      await tester.tap(profilTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      print('Men-scroll halaman profil ke bawah...');
      // 👇 TAMBAHAN BARU: Robot menyapu (swipe) layar ke atas sejauh 500 pixel
      // untuk memunculkan tombol Keluar yang ada di paling bawah
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -500));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      print('Melakukan Logout dari akun User...');
      final btnKeluar = find.text('Keluar (Logout)');
      await tester.ensureVisible(btnKeluar); // Pastikan tombol benar-benar terlihat
      await tester.tap(btnKeluar);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Memastikan sudah terlempar kembali ke halaman Login
      expect(find.text('GearShift Login'), findsOneWidget);

      // ==========================================
      // FASE 3: LOGIN SEBAGAI ADMIN
      // ==========================================
      print('Mencoba Login menggunakan akun Admin...');
      await tester.enterText(find.byType(TextField).at(0), 'admin123@gmail.com');
      await tester.enterText(find.byType(TextField).at(1), 'admin123');

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final btnMasuk = find.text('MASUK');
      await tester.ensureVisible(btnMasuk);
      await tester.tap(btnMasuk);

      await tester.pumpAndSettle(const Duration(seconds: 4));

      // ==========================================
      // FASE 4: NAVIGASI ADMIN & LOGOUT ICON
      // ==========================================
      print('Mengecek navigasi Admin Dashboard...');
      final tabTransaksi = find.text('Semua Transaksi');

      if (tabTransaksi.evaluate().isNotEmpty) {
        await tester.tap(tabTransaksi);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      print('Melakukan Logout dari ikon AppBar...');
      final iconLogout = find.byIcon(Icons.logout);
      await tester.tap(iconLogout);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verifikasi akhir
      print('Memverifikasi status kembali ke layar Login...');
      expect(find.text('GearShift Login'), findsOneWidget);
      print('🎉 SELURUH SKENARIO AUTHENTICATION BERHASIL! 🎉');
    });
  });
}