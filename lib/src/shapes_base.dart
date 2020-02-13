
import 'package:flutter/material.dart';

class Shapes extends StatelessWidget {
  final Shape shape;
  final ShapeStyle style;
  Shapes({this.shape, this.style});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: _ShapeCustomPainter(
            shape: ShapesCollection.getShape[shape], style: style));
  }
}

enum Shape { heart }
class ShapeStyle {
  final Color color;

  ShapeStyle({this.color});
}

class ShapesCollection {
  static Path _heart = Path()
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
  _ShapeCustomPainter({this.shape, this.style});
  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;
    // var gradient = RadialGradient(
    //   center: const Alignment(0.7, -0.6),
    //   radius: 0.2,
    //   colors: [const Color(0xFFFFFF00), const Color(0xFF0099FF)],
    //   stops: [0.4, 1.0],
    // );
    // canvas.drawRect(
    //   rect,
    //   Paint()..shader = gradient.createShader(rect),
    // );
    final paint = Paint()..color = style.color;
    canvas.drawPath(shape, paint);
  }

  // Since this Sky painter has no fields, it always paints
  // the same thing and semantics information is the same.
  // Therefore we return false here. If we had fields (set
  // from the constructor) then we would return true if any
  // of them differed from the same fields on the oldDelegate.
  @override
  bool shouldRepaint(_ShapeCustomPainter oldDelegate) => false;
  @override
  bool shouldRebuildSemantics(_ShapeCustomPainter oldDelegate) => false;
}
