import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../product/presentation/pages/catalog_page.dart';
import '../bloc/ai_mechanic_bloc.dart';
import '../bloc/ai_mechanic_event.dart';
import '../bloc/ai_mechanic_state.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/services.dart';

class AiMechanicPage extends StatefulWidget {
  const AiMechanicPage({Key? key}) : super(key: key);

  @override
  State<AiMechanicPage> createState() => _AiMechanicPageState();
}

class _AiMechanicPageState extends State<AiMechanicPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<AiMechanicBloc>().add(LoadChatHistoryEvent());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // --- FUNGSI BARU: Membuat Dokumen PDF Rangkuman Diagnosa ---
  Future<void> _generateAndPrintPdf(List<Map<String, dynamic>> chatHistory) async {
    final pdf = pw.Document();

    // Membangun halaman PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header Struk Bengkel
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('GEARSHIFT REPAIR DESK', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text('Laporan Diagnosa Resmi Mekanik AI', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                  ],
                ),
                pw.Text(
                  'Tanggal: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Divider(thickness: 1.5, color: PdfColors.teal),
            pw.SizedBox(height: 16),

            // Daftar Percakapan / Konsultasi
            ...chatHistory.map((chat) {
              final bool isUser = chat['is_user'] ?? false;
              final String message = chat['message'] ?? '';

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: isUser ? PdfColors.grey200 : PdfColors.teal50,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(
                    color: isUser ? PdfColors.grey400 : PdfColors.teal200,
                    width: 0.5,
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      isUser ? 'Keluhan Pengendara:' : 'Diagnosa Mekanik AI:',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: isUser ? PdfColors.grey700 : PdfColors.teal800,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      message,
                      style: const pw.TextStyle(fontSize: 11, color: PdfColors.black),
                    ),
                  ],
                ),
              );
            }).toList(),

            pw.SizedBox(height: 20),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                'Terima kasih telah menggunakan layanan cerdas GearShift.',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
              ),
            ),
          ];
        },
      ),
    );

    // Membuka menu pratinjau (preview) cetak / simpan PDF bawaan HP
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Diagnosa_GearShift_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  // Fungsi memunculkan kalender yang responsif terhadap Dark/Light Mode
  Future<void> _selectDate(BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024), // Tahun mulai aplikasi
      lastDate: DateTime.now(),  // Maksimal hari ini
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
              primary: theme.primaryColor, // Warna header & lingkaran tanggal terpilih
              onPrimary: Colors.white, // Warna teks di dalam lingkaran
              surface: theme.cardColor, // Warna background popup kalender (Dark Navy)
              onSurface: Colors.white, // Warna teks angka tanggal
            )
                : ColorScheme.light(
              primary: theme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            // Memastikan background utama dialog juga mengikuti tema
            dialogBackgroundColor: isDark ? theme.cardColor : Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (mounted) {
        context.read<AiMechanicBloc>().add(FilterChatByDateEvent(picked));
      }
    }
  }

  // Fungsi cerdas merakit teks tanggal, hari, dan jam ala WhatsApp
  String _formatDateTime(String? isoString) {
    if (isoString == null) return '';

    // Ubah UTC ke waktu lokal HP (WIB/WITA/WIT)
    final date = DateTime.parse(isoString).toLocal();
    final now = DateTime.now();

    // Reset jam ke 00:00:00 untuk perbandingan hari yang akurat
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final targetDate = DateTime(date.year, date.month, date.day);

    // Format Jam dan Menit (contoh: 09:05)
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final timeString = '$hour:$minute';

    if (targetDate == today) {
      return 'Hari ini, $timeString';
    } else if (targetDate == yesterday) {
      return 'Kemarin, $timeString';
    } else {
      // Array nama hari dalam bahasa Indonesia
      const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      final dayName = days[date.weekday - 1];

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString().substring(2); // Ambil 2 digit tahun terakhir (misal: 26)

      return '$dayName, $day/$month/$year $timeString';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Smart Mechanic AI'),
        actions: [

          // TOMBOL BARU: Ekspor PDF / Struk
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'Unduh Laporan PDF',
            onPressed: () {
              HapticFeedback.selectionClick();

              final state = context.read<AiMechanicBloc>().state;
              if (state is AiMechanicLoaded && state.chatHistory.isNotEmpty) {
                // Memanggil fungsi pembuat PDF dengan membawa data history saat ini
                _generateAndPrintPdf(state.chatHistory);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tidak ada riwayat chat untuk diekspor.')),
                );
              }
            },
          ),

          // Tombol Kalender di pojok kanan atas
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Cari riwayat tanggal',
            onPressed: () {
              HapticFeedback.selectionClick();
              _selectDate(context);
            }
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: isDark ? Colors.white12 : Colors.black12,
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<AiMechanicBloc, AiMechanicState>(
              listener: (context, state) {
                if (state is AiMechanicLoaded) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state is AiMechanicInitial) {
                  return _buildShimmerLoading(isDark, theme);
                } else if (state is AiMechanicError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(state.errorMessage, style: const TextStyle(color: Colors.redAccent)),
                    ),
                  );
                } else if (state is AiMechanicLoaded) {
                  return Column(
                    children: [
                      // Banner peringatan jika sedang memakai filter tanggal
                      if (state.filterDate != null)
                        Container(
                          width: double.infinity,
                          color: theme.primaryColor.withOpacity(0.1),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Menampilkan chat: ${state.filterDate!.day}/${state.filterDate!.month}/${state.filterDate!.year}',
                                style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                color: theme.primaryColor,
                                onPressed: () {
                                  // Tombol X untuk menghapus filter dan memuat semua chat kembali
                                  context.read<AiMechanicBloc>().add(LoadChatHistoryEvent());
                                },
                              )
                            ],
                          ),
                        ),

                      // List Chat Bubble
                      Expanded(
                        child: state.chatHistory.isEmpty
                            ? _buildEmptyState(isDark, textColor)
                            : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: state.chatHistory.length + (state.isWaitingForAi ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.chatHistory.length) {
                              return _buildTypingIndicator(theme);
                            }

                            final chat = state.chatHistory[index];
                            final isUser = chat['is_user'] as bool;
                            final timeString = _formatDateTime(chat['created_at']);

                            return _buildChatBubble(chat['message'], timeString, isUser, theme, isDark, textColor);
                          },
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          _buildInputArea(context, isDark, theme, textColor),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: isDark ? Colors.white24 : Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('Tidak ada obrolan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  // --- FUNGSI BARU: Efek Loading Shimmer Ala Startup ---
  Widget _buildShimmerLoading(bool isDark, ThemeData theme) {
    // Menyesuaikan warna bayangan dengan tema gelap/terang
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4, // Menampilkan 4 gelembung tiruan
        itemBuilder: (context, index) {
          final isUser = index % 2 != 0; // Selang-seling kiri dan kanan
          return Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              // Lebar tiruan acak agar terlihat natural
              width: MediaQuery.of(context).size.width * (isUser ? 0.5 : 0.7),
              height: isUser ? 50 : 80, // Tinggi tiruan acak
              decoration: BoxDecoration(
                color: Colors.white, // Warnanya bebas karena akan ditimpa oleh Shimmer
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- FUNGSI BARU: Chat Bubble dengan Dukungan Markdown ---
  Widget _buildChatBubble(String message, String time, bool isUser, ThemeData theme, bool isDark, Color textColor) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: isUser ? theme.primaryColor : theme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
          ),
          boxShadow: [
            if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // MENGGANTI TEXT BIASA MENJADI MARKDOWN
            MarkdownBody(
              data: message,
              styleSheet: MarkdownStyleSheet(
                // Menyesuaikan warna teks dengan tema (Dark/Light mode)
                p: TextStyle(color: isUser ? Colors.white : textColor, fontSize: 15, height: 1.4),
                strong: TextStyle(color: isUser ? Colors.white : textColor, fontWeight: FontWeight.bold),
                listBullet: TextStyle(color: isUser ? Colors.white : textColor),
              ),
            ),

            const SizedBox(height: 6),

            // Indikator Jam
            Text(
              time,
              style: TextStyle(
                color: isUser ? Colors.white70 : (isDark ? Colors.white54 : Colors.black54),
                fontSize: 11,
              ),
            ),

            // TOMBOL DEEP LINKING
            if (!isUser) ...[
              const SizedBox(height: 12),
              Divider(height: 1, color: isDark ? Colors.white12 : Colors.grey.shade200),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Mengarahkan ke Katalog...'),
                        backgroundColor: theme.primaryColor,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: Icon(Icons.shopping_cart_rounded, size: 16, color: theme.primaryColor),
                  label: Text(
                      'Cari Sparepart di Katalog',
                      style: TextStyle(color: theme.primaryColor, fontSize: 13, fontWeight: FontWeight.bold)
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.primaryColor.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    backgroundColor: theme.primaryColor.withOpacity(0.05),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    )
        .animate()
        .fade(duration: 300.ms)
        .slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: theme.primaryColor),
            ),
            const SizedBox(width: 12),
            Text('Mekanik sedang mengetik...', style: TextStyle(color: theme.primaryColor, fontSize: 13)),
          ],
        ),
      ),
    )
    // <-- Animasi fade berulang (loop) seperti sedang bernapas
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .fade(begin: 0.5, end: 1.0, duration: 600.ms);
  }

  // --- FUNGSI BARU 1: Merakit deretan tombol Quick Reply ---
  Widget _buildQuickReplies(BuildContext context, ThemeData theme, bool isDark) {
    // Daftar keluhan umum yang sering terjadi di bengkel
    final List<String> quickReplies = [
      "Mesin sering brebet",
      "Tarikan awal ngempos",
      "Suara CVT kasar",
      "Susah distarter pagi",
      "Rem kurang pakem",
      "Motor sering mati mendadak"
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: quickReplies.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ActionChip(
            label: Text(
                quickReplies[index],
                style: TextStyle(fontSize: 13, color: isDark ? Colors.white : theme.primaryColor, fontWeight: FontWeight.w500)
            ),
            backgroundColor: isDark ? theme.cardColor : theme.primaryColor.withOpacity(0.1),
            side: BorderSide(color: theme.primaryColor.withOpacity(0.5)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Langsung mengirim pesan saat chip ditekan
              FocusScope.of(context).unfocus();
              context.read<AiMechanicBloc>().add(SendMessageEvent(quickReplies[index]));
            },
          )
              .animate()
              .fade(delay: (index * 100).ms, duration: 400.ms) // Muncul bergantian tiap 100 milidetik
              .slideX(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut);
        },
      ),
    );
  }

  // --- FUNGSI BARU 2: Input Area yang sudah di-upgrade ---
  Widget _buildInputArea(BuildContext context, bool isDark, ThemeData theme, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 1.0)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Pastikan tidak memakan tinggi layar secara berlebihan
          children: [
            const SizedBox(height: 12),
            // Memanggil fungsi Quick Replies di atas kolom ketik
            _buildQuickReplies(context, theme, isDark),

            // Kolom ketik utama
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLines: 3,
                      minLines: 1,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Ketik keluhan motor...',
                        hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
                        filled: true,
                        fillColor: isDark ? Colors.black.withOpacity(0.2) : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.transparent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () {
                      if (_messageController.text.trim().isNotEmpty) {
                        HapticFeedback.mediumImpact();

                        final text = _messageController.text;
                        _messageController.clear();
                        FocusScope.of(context).unfocus();
                        context.read<AiMechanicBloc>().add(SendMessageEvent(text));
                      }
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: theme.primaryColor,
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}