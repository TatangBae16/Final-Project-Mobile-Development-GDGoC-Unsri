import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:md_midtermproject/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:md_midtermproject/features/profile/presentation/bloc/profile_event.dart';
import 'package:md_midtermproject/features/profile/presentation/bloc/profile_state.dart';
import 'package:md_midtermproject/features/profile/presentation/pages/profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState> implements ProfileBloc {}

class FakeUser extends Fake implements User {
  @override
  String get id => 'user-999';
  @override
  String? get email => 'tester@gearshift.com';
  @override
  Map<String, dynamic>? get userMetadata => {
    'full_name': 'Mekanik Handal',
    'address': 'Jl. Sukses Skripsi No. 1'
  };
}

void main() {
  late MockProfileBloc mockProfileBloc;

  setUp(() {
    mockProfileBloc = MockProfileBloc();
  });

  tearDown(() {
    mockProfileBloc.close();
  });

  group('ProfilePage Widget Tests', () {

    // TES 1 (Yang berhasil nge-scroll tadi)
    testWidgets('Menampilkan nama, email, dan tombol Logout setelah di-scroll', (WidgetTester tester) async {
      whenListen(
        mockProfileBloc,
        Stream.fromIterable([ProfileLoaded(FakeUser())]),
        initialState: ProfileLoaded(FakeUser()),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ProfileBloc>.value(
            value: mockProfileBloc,
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Mekanik Handal'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text('Keluar (Logout)'), findsOneWidget);
    });

    // TES 2 (BARU): Robot mengeklik menu Edit Alamat
    testWidgets('Menampilkan Pop-up Dialog saat menu Alamat Pengiriman diklik', (WidgetTester tester) async {
      whenListen(
        mockProfileBloc,
        Stream.fromIterable([ProfileLoaded(FakeUser())]),
        initialState: ProfileLoaded(FakeUser()),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ProfileBloc>.value(
            value: mockProfileBloc,
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pumpAndSettle(); // Tunggu layar selesai digambar

      // ACT: Suruh robot mengeklik teks 'Alamat Pengiriman'
      await tester.tap(find.text('Alamat Pengiriman'));

      // Tunggu animasi pop-up selesai muncul
      await tester.pumpAndSettle();

      // ASSERT: Pastikan Pop-up Dialog benar-benar muncul dengan judul ini
      expect(find.text('Edit Alamat Pengiriman'), findsOneWidget);
      expect(find.text('Simpan'), findsOneWidget); // Pastikan ada tombol simpan
    });

  });
}