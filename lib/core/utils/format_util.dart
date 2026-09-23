// Lokasi: lib/utils/format_util.dart

class FormatUtil {
  static String formatRupiah(num number) {
    return 'Rp ${number.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}