import 'package:flutter/material.dart';

import '../controller/tekrar3_state.dart';

class VitrinEkrani extends StatelessWidget {
  const VitrinEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Canlı Vitrin (ValueNotifier)')),
      body: Center(
        child: TextButton(
          onPressed: () {
            SepetKontrolu.ornek.sepeteEkle();
          },
          child: const Text('Sepete Ürün Ekle (+1)'),
        ),
      ),
    );
  }
}
