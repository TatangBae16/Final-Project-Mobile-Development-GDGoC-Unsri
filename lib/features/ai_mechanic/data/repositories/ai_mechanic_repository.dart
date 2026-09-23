import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Wajib di-import

class AiMechanicRepository {
  // Memanggil instance Supabase yang sudah aktif di aplikasimu
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> getDiagnosticAdvice(String userMessage) async {
    final String apiKey = dotenv.env['GEMINI_API_KEY']?.trim() ?? '';
    if (apiKey.isEmpty) throw Exception("Gemini API Key tidak ditemukan.");

    // Memastikan user sudah login
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Sesi login tidak ditemukan. Silakan login kembali.");

    // Mengambil nama user dari metadata profil (bisa dari register/login)
    // Jika kosong, kita pakai sapaan default "Pengendara"
    final userName = user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? 'Pengendara';

    // 1. Simpan pesan User ke Supabase
    await _supabase.from('ai_chat_history').insert({
      'user_id': user.id,
      'message': userMessage,
      'is_user': true,
    });

    // 2. Ambil riwayat percakapan dari Supabase (diurutkan dari waktu terlama ke terbaru)
    final historyData = await _supabase
        .from('ai_chat_history')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: true);

    // 3. Merakit format history sesuai standar JSON Gemini API
    List<Map<String, dynamic>> chatContents = [];
    for (var row in historyData) {
      chatContents.add({
        "role": row['is_user'] == true ? "user" : "model", // Gemini mengenali 'user' dan 'model'
        "parts": [{"text": row['message']}]
      });
    }

    final String url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite-preview:generateContent?key=$apiKey';
    final dio = Dio();

    // System Instruction khusus v1beta, diinjeksi dengan nama user secara dinamis
    final systemInstruction = {
      "parts": [
        {
          "text": """
            Kamu adalah mekanik bengkel motor senior dengan pengalaman 20+ tahun menangani motor bebek, matic, dan sport (2-tak maupun 4-tak). Kamu sedang melayani pelanggan bernama $userName lewat chat aplikasi DiagnosMoto.
            
            # GAYA BICARA
            - Bahasa Indonesia santai ala obrolan bengkel, tapi tetap profesional dan tidak asal.
            - Sapa $userName di awal percakapan atau saat menyampaikan kesimpulan diagnosa.
            - Boleh pakai istilah bengkel sehari-hari (contoh: "brebet", "ngempos", "nembak", "los" pada kopling) tapi selalu jelaskan maksud teknisnya sekali saja biar user awam paham.
            - Jangan bertele-tele. Langsung ke pokok gejala → dugaan penyebab → rekomendasi.
            
            # RUANG LINGKUP KEAHLIAN
            Fokus HANYA pada sepeda motor. Kuasai 5 sistem berikut dan gejala umum masing-masing:
            1. **Mesin (engine)**: kompresi, piston & ring seher, klep, noken as, karburator/throttle body & injektor, filter udara, oli mesin.
            2. **Kelistrikan & pengapian**: aki (accu), spul (stator), kiprok (regulator/rectifier), CDI/ECU, koil, busi, kabel busi.
            3. **Transmisi & penggerak**: kampas kopling, gigi rasio/girbox, CVT (roller, v-belt, kampas ganda untuk matic), rantai & gear set.
            4. **Pengereman & kaki-kaki**: kampas rem, minyak rem, master rem, shockbreaker, bearing roda, laher.
            5. **Bahan bakar & emisi**: pompa bensin, selang bensin, filter bensin, knalpot/catalytic converter (untuk motor injeksi).
            
            Jika pertanyaan di luar topik motor (misal mobil, elektronik rumah tangga, dsb), tolak dengan sopan dan arahkan kembali ke topik motor.
            
            # METODE DIAGNOSA (selaras dengan mesin sistem pakar Forward Chaining + Certainty Factor)
            1. **Gali gejala dulu** sebelum menyimpulkan. Jika info dari user masih kurang (misal cuma bilang "motor saya rewel"), ajukan MAKSIMAL 2-3 pertanyaan klarifikasi yang paling relevan dulu — jangan langsung menebak.
               Contoh pertanyaan penggali: "Rewelnya pas kondisi mesin dingin atau udah panas, Kak?", "Ada bau bensin nggak pas distarter?", "Terakhir servis/ganti oli kapan?"
            2. Setelah gejala cukup, **petakan ke kemungkinan penyebab** dan urutkan dari yang paling mungkin (persentase keyakinan kasar, mis. "kemungkinan besar ~70%", "kemungkinan lain ~20%") — ini merepresentasikan hasil certainty factor secara natural dalam bahasa, bukan angka rumus mentah.
            3. **Sebutkan sparepart spesifik** yang perlu dicek/diganti untuk tiap dugaan, bukan istilah umum. Misal jangan cuma bilang "cek kelistrikan", tapi "cek kiprok dan spul, kemungkinan kiprok yang soak karena aki gampang tekor".
            4. Tutup dengan **rekomendasi tindakan** yang jelas: apa yang bisa dicek/diperbaiki sendiri vs kapan harus dibawa ke bengkel karena butuh alat khusus (misal congkel klep, servis injektor).
            
            # BATASAN & SAFETY
            - Jangan pernah menyarankan tindakan berbahaya (misal modifikasi ilegal, bypass safety switch, dsb).
            - Kalau gejala mengarah ke hal yang berisiko keselamatan langsung (rem blong, kebocoran bensin parah, oli mesin habis total), tegaskan untuk BERHENTI PAKAI motor dan bawa ke bengkel SEGERA — jangan cuma kasih rekomendasi sparepart santai.
            - Jangan mengarang merek/harga part kalau tidak yakin; boleh bilang "harga bervariasi tergantung merek dan bengkel".
            - Selalu ingatkan bahwa diagnosa berbasis gejala yang disampaikan user, hasil akhir tetap perlu dicek fisik oleh mekanik/bengkel untuk kepastian.
            """
        }
      ]
    };

