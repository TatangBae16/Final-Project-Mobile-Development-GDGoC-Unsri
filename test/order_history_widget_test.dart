import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:md_midtermproject/features/order/presentation/bloc/order_bloc.dart';
import 'package:md_midtermproject/features/order/presentation/bloc/order_event.dart';
import 'package:md_midtermproject/features/order/presentation/bloc/order_state.dart';
import 'package:md_midtermproject/features/order/presentation/pages/order_history_page.dart';
import 'package:shimmer/shimmer.dart';

// Membuat Mock BLoC tiruan khusus untuk pengujian tampilan (UI)
class MockOrderBloc extends MockBloc<OrderEvent, OrderState> implements OrderBloc {}

void main() {
  late MockOrderBloc mockOrderBloc;

  setUp(() {
    mockOrderBloc = MockOrderBloc();
  });

  tearDown(() {
    mockOrderBloc.close();
  });

  group('OrderHistoryPage Widget Tests', () {

    // TES 1 (Yang sudah berhasil sebelumnya)
    testWidgets('Menampilkan pesan kosong saat data orders masih kosong', (WidgetTester tester) async {
      whenListen(
        mockOrderBloc,
        Stream.fromIterable([OrderLoaded([])]),
        initialState: OrderLoaded([]),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<OrderBloc>.value(
            value: mockOrderBloc,
            child: const OrderHistoryPage(),
          ),
        ),
      );

      expect(find.text('Belum ada riwayat transaksi'), findsOneWidget);
    });

    // TES 2 (BARU): Mengecek Animasi Loading (Shimmer)
    testWidgets('Menampilkan efek animasi Shimmer saat state sedang OrderLoading', (WidgetTester tester) async {
      // Arrange: Paksa BLoC memancarkan state Loading
      whenListen(
        mockOrderBloc,
        Stream.fromIterable([OrderLoading()]),
        initialState: OrderLoading(),
      );

      // Act: Render halaman
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<OrderBloc>.value(
            value: mockOrderBloc,
            child: const OrderHistoryPage(),
          ),
        ),
      );

      // Assert: Cari apakah ada widget Shimmer di layar
      expect(find.byType(Shimmer), findsOneWidget);
    });

  });
}