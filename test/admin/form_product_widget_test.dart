// Lokasi: test/admin/form_product_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:md_midtermproject/features/admin/presentation/pages/form_product_page.dart';
import 'package:md_midtermproject/features/product/presentation/bloc/product_bloc.dart';
import 'package:md_midtermproject/features/product/presentation/bloc/product_event.dart';
import 'package:md_midtermproject/features/product/presentation/bloc/product_state.dart';

class MockProductBloc extends MockBloc<ProductEvent, ProductState> implements ProductBloc {}

void main() {
  late MockProductBloc mockProductBloc;

  setUp(() {
    mockProductBloc = MockProductBloc();
    whenListen(
      mockProductBloc,
      Stream.fromIterable([ProductInitial()]),
      initialState: ProductInitial(),
    );
  });

  tearDown(() {
    mockProductBloc.close();
  });

  testWidgets('FormProductPage merender elemen input form admin dengan lengkap', (WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider<ProductBloc>.value(
        value: mockProductBloc,
        child: const MaterialApp(
          home: FormProductPage(),
        ),
      ),
    );

    await tester.pump();

    // Verifikasi bahwa kolom input teks berhasil dirender dengan sempurna
    expect(find.byType(TextField), findsWidgets);
  });
}