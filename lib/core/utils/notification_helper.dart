import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(settings: settings);

    // Meminta izin notifikasi (Wajib untuk Android 13+)
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // 1. Notifikasi Saat Pesanan Dibuat (Menunggu Pembayaran)
  static Future<void> showOrderCreated() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'order_created_channel',
      'Pesanan Dibuat',
      channelDescription: 'Notifikasi saat pesanan berhasil dibuat',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF36ADA3),
    );

    await _notificationsPlugin.show(
      id: 1,
      title: 'Pesanan Dibuat! 🛒',
      body: 'Pesanan kamu berhasil dibuat. Yuk, selesaikan pembayaranmu sekarang!',
      notificationDetails: const NotificationDetails(android: androidDetails),
    );
  }

  // 2. Notifikasi Saat Pembayaran Berhasil
  static Future<void> showPaymentSuccess() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'payment_success_channel',
      'Pembayaran Berhasil',
      channelDescription: 'Notifikasi saat pembayaran sukses',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF4CAF50), // Warna hijau
    );

    await _notificationsPlugin.show(
      id: 2,
      title: 'Pembayaran Berhasil! 💸',
      body: 'Mantap! Pembayaran sudah kami terima. Mekanik kami sedang memproses pesananmu.',
      notificationDetails: const NotificationDetails(android: androidDetails),
    );
  }

  // 3. Notifikasi Saat Order Dibatalkan
  static Future<void> showOrderCanceled() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'order_cancel_channel',
      'Pesanan Dibatalkan',
      channelDescription: 'Notifikasi saat pesanan dibatalkan',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFF44336), // Warna merah
    );

    await _notificationsPlugin.show(
      id: 3,
      title: 'Pesanan Dibatalkan ❌',
      body: 'Order kamu telah dibatalkan. Jangan ragu untuk berbelanja kembali di GearShift!',
      notificationDetails: const NotificationDetails(android: androidDetails),
    );
  }
}