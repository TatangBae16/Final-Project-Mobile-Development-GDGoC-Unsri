// Lokasi: test/product/product_detail_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:md_midtermproject/features/product/presentation/pages/product_detail_page.dart';
import 'package:md_midtermproject/features/product/data/models/product_model.dart';
import 'package:md_midtermproject/features/product/presentation/bloc/quantity_bloc.dart';
import 'package:md_midtermproject/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:md_midtermproject/features/cart/presentation/bloc/cart_event.dart';
import 'package:md_midtermproject/features/cart/presentation/bloc/cart_state.dart';
import 'package:md_midtermproject/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:md_midtermproject/features/wishlist/presentation/bloc/wishlist_event.dart';
import 'package:md_midtermproject/features/wishlist/presentation/bloc/wishlist_state.dart';

class MockWishlistBloc extends MockBloc<WishlistEvent, WishlistState> implements WishlistBloc {}
class MockCartBloc extends MockBloc<CartEvent, CartState> implements CartBloc {}

class FakeProduct extends Fake implements ProductModel {
  @override
  int get id => 1;
  @override
  String get name => 'Piston Ninja';
  @override
  num get price => 250000;
  @override
  String get description => 'Piston ori berkualitas';
  @override
  String get imageUrl => '';
  @override
  int? get stock => 10;
}

void main() {
  late MockWishlistBloc mockWishlistBloc;
  late MockCartBloc mockCartBloc;
  final fakeProduct = FakeProduct();

  setUp(() {
    mockWishlistBloc = MockWishlistBloc();
    mockCartBloc = MockCartBloc();

    whenListen(mockCartBloc, Stream.fromIterable([const CartLoaded([])]), initialState: const CartLoaded([]));
    whenListen(mockWishlistBloc, Stream.fromIterable([const WishlistStatusLoaded(false)]), initialState: const WishlistStatusLoaded(false));
  });

  tearDown(() {
    mockWishlistBloc.close();
    mockCartBloc.close();
  });

  testWidgets('Menampilkan detail produk dan tombol tambah keranjang', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<WishlistBloc>.value(value: mockWishlistBloc),
          BlocProvider<CartBloc>.value(value: mockCartBloc),
          BlocProvider<QuantityBloc>(create: (_) => QuantityBloc()), // Pakai BLoC asli karena logikanya simpel
        ],
        child: MaterialApp(home: ProductDetailPage(product: fakeProduct)),
      ),
    );

    // ANTI-TIMEOUT: Pakai pump biasa karena ada CachedNetworkImage
    await tester.pump();

    // Verifikasi Info Produk Render Sempurna
    expect(find.text('Piston Ninja'), findsOneWidget);
    expect(find.text('Spesifikasi Teknis'), findsOneWidget);
    expect(find.text('Piston ori berkualitas'), findsOneWidget);
    expect(find.text('Stok: 10'), findsOneWidget);

    // Verifikasi Tombol Bawah
    expect(find.text('Tambah ke Keranjang - Rp 250.000'), findsOneWidget);
  });
}