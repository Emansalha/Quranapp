import 'package:flutter/material.dart';
import 'package:quran_app/MyHomePage.dart';
import 'package:quran_app/loading_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Directionality(textDirection: TextDirection.rtl, child: loading()),
    );
  }
}
