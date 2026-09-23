import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:md_midtermproject/features/profile/domain/repositories/profile_repository.dart';
import 'package:md_midtermproject/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:md_midtermproject/features/profile/presentation/bloc/profile_event.dart';
import 'package:md_midtermproject/features/profile/presentation/bloc/profile_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ==========================================
// 1. MEMBUAT DATA TIRUAN (FAKE)
// ==========================================
// Kita menipu aplikasi seolah-olah ada data user dari Supabase
class FakeUser extends Fake implements User {
  @override
  String get id => 'user-123';

  @override
  String? get email => 'taruna@mahasiswa.unsri.ac.id';

  @override
  Map<String, dynamic>? get userMetadata => {
    'full_name': 'Taruna Rajasa Iryawan',
    'address': 'Palembang'
  };
}

// Kita membuat jembatan database tiruan agar tidak hit Supabase sungguhan
class FakeProfileRepository extends Fake implements ProfileRepository {
  bool isUserNull = false;

  @override
  User? getCurrentUser() {
    if (isUserNull) return null; // Simulasi jika belum login
    return FakeUser(); // Simulasi jika sudah login
  }
}

// ==========================================
// 2. SKRIP UNIT TEST BLoC
// ==========================================
void main() {
  group('ProfileBloc Unit Test', () {
    late FakeProfileRepository fakeRepo;

    // setUp akan dipanggil otomatis sebelum setiap 1 blok tes dijalankan
    // untuk memastikan datanya selalu segar/direset
    setUp(() {
      fakeRepo = FakeProfileRepository();
    });

    // TEST 1: Skenario Sukses (User Ditemukan)
    blocTest<ProfileBloc, ProfileState>(
      'Harus memancarkan [ProfileLoading, ProfileLoaded] saat LoadProfile dipanggil dan user ada',

      // 1. BUILD: BLoC mana yang mau dites
      build: () => ProfileBloc(fakeRepo),

      // 2. ACT: Event apa yang mau dipicu
      act: (bloc) => bloc.add(LoadProfile()),

      // 3. WAIT: Kita butuh ini karena kemarin kita menambahkan jeda 1 detik untuk efek Shimmer
      wait: const Duration(seconds: 1),

      // 4. EXPECT: Urutan State yang kita harapkan keluar
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileLoaded>(), // Berharap sukses karena data FakeUser ada
      ],
    );

    // TEST 2: Skenario Gagal (User Tidak Ditemukan)
    blocTest<ProfileBloc, ProfileState>(
      'Harus memancarkan [ProfileLoading, ProfileError] saat LoadProfile dipanggil tapi user null',
      build: () {
        fakeRepo.isUserNull = true; // Kita sengaja buat skenarionya error
        return ProfileBloc(fakeRepo);
      },
      act: (bloc) => bloc.add(LoadProfile()),
      wait: const Duration(seconds: 1),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileError>(), // Berharap gagal karena isUserNull = true
      ],
    );
  });
}