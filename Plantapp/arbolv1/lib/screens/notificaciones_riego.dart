import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> inicializarNotificaciones() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  //const AndroidInitializationSettings initializationSettingsAndroid =
  //AndroidInitializationSettings('app_icon'); //icono de la app

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> mostrarNotificacionRiego(String titulo, String cuerpo) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'canal_riego',
        'Riego',
        channelDescription: 'Notificaciones de riego',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    'hola',
    'que onda',
    platformChannelSpecifics,
  );
}
  //await flutterLocalNotificationsPlugin.show(
    //0,
    //titulo,
    //cuerpo,
    //platformChannelSpecifics,
  //);
//}