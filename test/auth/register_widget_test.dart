// Lokasi: test/auth/register_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';

// Ganti dengan nama proyek aslimu
import 'package:md_midtermproject/features/auth/presentation/pages/register_page.dart';
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

  testWidgets('RegisterPage menampilkan seluruh elemen Form Pendaftaran', (WidgetTester tester) async {
    whenListen(
      mockAuthBloc,
      Stream.fromIterable([AuthInitial()]),
      initialState: AuthInitial(),
    );

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const MaterialApp(
          home: RegisterPage(),
        ),
      ),
    );

    await tester.pumpAndSettle(); // Tunggu efek glassmorphism selesai di-render

    // Verifikasi semua teks label input dan tombol muncul di layar
    expect(find.text('Buat Akun Baru'), findsOneWidget);
    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password (Min. 6 Karakter)'), findsOneWidget);
    expect(find.text('DAFTAR SEKARANG'), findsOneWidget);
    expect(find.text('Daftar dengan Google'), findsOneWidget);

    // Verifikasi ikon-ikon utama muncul
    expect(find.byIcon(Icons.person_add_alt_1_rounded), findsOneWidget);
    expect(find.byIcon(Icons.badge_outlined), findsOneWidget);
  });
}