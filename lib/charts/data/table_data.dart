import 'package:flutter/material.dart';

class TableData {
    //change dynamically on user decision
    final String time;
    final double food;
    final double event;
    final double education;
    final double other;

    const TableData({
        required this.time,
        this.food,
        this.event,
        this.education,
        this.other,
    });

}