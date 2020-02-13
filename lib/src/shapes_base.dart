import 'package:flutter/material.dart';

class Shapes extends StatelessWidget {
  final Shape shape;
  final ShapeStyle style;
  final Widget child;
  Shapes({this.shape, this.style, this.child});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShapeCustomPainter(
          shape: ShapesCollection.getShape[shape], style: style),
      child: child ?? child,
    );
  }
}

enum Shape { heart }

class ShapeStyle {
  final Color color;

  ShapeStyle({this.color});
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
  _ShapeCustomPainter({this.shape, this.style});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = style.color;
    canvas.translate(size.width / 2, size.height / 2);
    canvas.drawPath(shape.center(size), paint);
  }

  @override
  bool shouldRepaint(_ShapeCustomPainter oldDelegate) => false;
  @override
  bool shouldRebuildSemantics(_ShapeCustomPainter oldDelegate) => false;
}

extension PathOperations on Path {
  Path center(Size size) {
    final bbox = getBounds();
    final pathRect = Offset(bbox.center.dx, bbox.center.dy) & size;

    return shift(Offset(-pathRect.centerLeft.dx, -pathRect.topCenter.dy));
  }
}
