import 'package:fin_view/charts/data/pie_data.dart';
import 'package:flutter/material.dart';
import 'package:fin_view/view_charts.dart';

Widget buildIndicator({
  required Color color,
  required String text,
  bool isSquare = false,
  double size = 16,
  Color textColor = const Color(0xff505050),
}) =>
    Row(children: <Widget>[
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
        ),
      ),
      const SizedBox(width: 8),
      Text(
        text,
        style: TextStyle(color: textColor, fontSize: 16),
      )
    ]);
