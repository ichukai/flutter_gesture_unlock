import 'package:flutter/material.dart';
import 'package:flutter_gesture_unlock/unlock_point.dart';

import 'gesture_unlock_view.dart';

class GestureUnlockIndicator extends StatefulWidget {
  ///控件大小
  final double? size;

  ///圆之间的间距
  final double? roundSpace;

  ///圆之间的间距比例(以圆直径作为基准)，[roundSpace]设置时无效
  final double roundSpaceRatio;

  ///线宽度
  final double strokeWidth;

  ///默认颜色
  final Color defaultColor;

  ///选中颜色
  final Color selectedColor;

  final _GestureUnlockIndicatorState _state = _GestureUnlockIndicatorState();

  GestureUnlockIndicator(
      {this.size,
      this.roundSpace,
      this.roundSpaceRatio = 0.5,
      this.strokeWidth = 1,
      this.defaultColor = Colors.grey,
      this.selectedColor = Colors.blue});

  void setSelectPoint(List<int> selected) {
    _state.setSelectPoint(selected);
  }

  @override
  _GestureUnlockIndicatorState createState() {
    return _state;
  }
}

class _GestureUnlockIndicatorState extends State<GestureUnlockIndicator> {
  List<UnlockPoint> _rounds =
      List.generate(9, (index) => UnlockPoint(x: 0, y: 0, position: 0));
  double? _radius;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        size: Size(widget.size!, widget.size!),
        painter: LockPatternIndicatorPainter(
          _rounds,
          _radius,
          widget.strokeWidth,
          widget.defaultColor,
          widget.selectedColor,
        ));
  }

  void setSelectPoint(List<int> selected) {
    for (int i = 0; i < _rounds.length; i++) {
      _rounds[i]!.status =
          selected.contains(i) ? UnlockStatus.success : UnlockStatus.normal;
    }
  }

  void _init() {
    var width = widget.size;
    var roundSpace = widget.roundSpace;
    if (roundSpace != null) {
      _radius = (width! - roundSpace * 2) / 3 / 2;
    } else {
      _radius = width! / (3 + widget.roundSpaceRatio * 2) / 2;
      roundSpace = _radius! * 2 * widget.roundSpaceRatio;
    }

    for (int i = 0; i < _rounds.length; i++) {
      var row = i ~/ 3;
      var column = i % 3;
      var dx = column * (_radius! * 2 + roundSpace) + _radius!;
      var dy = row * (_radius! * 2 + roundSpace) + _radius!;
      _rounds[i] = UnlockPoint(x: dx, y: dy, position: i);
    }
    setState(() {});
  }
}

class LockPatternIndicatorPainter extends CustomPainter {
  List<UnlockPoint?> _rounds;
  double? _radius;
  double _strokeWidth;
  Color _defaultColor;
  Color _selectedColor;

  LockPatternIndicatorPainter(this._rounds, this._radius, this._strokeWidth,
      this._defaultColor, this._selectedColor);

  @override
  void paint(Canvas canvas, Size size) {
    if (_radius == null) return;

    var paint = Paint();
    paint.strokeWidth = _strokeWidth;

    for (var round in _rounds) {
      switch (round!.status) {
        case UnlockStatus.normal:
          paint.style = PaintingStyle.fill;
          paint.color = _defaultColor;
          canvas.drawCircle(round.toOffset(), _radius!, paint);
          break;
        case UnlockStatus.success:
          paint.style = PaintingStyle.fill;
          paint.color = _selectedColor;
          canvas.drawCircle(round.toOffset(), _radius!, paint);
          break;
        default:
          break;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
