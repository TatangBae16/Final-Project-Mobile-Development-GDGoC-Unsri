// Lokasi: test/product/quantity_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_midtermproject/features/product/presentation/bloc/quantity_bloc.dart';
import 'package:md_midtermproject/features/product/presentation/bloc/quantity_event.dart';
import 'package:md_midtermproject/features/product/presentation/bloc/quantity_state.dart';

void main() {
  group('QuantityBloc Unit Test', () {
    // TES 1: Tambah kuantitas (Batas maksimal 10)
    blocTest<QuantityBloc, QuantityState>(
      'Increment menambahkan value jika belum mencapai maxStock',
      build: () => QuantityBloc(),
      act: (bloc) => bloc.add(IncrementQuantity(10)),
      expect: () => [
        isA<QuantityState>().having((state) => state.value, 'value angka harus 2', 2)
      ],
    );

    // TES 2: Kurangi kuantitas (Tidak boleh di bawah 1)
    blocTest<QuantityBloc, QuantityState>(
      'Decrement mengurangi value namun tidak kurang dari 1',
      build: () => QuantityBloc(),
      // Kita panggil decrement 2x dari state awal (1), seharusnya tetap 1 dan tidak memancarkan apapun
      act: (bloc) => bloc.add(DecrementQuantity()),
      expect: () => [], // Tidak ada state baru yang dipancarkan karena value sudah 1
    );
  });
}