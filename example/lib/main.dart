import 'package:flutter/material.dart';
import 'package:shapes/shapes.dart';
import 'package:flutter_gradients/flutter_gradients.dart';
import 'dart:math' as math;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Shapes showcase'),
        ),
        body: Center(
          child: Shapes(
              // size : Size(30,30),
              shape: Shape.heart,
              style: ShapeStyle(
                  color: Colors.blue,
                  gradient: SweepGradient(
                    startAngle: 0,
                    endAngle: math.pi / 2,
                    stops: [0.0, 1.0],
                    tileMode: TileMode.mirror,
                    colors: [
                      stringToColor("#00c6fb"),
                      stringToColor("#005bea")
                    ],
                  )),
              child: Text(
                'Flutter',
                style: TextStyle(color: Colors.white),
              )),
        ));
  }
}

Color _intToColor(int hexNumber) => Color.fromARGB(
    255,
    (hexNumber >> 16) & 0xFF,
    ((hexNumber >> 8) & 0xFF),
    (hexNumber >> 0) & 0xFF);

/// String To Material color
Color stringToColor(String hex) =>
    _intToColor(int.parse(_textSubString(hex), radix: 16));

String _textSubString(String text) {
  if (text == null) return null;

  if (text.length < 6) return null;

  if (text.length == 6) return text;

  return text.substring(1, text.length);
}
