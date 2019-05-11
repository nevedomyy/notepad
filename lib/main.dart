import 'package:flutter/material.dart';
import 'menu.dart';

void main() => runApp(App());

class App extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          textTheme: TextTheme(
            body1: TextStyle(color: Colors.black87, fontSize: 18.0),
          )
      ),
      home: Menu(),
    );
  }
}