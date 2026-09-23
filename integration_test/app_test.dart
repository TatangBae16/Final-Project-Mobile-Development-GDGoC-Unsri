// Lokasi: integration_test/app_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Import file main.dart aslimu untuk menjalankan aplikasi secara utuh
// ⚠️ GANTI 'namaproyekmu' DENGAN NAMA PROYEK ASLIMU
import 'package:md_midtermproject/main.dart' as app;

void main() {
  // 1. Wajib dipanggil untuk menyambungkan skrip ke Emulator/HP
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-End Test: Membuka aplikasi secara utuh sampai ke halaman awal', (WidgetTester tester) async {
    // 2. ACT: Jalankan fungsi main() aslimu
    // Ini akan menginisialisasi Supabase sungguhan dan merender layar!
    app.main();

    // 3. WAIT: Tunggu sampai aplikasi selesai proses loading, animasi, dll
    // Kita kasih waktu maksimal 5 detik agar robotnya sabar
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // 4. ASSERT: Mengecek apakah aplikasi berhasil terbuka tanpa crash.
    // Biasanya, kalau kita belum login, aplikasi akan diarahkan ke halaman Login.
    // Mari kita suruh robot mencari tombol atau teks berbunyi "Login" atau "Masuk"

    // 💡 CATATAN: Ubah kata 'Login' di bawah ini dengan teks sungguhan
    // yang ada di halaman LoginPage-mu (misal: 'Masuk', 'Email', atau 'Password')
    expect(find.text('Login'), findsWidgets);
  });
}