import 'package:flutter/material.dart';

class Shapes extends StatefulWidget {
  final Path path;
  final ShapeStyle style;
  final Widget child;
  final bool fill;
  final ShapeAnimation animation;
  const Shapes({this.path, this.style, this.child, this.fill, this.animation});

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
    if (widget.animation != null) {
      controller = AnimationController(
          duration: Duration(milliseconds: widget.animation.duration),
          vsync: this);
      final Animation<double> easeSelection =
          CurvedAnimation(parent: controller, curve: widget.animation.curve);

      //  Cubic ElasticInCurve ElasticInOutCurve ElasticOutCurve FlippedCurve Interval SawTooth Threshold
      animations[widget.animation.shapeTransforms](easeSelection);
      print('are we ere');
      controller.forward();
    }
  }

  @override
  void dispose() {
    if (controller != null) controller.dispose();
    super.dispose();
  }

  Widget rotate({Widget child}) =>
      Transform.rotate(angle: rotations.value, child: child);
  Widget scale({Widget child}) =>
      Transform.scale(scale: scales.value.dx, child: child);

  Widget translate({Widget child}) =>
      Transform.translate(offset: translations.value, child: child);

  Widget painter({Widget child}) => child;

  Widget scaleAndRotate({Widget child}) => scale(child: rotate(child: child));

  Widget scaleAndTranslate({Widget child}) =>
      scale(child: translate(child: child));

  Widget translateAndRotate({Widget child}) =>
      translate(child: rotate(child: child));

  Widget all({Widget child}) =>
      translate(child: rotate(child: scale(child: child)));

  Map<ShapeTransforms, Widget Function({Widget child})> get transformations =>
      <ShapeTransforms, Widget Function({Widget child})>{
        ShapeTransforms.none: painter,
        ShapeTransforms.onlyRotate: rotate,
        ShapeTransforms.onlyScale: scale,
        ShapeTransforms.onlyTranslate: translate,
        ShapeTransforms.scaleAndRotate: scaleAndRotate,
        ShapeTransforms.scaleAndTranslate: scaleAndTranslate,
        ShapeTransforms.translateAndRotate: translateAndRotate,
        ShapeTransforms.all: all
      };

  void doNothing(Animation<double> easeSelection) => print('hey');
  void mutateRotate(Animation<double> easeSelection) {
    rotations = widget.animation.rotateAnimation(easeSelection)
      ..addListener(() {
        setState(() {});
      });
  }

  void mutateScale(Animation<double> easeSelection) {
    scales = widget.animation.scaleAnimation(easeSelection)
      ..addListener(() {
        setState(() {});
      });
  }

  void mutateTranslate(Animation<double> easeSelection) {
    translations = widget.animation.translateAnimation(easeSelection)
      ..addListener(() {
        setState(() {});
      });
  }

  void mutateScaleAndRotate(Animation<double> easeSelection) {
    mutateScale(easeSelection);
    mutateRotate(easeSelection);
  }

  void mutateScaleAndTranslate(Animation<double> easeSelection) {
    mutateScale(easeSelection);
    mutateTranslate(easeSelection);
  }

  void mutateTranslateAndRotate(Animation<double> easeSelection) {
    mutateTranslate(easeSelection);
    mutateRotate(easeSelection);
  }

  void mutateAll(Animation<double> easeSelection) {
    mutateTranslate(easeSelection);
    mutateRotate(easeSelection);
    mutateScale(easeSelection);
  }

  Map<ShapeTransforms, void Function(Animation<double>)> get animations =>
      <ShapeTransforms, void Function(Animation<double>)>{
        ShapeTransforms.none: doNothing,
        ShapeTransforms.onlyRotate: mutateRotate,
        ShapeTransforms.onlyScale: mutateScale,
        ShapeTransforms.onlyTranslate: mutateTranslate,
        ShapeTransforms.scaleAndRotate: mutateScaleAndRotate,
        ShapeTransforms.scaleAndTranslate: mutateScaleAndTranslate,
        ShapeTransforms.translateAndRotate: mutateTranslateAndRotate,
        ShapeTransforms.all: mutateAll
      };

  @override
  Widget build(BuildContext context) {
    return _ShapeTransform(
        transformations: transformations,
        shapeTransforms: widget.animation != null
            ? widget.animation.shapeTransforms
            : ShapeTransforms.none,
        child: CustomPaint(
          size: Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height),
          painter: _ShapeCustomPainter(
              shape: widget.path, style: widget.style, fill: widget.fill),
          child: widget.child,
        ));
  }
}

class _ShapeTransform extends StatelessWidget {
  const _ShapeTransform({
    Key key,
    @required this.transformations,
    @required this.shapeTransforms,
    @required this.child,
  }) : super(key: key);

  final Map<ShapeTransforms, Widget Function({Widget child})> transformations;
  final ShapeTransforms shapeTransforms;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      transformations[shapeTransforms](child: child);
}

