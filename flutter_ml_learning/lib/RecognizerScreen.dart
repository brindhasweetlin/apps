import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecognizerScreen extends StatefulWidget {
  File image;

  RecognizerScreen({required this.image});

  @override
  State<RecognizerScreen> createState() => _RecognizerScreenState();
}

class _RecognizerScreenState extends State<RecognizerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Recognizer"),
      ),
      body: Container(child: Image.file(this.widget.image)),
    );
  }
}
