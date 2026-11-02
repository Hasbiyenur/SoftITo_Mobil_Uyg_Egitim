import 'package:flutter/material.dart';
import 'package:sepet/controller/tekrar3_state.dart'; //dosyadaki özellikler bu dosyada da kullanılmasını sağlar içine aktarılır

void main() {
  runApp(
    MaterialApp.router(
      //Materialapp e verilen yönlendirme sağlar
      debugShowCheckedModeBanner: false, //debug yazısını kaldırır
      routerConfig: uygulamaRotalari, //Materialapp e verilen yönlendirme aracı
      theme: ThemeData(
        useMaterial3: true,
      ), //tema olarak googleın tasarım dili kullanılıyor
    ),
  );
}
