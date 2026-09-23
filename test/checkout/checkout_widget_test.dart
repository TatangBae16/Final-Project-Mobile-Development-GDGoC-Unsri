import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:md_midtermproject/features/checkout/presentation/pages/checkout_page.dart';
import 'package:md_midtermproject/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:md_midtermproject/features/cart/presentation/bloc/cart_event.dart';
import 'package:md_midtermproject/features/cart/presentation/bloc/cart_state.dart';
import 'package:md_midtermproject/features/order/presentation/bloc/order_bloc.dart';
import 'package:md_midtermproject/features/order/presentation/bloc/order_event.dart';
import 'package:md_midtermproject/features/order/presentation/bloc/order_state.dart';

class MockOrderBloc extends MockBloc<OrderEvent, OrderState> implements OrderBloc {}
class MockCartBloc extends MockBloc<CartEvent, CartState> implements CartBloc {}

void main() {
  late MockOrderBloc mockOrderBloc;
  late MockCartBloc mockCartBloc;

  setUp(() {
    mockOrderBloc = MockOrderBloc();
    mockCartBloc = MockCartBloc();
    whenListen(mockOrderBloc, Stream.fromIterable([OrderInitial()]), initialState: OrderInitial());
  });

  tearDown(() {
    mockOrderBloc.close();
    mockCartBloc.close();
  });

  testWidgets('CheckoutPage merender Ringkasan Pesanan dan Tombol Bayar', (WidgetTester tester) async {
    final cartItems = [
      {'id': 1, 'quantity': 2, 'products': {'id': 101, 'name': 'Oli Mesin', 'price': 50000}}
    ];

    whenListen(
      mockCartBloc,
      Stream.fromIterable([CartLoaded(cartItems)]),
      initialState: CartLoaded(cartItems),
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<OrderBloc>.value(value: mockOrderBloc),
          BlocProvider<CartBloc>.value(value: mockCartBloc),
        ],
        child: const MaterialApp(home: CheckoutPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Alamat Pengiriman'), findsOneWidget);
    expect(find.text('Ringkasan Pesanan'), findsOneWidget);
    expect(find.text('Oli Mesin (x2)'), findsOneWidget);
    expect(find.text('Rp 100.000'), findsNWidgets(2)); // Total per barang
    expect(find.text('BAYAR SEKARANG'), findsOneWidget);
  });
}