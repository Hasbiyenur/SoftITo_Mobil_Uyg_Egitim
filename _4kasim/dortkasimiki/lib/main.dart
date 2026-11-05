import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/storage_ve_fcm_ekrani.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SoftitoFcmDemoApplication());
}

class SoftitoFcmDemoApplication extends StatelessWidget {
  const SoftitoFcmDemoApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Softito FCM Demo Application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(0, 0, 0, 0),
        ),
        useMaterial3: true,
      ),
      home: const StorageVeFcmEkrani(),
    );
  }
}
