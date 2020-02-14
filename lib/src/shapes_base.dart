import 'package:flutter/material.dart';

class Shapes extends StatefulWidget {
  final Shape shape;
  final ShapeStyle style;
  final Widget child;
  final bool fill;
  final ShapeAnimation animation;
  Shapes({this.shape, this.style, this.child, this.fill, this.animation});

  @override
  _ShapesState createState() => _ShapesState();
}

class _ShapesState extends State<Shapes> with SingleTickerProviderStateMixin {
  Animation<Offset> translations;
  Animation<Offset> scales;
  Animation<double> rotations;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: Duration(milliseconds: widget.animation.duration),
        vsync: this);
    final Animation<double> easeSelection =
        CurvedAnimation(parent: controller, curve: widget.animation.curve);

    //  Cubic ElasticInCurve ElasticInOutCurve ElasticOutCurve FlippedCurve Interval SawTooth Threshold

    translations = TweenSequence<Offset>([...widget.animation.translations()])
        .animate(easeSelection)
          ..addListener(() {
            setState(() {});
          });
    scales = TweenSequence<Offset>([...widget.animation.scales()])
        .animate(easeSelection) //TODO : move this in Scaleanimation
          ..addListener(() {
            setState(() {});
          });
    rotations = TweenSequence<double>([...widget.animation.rotations()])
        .animate(easeSelection)
          ..addListener(() {
            setState(() {});
          });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height),
      painter: _ShapeCustomPainter(
          shape: ShapesCollection.getShape[widget.shape],
          scaleProgress: scales.value,
          translationProgress: translations.value,
          rotationProgress: rotations.value,
          style: widget.style,
          fill: widget.fill),
      child: widget.child ?? widget.child,
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
  final Offset scaleProgress;
  final double rotationProgress;
  final Offset translationProgress;
  _ShapeCustomPainter(
      {this.shape,
      this.style,
      this.fill,
      this.scaleProgress,
      this.rotationProgress,
      this.translationProgress});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = style.gradient.createShader(Offset.zero & size)
      ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    final scale = style.shapeSize / shape.getBounds().size.width;
    canvas.scale(scaleProgress.dx);
    canvas.translate(translationProgress.dx, translationProgress.dy);
    canvas.rotate(rotationProgress);
    canvas.drawPath(shape.center(size).scale(scale), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShapeCustomPainter oldDelegate) =>
      oldDelegate.scaleProgress != scaleProgress;
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

// class Timeline {
//   final List<ShapeAnimation> animations;

//   Timeline({
//     @required this.animations,
//   });

//   factory Timeline.fromJson(Map<String, dynamic> json) => Timeline(
//         animations: List<ShapeAnimation>.from(
//             json["animations"].map((x) => ShapeAnimation.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "animations": List<dynamic>.from(animations.map((x) => x.toJson())),
//       };
// }

class ShapeAnimation {
  final String id;
  final List<Keyframe> keyframes;
  final int duration;
  final Curve curve;

  const ShapeAnimation({
    this.id,
    @required this.keyframes,
    this.duration,
    this.curve,
  });
  factory ShapeAnimation.fromJson(Map<String, dynamic> json) => ShapeAnimation(
        id: json["id"],
        keyframes: List<Keyframe>.from(
            json["animations"].map((x) => Keyframe.fromJson(x))),
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "keyframes": List<dynamic>.from(keyframes.map((x) => x.toJson())),
      };

  List<TweenSequenceItem<Offset>> translations() => keyframes
      .whereType<TranslateKeyframe>()
      .map((keyframe) => TweenSequenceItem(
          weight: keyframe.weight,
          tween:
              Tween(begin: Offset(0, 0), end: Offset(keyframe.x, keyframe.y))))
      .toList();

  List<TweenSequenceItem<Offset>> scales() => keyframes
      .whereType<ScaleKeyframe>()
      .map((keyframe) => TweenSequenceItem(
          weight: keyframe.weight,
          tween:
              Tween(begin: Offset(0, 0), end: Offset(keyframe.x, keyframe.y))))
      .toList();

  List<TweenSequenceItem<double>> rotations() => keyframes
      .whereType<RotateKeyframe>()
      .map((keyframe) => TweenSequenceItem(
          weight: keyframe.weight,
          tween: Tween(begin: 0.0, end: keyframe.angle)))
      .toList();
}

class TranslateKeyframe extends Keyframe {
  TranslateKeyframe(
      {int step, double x, double y, String cy, String easing, double weight})
      : super(step: step, x: x, y: y, cy: cy, easing: easing, weight: weight);
}

class ScaleKeyframe extends Keyframe {
  ScaleKeyframe(
      {int step, double sx, double sy, String cy, String easing, double weight})
      : super(step: step, x: sx, y: sy, cy: cy, easing: easing, weight: weight);
}

class RotateKeyframe extends Keyframe {
  final double angle;

  RotateKeyframe(
      {int step, @required this.angle, String cy, String easing, double weight})
      : super(step: step, cy: cy, easing: easing, weight: weight);

  factory RotateKeyframe.fromJson(Map<String, dynamic> json) => RotateKeyframe(
        step: json["step"] == null ? null : json["step"],
        angle: json["angle"] == null ? null : json["angle"],
        cy: json["cy"] == null ? null : json["cy"],
        easing: json["easing"] == null ? null : json["easing"],
      );

  Map<String, dynamic> toJson() => {
        "step": step == null ? null : step,
        "angle": angle == null ? null : angle,
        "cy": cy == null ? null : cy,
        "easing": easing == null ? null : easing,
      };
}

class Keyframe {
  final int step;
  final double x;
  final double y;
  final String cy;
  final String easing;
  final double weight; //TODO: to json

  Keyframe(
      {@required this.step,
      this.x,
      this.y,
      @required this.cy,
      @required this.easing,
      @required this.weight});

  factory Keyframe.fromJson(Map<String, dynamic> json) => Keyframe(
        step: json["step"] == null ? null : json["step"],
        x: json["x"] == null ? null : json["x"],
        y: json["y"] == null ? null : json["y"],
        cy: json["cy"] == null ? null : json["cy"],
        easing: json["easing"] == null ? null : json["easing"],
      );

  Map<String, dynamic> toJson() => {
        "step": step == null ? null : step,
        "x": x == null ? null : x,
        "y": y == null ? null : y,
        "cy": cy == null ? null : cy,
        "easing": easing == null ? null : easing,
      };
}