    int maxRetries = 2; // Maksimal coba ulang 2 kali
    int retryCount = 0;

    while (retryCount <= maxRetries) {
      try {
        final response = await dio.post(
          url,
          data: {
            "system_instruction": systemInstruction,
            "contents": chatContents
          },
          options: Options(headers: {'Content-Type': 'application/json'}),
        );

        if (response.statusCode == 200) {
          final textResponse = response.data['candidates'][0]['content']['parts'][0]['text'].toString();

          // Simpan balasan AI ke Supabase
          await _supabase.from('ai_chat_history').insert({
            'user_id': user.id,
            'message': textResponse,
            'is_user': false,
          });

          return textResponse;
        }
      } catch (e) {
        if (e is DioException) {
          // Deteksi error High Demand (429) atau Server Sibuk (503)
          if (e.response?.statusCode == 429 || e.response?.statusCode == 503) {
            if (retryCount < maxRetries) {
              retryCount++;
              // Tunggu 3 detik sebelum mencoba lagi (Exponential Backoff)
              await Future.delayed(Duration(seconds: 3 * retryCount));
              continue; // Ulangi loop
            }
          }
          throw Exception("Server Error: ${e.response?.data['error']['message'] ?? e.message}");
        }
        throw Exception("Error Sistem: $e");
      }
    }

    // Jika masih gagal setelah diulang
    throw Exception("Bengkel sedang sangat ramai (High Demand). Mohon tunggu beberapa saat lagi.");
  }

  // Fungsi tambahan: Untuk menyedot seluruh history saat halaman AI pertama kali dibuka
  Future<List<Map<String, dynamic>>> getChatHistory() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final data = await _supabase
        .from('ai_chat_history')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(data);
  }

  // Fungsi Baru: Memuat riwayat chat HANYA pada tanggal tertentu
  Future<List<Map<String, dynamic>>> getChatHistoryByDate(DateTime date) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    // Mengatur rentang waktu dari jam 00:00:00 sampai 23:59:59 pada tanggal yang dipilih
    // (Dikonversi ke UTC karena Supabase menyimpan waktu dalam standar UTC)
    final startOfDay = DateTime(date.year, date.month, date.day).toUtc().toIso8601String();
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).toUtc().toIso8601String();

    final data = await _supabase
        .from('ai_chat_history')
        .select()
        .eq('user_id', user.id)
        .gte('created_at', startOfDay) // Lebih besar dari jam 00:00
        .lte('created_at', endOfDay)   // Lebih kecil dari jam 23:59
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(data);
  }
}