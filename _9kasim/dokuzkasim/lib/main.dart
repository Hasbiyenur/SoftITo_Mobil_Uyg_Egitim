import 'package:dokuzkasim/bloc/cuzdan_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/cuzdan_bloc.dart';
import 'screens/cuzdan_ekrani.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MiniCuzdanApp());
}

class MiniCuzdanApp extends StatelessWidget {
  const MiniCuzdanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CuzdanBloc()..add(const CuzdanYukleEvent()),
      child: MaterialApp(
        title: "Hasbiyenur'un Cüzdanı",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const .fromARGB(0, 244, 4, 168),
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const CuzdanEkrani(),
      ),
    );
  }
}
