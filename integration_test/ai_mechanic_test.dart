import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 👇 Ganti sesuai dengan nama package proyekmu
import 'package:md_midtermproject/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Modul 3: Smart Mechanic AI Flow 🤖', () {
    testWidgets('Skenario: Quick Reply, Chat Manual, Smart Link, dan Cetak PDF', (WidgetTester tester) async {
      app.main();

      // 1. Persiapan: Bersihkan sesi dan buka aplikasi
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      try {
        await Supabase.instance.client.auth.signOut();
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      } catch (_) {}

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // ==========================================
      // FASE 1: LOGIN AKUN EKSISTING
      // ==========================================
      // print('Mencari halaman Login...');
      //
      // // Memastikan kita berada di halaman Login
      // expect(find.text('GearShift Login'), findsOneWidget);
      // expect(find.text('Welcome Back'), findsOneWidget);
      //
      // // Mencari kolom input (TextField) berdasarkan urutannya
      // // Index 0 biasanya adalah Email, Index 1 adalah Password
      // final emailField = find.byType(TextField).first;
      // final passwordField = find.byType(TextField).at(1);
      // final loginButton = find.text('MASUK');
      //
      // // Memastikan kolom input dan tombol ditemukan di layar
      // expect(emailField, findsOneWidget);
      // expect(passwordField, findsOneWidget);
      // expect(loginButton, findsOneWidget);

      print('Mencoba Login...');
      await tester.enterText(find.byType(TextField).at(0), 'tester_tetap1@gearshift.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final btnMasuk = find.text('MASUK');
      await tester.tap(btnMasuk);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // ==========================================
      // FASE 2: NAVIGASI KE TAB MEKANIK AI
      // ==========================================
      print('Membuka tab Mekanik AI...');
      final tabAi = find.text('Mekanik AI');
      await tester.tap(tabAi);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ==========================================
      // FASE 3: MENGGUNAKAN QUICK REPLY
      // ==========================================
      print('Menggeser menu Quick Reply ke samping...');
      final quickReplyBtn = find.text('Motor sering mati mendadak');

      // 👇 TAMBAHAN BARU: Robot akan men-scroll horizontal (swipe ke kiri)
      // secara perlahan sampai tombol keluhan yang dicari benar-benar muncul.
      final quickReplyList = find.byType(ListView).last;

      await tester.dragUntilVisible(
        quickReplyBtn,
        quickReplyList,
        const Offset(-250, 0), // Geser ke kiri pada sumbu X sejauh 250 pixel
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      print('Menekan tombol Quick Reply...');
      // ensureVisible tidak wajib lagi karena dragUntilVisible sudah memastikannya
      await tester.tap(quickReplyBtn);

      // Tunggu AI memproses dan mengetik balasan
      print('Menunggu balasan AI muncul...');
      await tester.pump(const Duration(seconds: 8));
      await tester.pumpAndSettle();

      // ==========================================
      // FASE 4: CHAT MANUAL (FOLLOW-UP)
      // ==========================================
      print('Mengetik pertanyaan lanjutan secara manual...');
      final chatInput = find.byType(TextField).first;

      await tester.enterText(chatInput, 'Bagaimana cara mengecek bagian businya sendiri di rumah?');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      print('Mengirim pesan...');
      final sendBtn = find.byIcon(Icons.send_rounded);
      await tester.tap(sendBtn);

      print('Menunggu balasan AI kedua muncul...');
      await tester.pump(const Duration(seconds: 8));
      await tester.pumpAndSettle();

      // ==========================================
      // FASE 4.5: SMART LINK KE KATALOG & KEMBALI
      // ==========================================
      print('Menggulir obrolan ke bawah...');
      // 👇 TAMBAHAN BARU: Robot menarik layar (ListView/Scrollable) ke atas
      // agar pesan AI yang paling bawah (termasuk tombol) masuk ke dalam layar
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -800));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      print('Menekan tombol Smart Link ke Katalog...');
      // Menggunakan teks yang sesuai dengan kodingan UI-mu
      final smartLinkBtn = find.text('Cari Sparepart di Katalog');
      await tester.ensureVisible(smartLinkBtn);
      await tester.tap(smartLinkBtn);

      print('Menunggu halaman Katalog terbuka...');
      await tester.pumpAndSettle(const Duration(seconds: 3));

      print('Menekan tombol Back (Kembali)...');
      // 👇 Menggunakan ikon panah kiri sesuai dengan gambar screenshot-mu
      final backBtn = find.byIcon(Icons.arrow_back);
      await tester.ensureVisible(backBtn);
      await tester.tap(backBtn);

      print('Menunggu kembali ke halaman obrolan Mekanik AI...');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ==========================================
      // FASE 5: CETAK PDF
      // ==========================================
      print('Menekan tombol Cetak PDF...');

      // Tombol Cetak PDF yang ada di AppBar
      final pdfBtn = find.byIcon(Icons.picture_as_pdf_rounded);

      await tester.ensureVisible(pdfBtn);
      await tester.tap(pdfBtn);

      print('Memproses dokumen PDF...');
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      print('🎉 SKENARIO SMART MECHANIC AI BERHASIL! 🎉');
    });
  });
}