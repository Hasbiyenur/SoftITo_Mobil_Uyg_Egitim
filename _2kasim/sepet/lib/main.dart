import 'package:flutter/material.dart';
import 'package:sepet/controller/tekrar3_state.dart';

void main() {
  runApp(
    MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: uygulamaRotalari,
      theme: ThemeData(useMaterial3: true),
    ),
  );
}
