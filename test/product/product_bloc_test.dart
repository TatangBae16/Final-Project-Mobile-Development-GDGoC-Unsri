// Lokasi: test/product/product_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_midtermproject/features/product/presentation/bloc/product_bloc.dart';
import 'package:md_midtermproject/features/product/presentation/bloc/product_event.dart';
import 'package:md_midtermproject/features/product/presentation/bloc/product_state.dart';
import 'package:md_midtermproject/features/product/domain/repositories/product_repository.dart';
import 'package:md_midtermproject/features/product/data/models/product_model.dart';

// FAKE DATA
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

class FakeProductRepository extends Fake implements ProductRepository {
  bool isSuccess = true;

  @override
  Future<List<ProductModel>> getProducts({String? query, String? category}) async {
    if (isSuccess) return [FakeProduct()];
    throw Exception("Gagal memuat produk");
  }
}

void main() {
  group('ProductBloc Unit Test', () {
    late FakeProductRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeProductRepository();
    });

    blocTest<ProductBloc, ProductState>(
      'Memancarkan [Loading, Loaded] saat fetch sukses',
      build: () => ProductBloc(repository: fakeRepo),
      act: (bloc) => bloc.add(const FetchProductsEvent()),
      expect: () => [isA<ProductLoading>(), isA<ProductLoaded>()],
    );

    blocTest<ProductBloc, ProductState>(
      'Memancarkan [Loading, Error] saat fetch gagal',
      build: () {
        fakeRepo.isSuccess = false;
        return ProductBloc(repository: fakeRepo);
      },
      act: (bloc) => bloc.add(const FetchProductsEvent()),
      expect: () => [isA<ProductLoading>(), isA<ProductError>()],
    );
  });
}