import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'MyHomePage.dart';

class loading extends StatefulWidget {
  const loading({super.key});

  @override
  State<loading> createState() => _loadingState();
}

class _loadingState extends State<loading> {
  @override
  void nav() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MyHomePage()));
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), nav);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      backgroundColor: Color(0xfff1cda6),
      body: Center(
        child: Text(
          'القرآن الكريم ',
          style: TextStyle(
            color: Colors.black,
            fontSize: 40,
          ),
        ),
      ),
    ));
  }
}
