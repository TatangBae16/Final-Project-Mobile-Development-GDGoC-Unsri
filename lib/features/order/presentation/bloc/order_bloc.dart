import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/order_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc(this.orderRepository) : super(OrderInitial()) {
    on<FetchOrderHistory>((event, emit) async {
      emit(OrderLoading());
      try {
        await Future.delayed(const Duration(seconds: 1));
        final orders = await orderRepository.getOrderHistory(event.userId);
        emit(OrderLoaded(orders));
      } catch (e) {
        emit(OrderError(e.toString()));
      }
    });

    on<ProcessCheckout>((event, emit) async {
      emit(OrderCheckoutLoading());
      try {
        final url = await orderRepository.createOrderAndGetPaymentUrl(
          userId: event.userId,
          userName: event.userName,
          userEmail: event.userEmail,
          userAddress: event.userAddress,
          totalPrice: event.totalPrice,
          cartItems: event.cartItems,
        );
        emit(OrderCheckoutSuccess(url));
      } catch (e) {
        emit(OrderCheckoutError(e.toString()));
      }
    });

    on<CheckOrderPayment>((event, emit) async {
      try {
        // 1. Jalankan fungsi cek status ke Midtrans/Payment Gateway
        await orderRepository.checkPaymentStatus(event.orderId);

        // 2. Ambil data pesanan terbaru dari Supabase
        final userId = Supabase.instance.client.auth.currentUser!.id;
        final updatedOrders = await orderRepository.getOrderHistory(userId);

        // 3. CARI status pesanan yang baru saja dicek
        final checkedOrder = updatedOrders.cast<Map<String, dynamic>>().firstWhere(
              (order) => order['id'] == event.orderId,
          // 👇 UBAH BAGIAN INI: Mengembalikan Map kosong, bukan null, agar tipe datanya tidak bentrok
          orElse: () => <String, dynamic>{},
        );

        // 4. TEMBAKKAN STATE NOTIFIKASI BERDASARKAN STATUS
        // PERBAIKAN: Cek apakah Map tersebut kosong alih-alih mengecek null
        if (checkedOrder.isNotEmpty) {
          final status = checkedOrder['status'].toString().toLowerCase();

          if (status.contains('success') || status.contains('settlement') || status.contains('lunas')) {
            emit(OrderPaymentSuccess()); // Memicu notifikasi Sukses
          } else if (status.contains('cancel') || status.contains('expire') || status.contains('gagal')) {
            emit(OrderCancelSuccess()); // Memicu notifikasi Batal
          }
        }

        // 5. Terakhir, tampilkan daftar pesanan terbaru di UI
        emit(OrderLoaded(updatedOrders));
      } catch (e) {
        emit(OrderActionError(e.toString()));
      }
    });

    on<FetchAllOrders>((event, emit) async {
      emit(OrderLoading());
      try {
        final orders = await orderRepository.getAllOrders();
        emit(OrderLoaded(orders)); // Reuse state yang sudah ada
      } catch (e) {
        emit(OrderError(e.toString()));
      }
    });
  }
}