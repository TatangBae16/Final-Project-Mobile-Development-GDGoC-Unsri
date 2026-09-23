// Lokasi: test/admin/admin_dashboard_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:md_midtermproject/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:md_midtermproject/features/product/presentation/bloc/product_bloc.dart';
import 'package:md_midtermproject/features/product/presentation/bloc/product_event.dart';
import 'package:md_midtermproject/features/product/presentation/bloc/product_state.dart';
import 'package:md_midtermproject/features/order/presentation/bloc/order_bloc.dart';
import 'package:md_midtermproject/features/order/presentation/bloc/order_event.dart';
import 'package:md_midtermproject/features/order/presentation/bloc/order_state.dart';
import 'package:md_midtermproject/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:md_midtermproject/features/auth/presentation/bloc/auth_event.dart';
import 'package:md_midtermproject/features/auth/presentation/bloc/auth_state.dart';

class MockProductBloc extends MockBloc<ProductEvent, ProductState> implements ProductBloc {}
class MockOrderBloc extends MockBloc<OrderEvent, OrderState> implements OrderBloc {}
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockProductBloc mockProductBloc;
  late MockOrderBloc mockOrderBloc;
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockProductBloc = MockProductBloc();
    mockOrderBloc = MockOrderBloc();
    mockAuthBloc = MockAuthBloc();

    whenListen(mockProductBloc, Stream.fromIterable([ProductInitial()]), initialState: ProductInitial());
    whenListen(mockOrderBloc, Stream.fromIterable([OrderInitial()]), initialState: OrderInitial());
    whenListen(mockAuthBloc, Stream.fromIterable([AuthInitial()]), initialState: AuthInitial());
  });

  tearDown(() {
    mockProductBloc.close();
    mockOrderBloc.close();
    mockAuthBloc.close();
  });

  testWidgets('AdminDashboardPage merender Tab Bar dan Floating Action Button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ProductBloc>.value(value: mockProductBloc),
          BlocProvider<OrderBloc>.value(value: mockOrderBloc),
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        ],
        child: const MaterialApp(home: AdminDashboardPage()),
      ),
    );

    // Gunakan pump() biasa untuk menghindari konflik animasi
    await tester.pump();

    // Verifikasi Tab Admin muncul
    expect(find.text('Admin Panel'), findsOneWidget);
    expect(find.text('Kelola Komponen'), findsOneWidget);
    expect(find.text('Semua Transaksi'), findsOneWidget);

    // Verifikasi tombol tambah produk (FAB) muncul di Tab 1
    expect(find.text('Tambah Komponen'), findsOneWidget);
  });
}