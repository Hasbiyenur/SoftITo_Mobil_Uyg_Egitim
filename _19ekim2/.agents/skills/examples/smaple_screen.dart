import 'package:flutter/material.dart';

/// Örnek referans ekran şablonu (ValueNotifier ve Atomic Widget yaklaşımı)
class SampleWaterScreen extends StatelessWidget {
  const SampleWaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Örnek Su Takibi'),
      ),
      body: const Center(
        child: Text('ValueNotifier ile reaktif ekran'),
      ),
    );
  }
}
