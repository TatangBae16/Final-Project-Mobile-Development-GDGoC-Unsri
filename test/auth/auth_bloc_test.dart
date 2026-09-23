import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'package:md_midtermproject/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:md_midtermproject/features/auth/presentation/bloc/auth_event.dart';
import 'package:md_midtermproject/features/auth/presentation/bloc/auth_state.dart';
import 'package:md_midtermproject/features/auth/data/auth_repository.dart';
// IMPORT MODEL ASLI MILIKMU
import 'package:md_midtermproject/features/auth/data/models/profile_model.dart';

// FAKE DATA
class FakeUser extends Fake implements User {
  @override
  String get id => 'user-123';
}

class FakeAuthResponse extends Fake implements AuthResponse {
  @override
  User? get user => FakeUser();
}

// PERBAIKAN: Gunakan Fake yang mengimplementasi ProfileModel
class FakeProfile extends Fake implements ProfileModel {
  @override
  String get role => 'user';
}

class FakeAuthRepository extends Fake implements AuthRepository {
  bool isSuccess = true;

  @override
  Future<AuthResponse> signIn({required String email, required String password}) async {
    if (isSuccess) return FakeAuthResponse();
    throw Exception("Email atau password salah");
  }

  // PERBAIKAN: Ubah dynamic menjadi ProfileModel
  @override
  Future<ProfileModel> getUserProfile(String userId) async {
    return FakeProfile();
  }
}

// FUNGSI MAIN
void main() {
  group('AuthBloc Unit Test', () {
    late FakeAuthRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeAuthRepository();
    });

    blocTest<AuthBloc, AuthState>(
      'Memancarkan [AuthLoading, Authenticated] saat Login sukses',
      build: () => AuthBloc(authRepository: fakeRepo),
      act: (bloc) => bloc.add(LoginRequested('test@mail.com', 'password123')),
      expect: () => [isA<AuthLoading>(), isA<Authenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'Memancarkan [AuthLoading, AuthError] saat Login gagal',
      build: () {
        fakeRepo.isSuccess = false; // Paksa gagal
        return AuthBloc(authRepository: fakeRepo);
      },
      act: (bloc) => bloc.add(LoginRequested('salah@mail.com', 'salah123')),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );
  });
}