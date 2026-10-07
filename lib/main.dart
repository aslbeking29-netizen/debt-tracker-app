import 'package:flutter/material.dart';

import 'screens/royxat_ekran.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QarzDaftariApp());
}

class QarzDaftariApp extends StatelessWidget {
  const QarzDaftariApp({super.key});

  @override
  Widget build(BuildContext context) {
    final rangSxemasi = ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Qarz Daftari',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: rangSxemasi,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: rangSxemasi.primary,
          foregroundColor: rangSxemasi.onPrimary,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: rangSxemasi.primary,
          foregroundColor: rangSxemasi.onPrimary,
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: Colors.teal,
        ),
      ),
      home: const RoyxatEkran(),
    );
  }
}
