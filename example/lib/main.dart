import 'package:flutter/material.dart';
import 'package:shapes/shapes.dart';

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
              shape: Shape.heart,
              style: ShapeStyle(color: Colors.blue),
              child: Text('hey')),
        ));
  }
}
