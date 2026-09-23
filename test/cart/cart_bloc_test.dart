// Lokasi: test/cart/cart_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_midtermproject/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:md_midtermproject/features/cart/presentation/bloc/cart_event.dart';
import 'package:md_midtermproject/features/cart/presentation/bloc/cart_state.dart';
import 'package:md_midtermproject/features/cart/domain/repositories/cart_repository.dart';

// FAKE DATABASE
class FakeCartRepository extends Fake implements CartRepository {
  bool isSuccess = true;

  @override
  Future<List<Map<String, dynamic>>> fetchCartItems(String userId) async {
    if (isSuccess) {
      return [
        {
          'id': 1,
          'quantity': 2,
          'products': {'id': 101, 'name': 'Oli Mesin Motul', 'price': 150000}
        }
      ];
    } else {
      throw Exception("Gagal koneksi ke database");
    }
  }

  @override
  Future<void> updateQuantity(int cartId, int quantity) async {}
}

void main() {
  group('CartBloc Unit Test', () {
    late FakeCartRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeCartRepository();
    });

    // TES 1: Berhasil memuat keranjang
    blocTest<CartBloc, CartState>(
      'Memancarkan [CartLoading, CartLoaded] saat berhasil mengambil data keranjang',
      build: () => CartBloc(repository: fakeRepo),
      act: (bloc) => bloc.add(FetchCartRequested()),
      expect: () => [
        isA<CartLoading>(),
        isA<CartLoaded>(),
      ],
    );

    // TES 2: Gagal memuat keranjang
    blocTest<CartBloc, CartState>(
      'Memancarkan [CartLoading, CartError] saat koneksi terputus',
      build: () {
        fakeRepo.isSuccess = false;
        return CartBloc(repository: fakeRepo);
      },
      act: (bloc) => bloc.add(FetchCartRequested()),
      expect: () => [
        isA<CartLoading>(),
        isA<CartError>(),
      ],
    );

    // TES 3: Update Kuantitas Langsung (Optimistic Update)
    blocTest<CartBloc, CartState>(
      'Memancarkan state CartLoaded baru saat kuantitas diupdate',
      build: () => CartBloc(repository: fakeRepo),
      seed: () => const CartLoaded([
        {'id': 99, 'quantity': 1, 'products': {'id': 101, 'name': 'Oli', 'price': 50000}}
      ]),
      act: (bloc) => bloc.add(UpdateQuantityRequested(cartId: 99, newQuantity: 5)),
      expect: () => [
        isA<CartLoaded>().having(
              (state) => state.cartItems[0]['quantity'],
          'kuantitas terupdate menjadi 5',
          5,
        ),
      ],
    );
  });
}