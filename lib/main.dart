import 'dart:io'; // 👈 Necessário para testar conexão com o emulador
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'
    show kDebugMode, defaultTargetPlatform, TargetPlatform;

import 'screens/prontuario_list_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    final host = defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';

    final isEmulatorRunning = await _checkIfEmulatorRunning(host, 8080);

    if (isEmulatorRunning) {
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      print('🔥 Conectado ao Firestore Emulator em $host:8080');
    } else {
      print('☁️ Emulador não encontrado — conectado ao Firestore real');
    }
  } else {
    print('☁️ Conectado ao Firestore real (produção)');
  }

  runApp(const MyApp());
}

Future<bool> _checkIfEmulatorRunning(String host, int port) async {
  try {
    final socket = await Socket.connect(
      host,
      port,
      timeout: const Duration(seconds: 1),
    );
    socket.destroy();
    return true;
  } catch (_) {
    return false;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prontuário Eletrônico',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: ProntuarioListScreen(),
    );
  }
}
