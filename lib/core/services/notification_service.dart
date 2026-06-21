import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance; //setiap kali dipanggil NotificationService() mengembalikan _instance
  NotificationService._internal(); // _internal untuk mutlak, tidak bisa diacak dari luar

  final FirebaseMessaging _messaging = FirebaseMessaging.instance; //menerima pesan push notification dari server firebase
  final FlutterLocalNotificationsPlugin _localNotifications = //untuk nampiling notif pop up fisik
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    //request permission
    await _messaging.requestPermission( //minta dialog persetujuan dulu di hp
      alert: true,
      badge: true,
      sound: true,
    );

    //initialize local notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initSettings);

    //menangani notifikasi saat aplikasi terbuka foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    //mendapatkan FCM token
    final token = await _messaging.getToken();
    if (token != null) {
      // menyimpan token di Firestore
      // ignore: avoid_print
      print('FCM Token: $token');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'rnd_dewi_sri_channel',
      'RnD Dewi Sri Notifications',
      channelDescription: 'Notifications for RnD Dewi Sri app',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Notifikasi',
      message.notification?.body ?? '',
      details,
    );
  }

  /// Show a local notification directly (for stock alerts, room service, etc.)
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'rnd_dewi_sri_channel',
      'RnD Dewi Sri Notifications',
      channelDescription: 'Notifications for RnD Dewi Sri app',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}
