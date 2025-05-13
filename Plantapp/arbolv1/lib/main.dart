import 'package:arbolv1/firebase_options.dart';
import 'package:arbolv1/screens/maps_screen.dart';
import 'package:arbolv1/screens/notificaciones_riego.dart';

//import 'package:arbolv1/services/firebase_services.dart';

//servicio de firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await inicializarNotificaciones();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Adopciones',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const AdoptarPantalla(),
    );
  }
}
