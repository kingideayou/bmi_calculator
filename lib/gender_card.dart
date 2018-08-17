import 'dart:math' as math;

import 'package:bmi_calculator/card_title.dart';
import 'package:bmi_calculator/gender.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GenderCard extends StatefulWidget {
  final Gender initialGender;

  const GenderCard({Key key, this.initialGender}) : super(key: key);

  @override
  _GenderCardState createState() => _GenderCardState();
}

const double _defaultGenderAngle = math.pi / 4;
const Map<Gender, double> _genderAngles = {
  Gender.female: -_defaultGenderAngle,
  Gender.other: 0.0,
  Gender.male: _defaultGenderAngle,
};
const double _circleSize = 80.0;

class _GenderCardState extends State<GenderCard>
    with SingleTickerProviderStateMixin {
  AnimationController _arrowAnimationController;
  Gender selectedGender;

  @override
  void initState() {
    selectedGender = widget.initialGender ?? Gender.other;
    _arrowAnimationController = new AnimationController(
      vsync: this,
      lowerBound: -_defaultGenderAngle,
      upperBound: _defaultGenderAngle,
      value: _genderAngles[selectedGender],
    );
    super.initState();
  }

  @override
  void dispose() {
    _arrowAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CardTitle("GENDER"),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: _drawMainStack(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawMainStack() {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          _drawCircleIndicator(),
          GenderIconTranslated(gender: Gender.female),
          GenderIconTranslated(gender: Gender.other),
          GenderIconTranslated(gender: Gender.male),
          _drawGestureDetector(),
        ],
      ),
    );
  }

  Widget _drawCircleIndicator() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        GenderCircle(),
        GenderArrow(listenable: _arrowAnimationController),
      ],
    );
  }

  _drawGestureDetector() {
    return Positioned.fill(
      child: TapHandler(
        onGenderTapped: _setSelectedGender,
      ),
    );
  }

  void _setSelectedGender(Gender gender) {
    setState(() => selectedGender = gender);
    _arrowAnimationController.animateTo(_genderAngles[gender],
        duration: Duration(milliseconds: 150));
  }
}

class GenderIconTranslated extends StatelessWidget {
  static final Map<Gender, String> _genderImages = {
    Gender.female: "images/gender_female.svg",
    Gender.other: "images/gender_other.svg",
    Gender.male: "images/gender_male.svg",
  };

  final Gender gender;

  const GenderIconTranslated({Key key, this.gender}) : super(key: key);

  bool get _isOtherGender => gender == Gender.other;

  String get _assetName => _genderImages[gender];

  double get _iconSize => _isOtherGender ? 22.0 : 16.0;

  double get _genderLeftPadding => _isOtherGender ? 8.0 : 0.0;

  @override
  Widget build(BuildContext context) {
    Widget icon = Padding(
      padding: EdgeInsets.only(left: _genderLeftPadding),
      child: SvgPicture.asset(
        _assetName,
        height: _iconSize,
        width: _iconSize,
      ),
    );

    Widget rotatedIcon = Transform.rotate(
      angle: -_genderAngles[gender],
      child: icon,
    );

    Widget iconWithALine = Padding(
      padding: EdgeInsets.only(bottom: _circleSize / 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          rotatedIcon,
          GenderLine(),
        ],
      ),
    );

    Widget rotatedIconWithALine = Transform.rotate(
      alignment: Alignment.bottomCenter,
      angle: _genderAngles[gender],
      child: iconWithALine,
    );

    Widget centeredIconWithALine = Padding(
      padding: EdgeInsets.only(bottom: _circleSize / 2),
      child: rotatedIconWithALine,
    );

    return centeredIconWithALine;
  }
}

class GenderArrow extends AnimatedWidget {
  static final double _arrowLength = 32.0;
  static final double _translationOffset = _arrowLength * -0.4;

  const GenderArrow({Key key, Listenable listenable})
      : super(key: key, listenable: listenable);

  @override
  Widget build(BuildContext context) {
    Animation animation = listenable;
    return Transform.rotate(
      angle: animation.value,
      alignment: Alignment(0.0, 0.0),
      child: Transform.translate(
        offset: Offset(0.0, _translationOffset),
        child: Transform.rotate(
          angle: -_defaultGenderAngle,
          child: SvgPicture.asset(
            "images/gender_arrow.svg",
            height: _arrowLength,
            width: _arrowLength,
          ),
        ),
      ),
    );
  }
}

class TapHandler extends StatelessWidget {
  final Function(Gender) onGenderTapped;

  const TapHandler({Key key, this.onGenderTapped}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
            child: GestureDetector(onTap: () => onGenderTapped(Gender.female))),
        Expanded(
            child: GestureDetector(onTap: () => onGenderTapped(Gender.other))),
        Expanded(
            child: GestureDetector(onTap: () => onGenderTapped(Gender.male))),
      ],
    );
  }
}

class GenderCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: _circleSize,
      height: _circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromRGBO(244, 244, 244, 1.0),
      ),
    );
  }
}

class GenderLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, top: 8.0),
      child: Container(
        height: 8.0,
        width: 1.0,
        color: Color.fromRGBO(216, 217, 223, 0.36),
      ),
    );
  }
}