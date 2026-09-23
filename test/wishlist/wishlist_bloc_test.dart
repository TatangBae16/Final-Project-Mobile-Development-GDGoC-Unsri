import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_midtermproject/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:md_midtermproject/features/wishlist/presentation/bloc/wishlist_event.dart';
import 'package:md_midtermproject/features/wishlist/presentation/bloc/wishlist_state.dart';
import 'package:md_midtermproject/features/wishlist/domain/repositories/wishlist_repository.dart';

class FakeWishlistRepository extends Fake implements WishlistRepository {
  bool isSuccess = true;

  @override
  Future<List<Map<String, dynamic>>> getWishlist(String userId) async {
    if (isSuccess) return [{'id': 1, 'products': {'id': 101, 'name': 'Knalpot Racing', 'price': 500000}}];
    throw Exception('Gagal memuat');
  }

  @override
  Future<bool> checkIsWishlisted(String userId, dynamic productId) async => true;
}

void main() {
  group('WishlistBloc Unit Test', () {
    late FakeWishlistRepository fakeRepo;

    setUp(() => fakeRepo = FakeWishlistRepository());

    blocTest<WishlistBloc, WishlistState>(
      'Emit [Loading, Loaded] saat fetch data berhasil',
      build: () => WishlistBloc(fakeRepo),
      act: (bloc) => bloc.add(FetchWishlist()),
      expect: () => [isA<WishlistLoading>(), isA<WishlistLoaded>()],
    );
  });
}