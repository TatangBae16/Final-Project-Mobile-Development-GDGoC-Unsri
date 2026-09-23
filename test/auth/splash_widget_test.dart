// Lokasi: test/auth/splash_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:md_midtermproject/features/auth/presentation/pages/splash_page.dart';
import 'package:md_midtermproject/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:md_midtermproject/features/auth/presentation/bloc/auth_event.dart';
import 'package:md_midtermproject/features/auth/presentation/bloc/auth_state.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  tearDown(() {
    mockAuthBloc.close();
  });

  testWidgets('SplashPage menampilkan Logo, Teks Slogan, dan Animasi Loading', (WidgetTester tester) async {
    whenListen(
      mockAuthBloc,
      Stream.fromIterable([AuthInitial()]),
      initialState: AuthInitial(),
    );

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const MaterialApp(
          home: SplashPage(),
        ),
      ),
    );

    await tester.pump();

    // Verifikasi Slogan, Loading, dan Logo
    expect(find.text('Powering Every Ride'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    // ==========================================
    // PERBAIKAN: Fast-forward waktu virtual robot
    // ==========================================
    // Majukan waktu sebanyak 2 detik agar Future.delayed di initState selesai
    await tester.pump(const Duration(seconds: 2));
  });
}