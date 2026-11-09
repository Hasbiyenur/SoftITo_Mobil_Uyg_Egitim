/*
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
*/
/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError=(errordetails){
    FirebaseCrashlytics.instance.recordFlutterFatalError(errordetails);
  };

  PlatformDispatcher.instance.onError=(error,stack){
    FirebaseCrashlytics.instance.recordError(error,stack, fatal: true);
    return true;
  };
  runApp(const SoftitoCrashApp()); //hata var infosu verir. ama detaylıca kim, ne zaman, nerede bunu belirtmez. çalışır ama yeterli değil.
}
*/

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class HataServisi{
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;,

  Future<void> kullaniciTanit({
    required String uid,
    required String rol,
    required String paket,
  }) async {
    await _crashlytics.setUserIdentifier(uid);
    await _crashlytics.setCustomKey('kullanici_rolu',rol); //kullanıcı özelliklerini key olarak atadık
    await _crashlytics.setCustomKey('uyelik_tipi',paket);
  }

  void ayakIziBirak(String adim){
    _crashlytics.log('kullanıcı işlem: $adim');
  }

  Future<void> sessizHataKaydet(dynamic hata, StackTrace stack) async {
    await _crashlytics.recordError(hata, stack, fatal:true);
  }

  ElevatedButton(
    onPressed:(){
      FirebaseCrashlytics.instance.crash();
    },
    child: const Text('Çökme Testi Gönder');
  )
}

