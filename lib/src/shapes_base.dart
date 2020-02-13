import 'package:flutter/material.dart';
import 'dart:math' as math;

class Shapes extends StatelessWidget {
  final Shape shape;
  final ShapeStyle style;
  final Widget child;
  final bool fill;
  Shapes({this.shape, this.style, this.child, this.fill});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height),
      painter: _ShapeCustomPainter(
          shape: ShapesCollection.getShape[shape], style: style, fill: fill),
      child: child ?? child,
    );
  }
}

enum Shape { heart }

class ShapeStyle {
  final Color color;
  final Gradient gradient;
  final double shapeSize;

  ShapeStyle({this.color, this.gradient, this.shapeSize});
}

class ShapesCollection {
  static final Path _heart = Path()
    ..moveTo(75, 40)
    ..cubicTo(75, 37, 70, 25, 50, 25)
    ..cubicTo(20, 25, 20, 62.5, 20, 62.5)
    ..cubicTo(20, 80, 40, 102, 75, 120)
    ..cubicTo(110, 102, 130, 80, 130, 62.5)
    ..cubicTo(130, 62.5, 130, 25, 100, 25)
    ..cubicTo(85, 25, 75, 37, 75, 40)
    ..close();

  static Map<Shape, Path> get getShape => <Shape, Path>{Shape.heart: _heart};
}

class _ShapeCustomPainter extends CustomPainter {
  final Path shape;
  final ShapeStyle style;
  final bool fill;
  _ShapeCustomPainter({this.shape, this.style, this.fill});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = style.gradient.createShader(Offset.zero & size)
      ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    final scale = style.shapeSize / shape.getBounds().size.width;
    canvas.drawPath(shape.center(size).scale(scale), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShapeCustomPainter oldDelegate) => true;
  @override
  bool shouldRebuildSemantics(_ShapeCustomPainter oldDelegate) =>
      false; //TODO: deal with semantics
}

extension PathOperations on Path {
  Path center(Size size) {
    final bbox = getBounds();
    final pathRect = Offset(bbox.center.dx, bbox.center.dy) & size;

    return shift(Offset(-pathRect.centerLeft.dx, -pathRect.topCenter.dy));
  }

  Path scale(double scale) {
    return transform(Transform.scale(scale: scale).transform.storage);
  }
}
