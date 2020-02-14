import 'package:flutter/material.dart';
import 'package:shapes/shapes.dart';
import 'package:flutter_gradients/flutter_gradients.dart';
import 'package:gradient_text/gradient_text.dart';
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
          child: Container(
            height: 150,
            width: 150,
            child: Shapes(
                path: ShapesCollection.heart(),
                animation: ShapeAnimation(
                    duration: 3000,
                    curve: Curves.easeIn,
                    keyframes: <Keyframe>[
                      ScaleKeyframe(step: 1, sx: 1.5, sy: 10, weight: 10),
                      TranslateKeyframe(step: 2, x: 100, y: 100, weight: 70),
                      RotateKeyframe(step: 3, angle: 45.0, weight: 90)
                    ]),
                fill: true,
                style: ShapeStyle(
                    shapeSize: 100,
                    gradient: SweepGradient(
                      startAngle: 0,
                      endAngle: math.pi / 2,
                      stops: [0.0, 1.0],
                      tileMode: TileMode.mirror,
                      colors: <Color>[
                        Color.fromARGB(255, 0, 198, 251),
                        Color.fromARGB(255, 0, 91, 234)
                      ],
                    )),
                child: Center(
                  child: Text(
                    'Flutter',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
          ),
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
