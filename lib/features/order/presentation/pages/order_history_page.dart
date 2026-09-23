import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/utils/format_util.dart';
import '../../../../core/utils/status_util.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        context.read<OrderBloc>().add(FetchOrderHistory(user.id));
      }
    } catch (e) {
      // 💡 CATATAN: Blok catch ini sengaja ditambahkan agar saat
      // Widget Testing berjalan (tanpa inisialisasi Supabase),
      // aplikasinya tidak crash dan tes UI tetap bisa dilanjutkan.
    }
  }

  // =========================================================
  // FUNGSI _formatRupiah DAN _getStatusColor SUDAH DIHAPUS
  // KARENA KITA SEKARANG MEMAKAI DARI FOLDER utils/
  // =========================================================

  Widget _buildShimmerLoading(bool isDark) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 80, height: 12, color: Colors.white),
                    Container(
                        width: 60, height: 22,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white, thickness: 2),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 120, height: 14, color: Colors.white),
                    Container(width: 70, height: 14, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 90, height: 14, color: Colors.white),
                    Container(width: 70, height: 14, color: Colors.white),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(color: Colors.white, thickness: 2),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 100, height: 16, color: Colors.white),
                    Container(width: 100, height: 18, color: Colors.white),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Riwayat Transaksi', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadOrders();
        },
        child: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {

            if (state is OrderLoading) {
              return _buildShimmerLoading(isDark);
            }

            else if (state is OrderError) {
              return Center(child: Text('Gagal memuat riwayat: ${state.message}'));
            } else if (state is OrderLoaded) {
              final orders = state.orders;

              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text('Belum ada riwayat transaksi', style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final List<dynamic> items = order['items_json'] ?? [];
                  final String status = order['status'] ?? 'Pending';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.08) : Colors.transparent,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order['created_at'].toString().substring(0, 10),
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                // 2. MENGGUNAKAN StatusUtil BARU
                                color: StatusUtil.getStatusColor(status).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  // 2. MENGGUNAKAN StatusUtil BARU
                                    color: StatusUtil.getStatusColor(status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (context, itemIndex) {
                            final item = items[itemIndex];

                            final productData = item['products'] ?? {};
                            final String productName = productData['name'] ?? item['product_name'] ?? 'Produk';
                            final num productPrice = productData['price'] ?? item['price'] ?? 0;
                            final num quantity = item['quantity'] ?? 1;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "$productName x$quantity",
                                      style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Text(
                                    // 3. MENGGUNAKAN FormatUtil BARU
                                    FormatUtil.formatRupiah(productPrice * quantity),
                                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              // 3. MENGGUNAKAN FormatUtil BARU
                              FormatUtil.formatRupiah(order['total_price']),
                              style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),

                        if (status.toLowerCase().contains('pending')) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 35,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: theme.primaryColor),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: Icon(Icons.refresh, size: 16, color: theme.primaryColor),
                              label: Text('CEK STATUS PEMBAYARAN', style: TextStyle(fontSize: 12, color: theme.primaryColor, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                context.read<OrderBloc>().add(CheckOrderPayment(order['id']));
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}