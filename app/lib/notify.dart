import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _fln = FlutterLocalNotificationsPlugin();

const _channel = AndroidNotificationChannel(
  'offers', 'Nearby offers',
  description: 'Store campaigns triggered as you pass beacons',
  importance: Importance.high,
);

AndroidFlutterLocalNotificationsPlugin? get _android =>
    _fln.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

Future<void> initNotify({void Function(int storeId)? onSelectStore}) async {
  await _fln.initialize(
    settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher')),
    onDidReceiveNotificationResponse: (resp) {
      final id = int.tryParse(resp.payload ?? '');
      if (id != null) onSelectStore?.call(id);
    },
  );
  await _android?.createNotificationChannel(_channel);
}

Future<void> requestNotifyPermission() async {
  await _android?.requestNotificationsPermission();
}

Future<void> showOffer(int id, String title, String body, {String? payload}) => _fln.show(
      id: id,
      title: title,
      body: body,
      payload: payload,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails('offers', 'Nearby offers',
            importance: Importance.high, priority: Priority.high,
            styleInformation: BigTextStyleInformation(body)),
      ),
    );
