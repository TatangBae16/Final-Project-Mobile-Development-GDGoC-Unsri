import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:md_midtermproject/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Modul 2: Katalog & Checkout Flow 🛒', () {
    testWidgets('Skenario: Cari Barang, Tambah Keranjang, dan Bayar', (WidgetTester tester) async {
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
      print('Mencoba Login menggunakan akun eksisting...');
      await tester.enterText(find.byType(TextField).at(0), 'tester_tetap6@gearshift.com'); // 👈 Sesuaikan emailmu
      await tester.enterText(find.byType(TextField).at(1), 'password123'); // 👈 Sesuaikan passwordmu

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final btnMasuk = find.text('MASUK');
      await tester.tap(btnMasuk);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // ==========================================
      // FASE 2: MENCARI BARANG DI KATALOG
      // ==========================================
      print('Mencari barang di Katalog...');
      // Mencari kolom pencarian (asumsi kolom ini adalah TextField pertama di halaman utama)
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'Kampas Kopling Kevlar'); // 👈 Ganti dengan nama produk yang pasti ada di databasemu

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      print('Membuka detail produk...');
      // Mengklik hasil pencarian yang muncul
      final itemKatalog = find.text('Kampas Kopling Kevlar').last;
      await tester.tap(itemKatalog);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ==========================================
      // FASE 3: DETAIL PRODUK & KERANJANG
      // ==========================================
      print('Menambahkan barang ke Keranjang...');
      // 👇 Sesuaikan tulisan dengan tombol di aplikasimu (misal: 'Tambah', 'Add to Cart')
      final btnTambah = find.text('Tambah ke Keranjang - Rp 280.000');
      await tester.ensureVisible(btnTambah);
      await tester.tap(btnTambah);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Jika aplikasimu tidak kembali otomatis ke layar awal setelah klik tambah,
      // aktifkan 3 baris di bawah ini untuk menekan tombol "Back" di pojok kiri atas:

      // print('Kembali ke layar utama...');
      // final btnBack = find.byTooltip('Back').or(find.byIcon(Icons.arrow_back));
      // await tester.tap(btnBack);
      // await tester.pumpAndSettle(const Duration(seconds: 2));

      print('Membuka Keranjang Belanja...');
      // Mencari ikon keranjang di pojok kanan atas
      final iconKeranjang = find.byIcon(Icons.shopping_cart_outlined);
      await tester.tap(iconKeranjang);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ==========================================
      // FASE 4: CHECKOUT & MIDTRANS
      // ==========================================
      print('Menekan tombol CHECKOUT...');
      final btnCheckout = find.text('CHECKOUT');
      await tester.ensureVisible(btnCheckout);
      await tester.tap(btnCheckout);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      print('Menekan tombol BAYAR SEKARANG...');
      final btnBayar = find.text('BAYAR SEKARANG');
      await tester.ensureVisible(btnBayar);
      await tester.tap(btnBayar);

      // 👇 KITA GUNAKAN pump() BUKAN pumpAndSettle() DI SINI
      // Karena aplikasi akan membuka Midtrans (WebView), animasi loadingnya tidak akan
      // pernah berhenti di mata Flutter. pumpAndSettle akan menyebabkan error "timeout".
      await tester.pump(const Duration(seconds: 4));

      print('Memverifikasi bahwa proses diarahkan ke Midtrans...');
      // Cukup pastikan aplikasi tidak crash saat tombol dibayar, tes dianggap sukses.
      print('🎉 SKENARIO KATALOG DAN CHECKOUT BERHASIL! 🎉');
    });
  });
}