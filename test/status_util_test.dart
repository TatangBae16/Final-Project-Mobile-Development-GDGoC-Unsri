// Lokasi: test/status_util_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// GANTI 'namaproyekmu' dengan nama proyek aslimu
import 'package:md_midtermproject/core/utils/status_util.dart';

void main() {
  group('StatusUtil Unit Test', () {

    test('Mengembalikan warna Oranye jika status mengandung kata PENDING', () {
      // Arrange & Act
      final hasilWarna = StatusUtil.getStatusColor('Payment Pending');
      // Assert
      expect(hasilWarna, Colors.orange);
    });

    test('Mengembalikan warna Merah jika status GAGAL atau CANCEL', () {
      // Arrange & Act
      final hasilBatal = StatusUtil.getStatusColor('Pesanan di-cancel admin');
      final hasilGagal = StatusUtil.getStatusColor('Pembayaran gagal');

      // Assert
      expect(hasilBatal, Colors.red);
      expect(hasilGagal, Colors.red);
    });

    test('Mengembalikan warna Abu-abu jika status tidak dikenali', () {
      // Arrange & Act
      final hasilDefault = StatusUtil.getStatusColor('Status tidak jelas');
      // Assert
      expect(hasilDefault, Colors.grey);
    });

  });
}