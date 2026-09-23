import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:md_midtermproject/features/wishlist/presentation/pages/wishlist_page.dart';
import 'package:md_midtermproject/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:md_midtermproject/features/wishlist/presentation/bloc/wishlist_event.dart';
import 'package:md_midtermproject/features/wishlist/presentation/bloc/wishlist_state.dart';
import 'package:md_midtermproject/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:md_midtermproject/features/cart/presentation/bloc/cart_event.dart';
import 'package:md_midtermproject/features/cart/presentation/bloc/cart_state.dart';

class MockWishlistBloc extends MockBloc<WishlistEvent, WishlistState> implements WishlistBloc {}
class MockCartBloc extends MockBloc<CartEvent, CartState> implements CartBloc {}

void main() {
  late MockWishlistBloc mockWishlistBloc;
  late MockCartBloc mockCartBloc;

  setUp(() {
    mockWishlistBloc = MockWishlistBloc();
    mockCartBloc = MockCartBloc();
    whenListen(mockCartBloc, Stream.fromIterable([const CartLoaded([])]), initialState: const CartLoaded([]));
  });

  tearDown(() {
    mockWishlistBloc.close();
    mockCartBloc.close();
  });

  testWidgets('WishlistPage menampilkan barang impian', (WidgetTester tester) async {
    final dummyData = [{'id': 1, 'products': {'id': 101, 'name': 'Knalpot Racing', 'price': 500000, 'image_url': ''}}];

    whenListen(
      mockWishlistBloc,
      Stream.fromIterable([WishlistLoaded(dummyData)]),
      initialState: WishlistLoaded(dummyData),
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<WishlistBloc>.value(value: mockWishlistBloc),
          BlocProvider<CartBloc>.value(value: mockCartBloc),
        ],
        child: const MaterialApp(home: WishlistPage()),
      ),
    );

    await tester.pump(); // Anti-timeout

    expect(find.text('Knalpot Racing'), findsOneWidget);
    expect(find.text('Rp 500.000'), findsOneWidget);
  });
}