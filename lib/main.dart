import 'package:flutter/material.dart';
import 'inscription_page.dart';

void main() {
  runApp(NyeApp());
}

class NyeApp extends StatelessWidget {
  const NyeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: InscriptionPage(),
    );
  }
}
