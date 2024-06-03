import 'package:flutter/material.dart';

Widget buildIndicator({
  required Color color,
  required String text,
  bool isSquare = true,
  double size = 16,
  Color textColor = const Color(0xff505050),
}) =>
    Row(children: <Widget>[
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
          color: color,
        ),
      ),
      const SizedBox(width: 8),
      Text(
        text,
        style: TextStyle(color: textColor, fontSize: 16),
      )
    ]);
