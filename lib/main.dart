import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(LogPetApp());
}

class LogPetApp extends StatelessWidget {
  const LogPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LOG-PET',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}