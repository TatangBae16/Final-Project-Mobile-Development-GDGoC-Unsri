// Lokasi: test/cart/cart_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:md_midtermproject/features/cart/presentation/pages/cart_page.dart';
import 'package:md_midtermproject/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:md_midtermproject/features/cart/presentation/bloc/cart_event.dart';
import 'package:md_midtermproject/features/cart/presentation/bloc/cart_state.dart';

class MockCartBloc extends MockBloc<CartEvent, CartState> implements CartBloc {}

void main() {
  late MockCartBloc mockCartBloc;

  setUp(() {
    mockCartBloc = MockCartBloc();
  });

  tearDown(() {
    mockCartBloc.close();
  });

  group('CartPage Widget Tests', () {

    testWidgets('Menampilkan pesan saat Keranjang Kosong', (WidgetTester tester) async {
      // Arrange: Data keranjang kosong ([])
      whenListen(
        mockCartBloc,
        Stream.fromIterable([const CartLoaded([])]),
        initialState: const CartLoaded([]),
      );

      await tester.pumpWidget(
        BlocProvider<CartBloc>.value(
          value: mockCartBloc,
          child: const MaterialApp(home: CartPage()),
        ),
      );

      // Assert
      expect(find.text('Keranjangmu masih kosong'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });

    testWidgets('Menampilkan list barang dan total harga saat Keranjang terisi', (WidgetTester tester) async {
      // Arrange: Ada 1 barang (Harga 150.000, jumlah 2 = Total 300.000)
      final dummyItems = [
        {
          'id': 1,
          'quantity': 2,
          'products': {'id': 101, 'name': 'Oli Mesin Motul', 'price': 150000}
        }
      ];

      whenListen(
        mockCartBloc,
        Stream.fromIterable([CartLoaded(dummyItems)]),
        initialState: CartLoaded(dummyItems),
      );

      await tester.pumpWidget(
        BlocProvider<CartBloc>.value(
          value: mockCartBloc,
          child: const MaterialApp(home: CartPage()),
        ),
      );

      await tester.pump();

      // Assert Teks Nama Barang
      expect(find.text('Oli Mesin Motul'), findsOneWidget);

      // Assert Total Harga (150.000 x 2 = Rp 300.000)
      // Perhatikan kita mencari string yang dihasilkan dari fungsi _formatRupiah milikmu
      expect(find.text('Rp 300.000'), findsOneWidget);

      // Assert Tombol CHECKOUT muncul
      expect(find.text('CHECKOUT'), findsOneWidget);
    });

  });
}