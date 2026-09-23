// Lokasi: lib/utils/status_util.dart
import 'package:flutter/material.dart';

class StatusUtil {
  static Color getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('pending')) return Colors.orange;
    if (s.contains('success')) return Colors.green;
    if (s.contains('cancel') || s.contains('gagal')) return Colors.red;
    if (s.contains('dikemas')) return Colors.blue;
    if (s.contains('dikirim')) return Colors.green;

    // Default warna jika status tidak dikenali
    return Colors.grey;
  }
}