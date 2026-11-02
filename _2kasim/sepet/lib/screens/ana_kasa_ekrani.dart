import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../controller/tekrar3_state.dart';

class AnaKasaEkrani extends StatelessWidget {
  const AnaKasaEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sepet Ana Sayfası')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bu ekrandayken diğer sekmelere geçebilir ve değişimin etkilerini görebilirsin.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
