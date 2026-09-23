import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  // ========================================================
  // 1. CONSTRUCTOR (Sangat bersih, hanya berisi pendaftaran)
  // ========================================================
  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    _initSupabaseListener();

    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  // ========================================================
  // 2. METHOD-METHOD LOGIKA (Dipisah agar rapi & anti-error)
  // ========================================================

  void _initSupabaseListener() {
    try {
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final supabaseEvent = data.event;
        if (supabaseEvent == AuthChangeEvent.signedIn) {
          Future.delayed(const Duration(milliseconds: 500), () {
            add(AuthCheckRequested());
          });
        }
      });
    } catch (e) {
      // Abaikan error saat Widget/Unit Testing berjalan
    }
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final user = authRepository.getCurrentUser();
    if (user != null) {
      try {
        final profile = await authRepository.getUserProfile(user.id);
        emit(Authenticated(user, profile));
      } catch (e) {
        emit(Unauthenticated());
      }
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.signIn(email: event.email, password: event.password);
      if (response.user != null) {
        final profile = await authRepository.getUserProfile(response.user!.id);
        emit(Authenticated(response.user!, profile));
      } else {
        emit(AuthError("Gagal login, user tidak ditemukan."));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.signUp(email: event.email, password: event.password, name: event.name);
      if (response.user != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        final profile = await authRepository.getUserProfile(response.user!.id);
        emit(Authenticated(response.user!, profile));
      } else {
        emit(AuthError("Gagal mendaftar."));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      // Abaikan jika error saat testing
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(Unauthenticated());
  }

  Future<void> _onGoogleSignInRequested(GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final isSuccess = await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'gearshift://login-callback',
      );

      if (!isSuccess) {
        emit(AuthError('Proses Google Login dibatalkan atau gagal dipanggil.'));
      }
    } catch (e) {
      emit(AuthError('Terjadi kesalahan: ${e.toString()}'));
    }
  }
}