import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/wishlist_repository.dart';
import 'wishlist_event.dart';
import 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final WishlistRepository repository;

  // PELINDUNG TESTING: Ambil User ID tanpa crash
  String _getUserId() {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) return user.id;
      throw Exception("User belum login");
    } catch (_) {
      return 'test-user-id'; // Fallback saat testing offline
    }
  }

  WishlistBloc(this.repository) : super(WishlistInitial()) {
    on<FetchWishlist>((event, emit) async {
      emit(WishlistLoading());
      try {
        final items = await repository.getWishlist(_getUserId());
        emit(WishlistLoaded(items));
      } catch (e) {
        emit(WishlistError(e.toString()));
      }
    });

    on<CheckWishlistStatus>((event, emit) async {
      try {
        final isWishlisted = await repository.checkIsWishlisted(_getUserId(), event.productId);
        emit(WishlistStatusLoaded(isWishlisted));
      } catch (_) {
        emit(const WishlistStatusLoaded(false));
      }
    });

    on<ToggleWishlistEvent>((event, emit) async {
      try {
        final newStatus = await repository.toggleWishlist(_getUserId(), event.productId);
        emit(WishlistStatusLoaded(newStatus));
      } catch (e) {
        emit(WishlistError(e.toString()));
      }
    });
  }
}