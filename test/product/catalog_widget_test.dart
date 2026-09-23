// Lokasi: test/product/catalog_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:md_midtermproject/features/product/presentation/pages/catalog_page.dart';
import 'package:md_midtermproject/features/product/presentation/bloc/product_bloc.dart';
import 'package:md_midtermproject/features/product/presentation/bloc/product_event.dart';
import 'package:md_midtermproject/features/product/presentation/bloc/product_state.dart';
import 'package:md_midtermproject/features/product/data/models/product_model.dart';
import 'package:md_midtermproject/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:md_midtermproject/features/auth/presentation/bloc/auth_state.dart';
import 'package:md_midtermproject/features/auth/presentation/bloc/auth_event.dart';
import 'package:md_midtermproject/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:md_midtermproject/features/cart/presentation/bloc/cart_state.dart';
import 'package:md_midtermproject/features/cart/presentation/bloc/cart_event.dart';

class MockProductBloc extends MockBloc<ProductEvent, ProductState> implements ProductBloc {}
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
class MockCartBloc extends MockBloc<CartEvent, CartState> implements CartBloc {}

class FakeProduct extends Fake implements ProductModel {
  @override
  int get id => 1;
  @override
  String get name => 'Piston Ninja';
  @override
  num get price => 250000;
  @override
  String get imageUrl => '';
}

void main() {
  late MockProductBloc mockProductBloc;
  late MockAuthBloc mockAuthBloc;
  late MockCartBloc mockCartBloc;

  setUp(() {
    mockProductBloc = MockProductBloc();
    mockAuthBloc = MockAuthBloc();
    mockCartBloc = MockCartBloc();

    // Default state aman untuk Auth dan Cart
    whenListen(mockAuthBloc, Stream.fromIterable([AuthInitial()]), initialState: AuthInitial());
    whenListen(mockCartBloc, Stream.fromIterable([const CartLoaded([])]), initialState: const CartLoaded([]));
  });

  tearDown(() {
    mockProductBloc.close();
    mockAuthBloc.close();
    mockCartBloc.close();
  });

  Widget buildTestableWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductBloc>.value(value: mockProductBloc),
        BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        BlocProvider<CartBloc>.value(value: mockCartBloc),
      ],
      child: const MaterialApp(home: CatalogPage()),
    );
  }

  testWidgets('Menampilkan produk saat state ProductLoaded', (WidgetTester tester) async {
    whenListen(
      mockProductBloc,
      Stream.fromIterable([ProductLoaded([FakeProduct()])]),
      initialState: ProductLoaded([FakeProduct()]),
    );

    await tester.pumpWidget(buildTestableWidget());

    // ANTI-TIMEOUT: Pakai pump biasa karena ada CachedNetworkImage
    await tester.pump();

    // Verifikasi UI Utama
    expect(find.text('GearShift Catalog'), findsOneWidget);
    expect(find.text('Piston Ninja'), findsOneWidget);
    expect(find.text('Rp 250.000'), findsOneWidget);
  });
}