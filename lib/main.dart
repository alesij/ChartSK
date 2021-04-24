import 'package:flutter/material.dart';
import 'pages/loading.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/' : (context) => Loading(),
    },
  ));
}