class ShapeStyle {
  final Color color;
  final Gradient gradient;
  final double shapeSize;

  const ShapeStyle({this.color, this.gradient, this.shapeSize});

  @override
  int get hashCode => hashValues(color, gradient, shapeSize);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShapeStyle &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          other.gradient == gradient &&
          shapeSize == other.shapeSize;
}

class ShapesCollection {
  const ShapesCollection();
  static Path heart() => Path()
    ..moveTo(75, 40)
    ..cubicTo(75, 37, 70, 25, 50, 25)
    ..cubicTo(20, 25, 20, 62.5, 20, 62.5)
    ..cubicTo(20, 80, 40, 102, 75, 120)
    ..cubicTo(110, 102, 130, 80, 130, 62.5)
    ..cubicTo(130, 62.5, 130, 25, 100, 25)
    ..cubicTo(85, 25, 75, 37, 75, 40)
    ..close();
}

class _ShapeCustomPainter extends CustomPainter {
  final Path shape;
  final ShapeStyle style;
  final bool fill;
  const _ShapeCustomPainter({
    this.shape,
    this.style,
    this.fill,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = style.gradient.createShader(Offset.zero & size)
      ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    final shapeWidth =shape.getBounds().size.width;
    final scale = style.shapeSize != null
        ? style.shapeSize / shapeWidth
        : size.width / shapeWidth;
    canvas.drawPath(shape.center(size).scale(scale), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShapeCustomPainter oldDelegate) => false;
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

enum ShapeTransforms {
  onlyRotate,
  onlyScale,
  onlyTranslate,
  scaleAndRotate,
  scaleAndTranslate,
  translateAndRotate,
  all,
  none
}

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

  ShapeTransforms get shapeTransforms {
    if (canTranslate & canRotate & canScale) {
      return ShapeTransforms.all;
    }

    if (canTranslate & canRotate) {
      return ShapeTransforms.translateAndRotate;
    }

    if (canScale & canTranslate) {
      return ShapeTransforms.scaleAndTranslate;
    }
    if (canScale & canRotate) {
      return ShapeTransforms.scaleAndRotate;
    }
    if (canScale) {
      return ShapeTransforms.onlyScale;
    }
    if (canRotate) {
      return ShapeTransforms.onlyRotate;
    }
    if (canTranslate) {
      return ShapeTransforms.onlyTranslate;
    }
    return ShapeTransforms.none;
  }

  bool get canScale => keyframes.whereType<ScaleKeyframe>().isNotEmpty;
  bool get canTranslate => keyframes.whereType<TranslateKeyframe>().isNotEmpty;
  bool get canRotate => keyframes.whereType<RotateKeyframe>().isNotEmpty;

  Animation<Offset> translateAnimation(Animation<double> easeSelection) =>
      TweenSequence<Offset>(keyframes
              .whereType<TranslateKeyframe>()
              .map((keyframe) => TweenSequenceItem(
                  weight: keyframe.weight,
                  tween: Tween(
                      begin: Offset(0, 0),
                      end: Offset(keyframe.x, keyframe.y))))
              .toList())
          .animate(easeSelection);

  Animation<Offset> scaleAnimation(Animation<double> easeSelection) =>
      TweenSequence<Offset>(keyframes
              .whereType<ScaleKeyframe>()
              .map((keyframe) => TweenSequenceItem(
                  weight: keyframe.weight,
                  tween: Tween(
                      begin: Offset(0, 0),
                      end: Offset(keyframe.x, keyframe.y))))
              .toList())
          .animate(easeSelection);

  Animation<double> rotateAnimation(Animation<double> easeSelection) =>
      TweenSequence<double>(keyframes
              .whereType<RotateKeyframe>()
              .map((keyframe) => TweenSequenceItem(
                  weight: keyframe.weight,
                  tween: Tween(begin: 0.0, end: keyframe.angle)))
              .toList())
          .animate(easeSelection);

  @override
  int get hashCode => hashValues(id, keyframes, duration, curve);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShapeAnimation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          duration == other.duration &&
          keyframes == other.keyframes &&
          curve == other.curve;
}

class TranslateKeyframe extends Keyframe {
  const TranslateKeyframe(
      {int step, double x, double y, String cy, String easing, double weight})
      : super(step: step, x: x, y: y, cy: cy, easing: easing, weight: weight);
}

class ScaleKeyframe extends Keyframe {
  const ScaleKeyframe(
      {int step, double sx, double sy, String cy, String easing, double weight})
      : super(step: step, x: sx, y: sy, cy: cy, easing: easing, weight: weight);
}

class RotateKeyframe extends Keyframe {
  final double angle;

  const RotateKeyframe(
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

  const Keyframe(
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

  @override
  int get hashCode => hashValues(step, x, cy, easing, weight);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Keyframe &&
          runtimeType == other.runtimeType &&
          step == other.step &&
          x == other.x &&
          cy == other.cy &&
          easing == other.easing &&
          weight == other.weight;
}
