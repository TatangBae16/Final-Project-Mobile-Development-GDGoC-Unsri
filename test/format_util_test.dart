// Lokasi: test/format_util_test.dart

import 'package:flutter_test/flutter_test.dart';
// GANTI 'namaproyekmu' dengan nama proyek aslimu (contoh: gearshift)
import 'package:md_midtermproject/core/utils/format_util.dart';

void main() {
  group('FormatUtil Unit Test', () {

    test('formatRupiah harus mengubah angka menjadi format Rupiah yang benar', () {
      // 1. Arrange (Persiapan)
      const hargaMurah = 15000;
      const hargaMahal = 1500000;
      const hargaNol = 0;

      // 2. Act (Eksekusi)
      final hasilMurah = FormatUtil.formatRupiah(hargaMurah);
      final hasilMahal = FormatUtil.formatRupiah(hargaMahal);
      final hasilNol = FormatUtil.formatRupiah(hargaNol);

      // 3. Assert (Validasi)
      expect(hasilMurah, 'Rp 15.000');
      expect(hasilMahal, 'Rp 1.500.000');
      expect(hasilNol, 'Rp 0');
    });

  });
}