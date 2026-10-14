import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: SayacSayfasi()));

class SayacSayfasi extends StatefulWidget {
  const SayacSayfasi({super.key});

  @override
  State<SayacSayfasi> createState() => _SayacSayfasiState();
}

class _SayacSayfasiState extends State<SayacSayfasi> {
  int sayac = 0;                    // ① State: değişen bilgi

  void artir() {
    setState(() {                   // ③ "Bir şey değişti, ekranı yenile!"
      sayac++;
    });
  }

  @override
  Widget build(BuildContext context) {   // ② Ekranı çizen metot
    return Scaffold(
      appBar: AppBar(title: const Text('Sayaç')),
      body: Center(
        child: Text('$sayac', style: const TextStyle(fontSize: 48)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: artir,
        child: const Icon(Icons.add),
      ),
    );
  }
}