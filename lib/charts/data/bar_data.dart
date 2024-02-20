import 'package:flutter/material.dart';

class BarData {
    static int interval = 10; //change according to max bar
    late List<dynamic> dataFromBase;
    static late List<Data> barData;
    String timeframe = "month";

    Future<void> createBarData(timeframe) async {
        dataFromBase = await SpentDatabase.instance.queryForBar();

        barData = queryForBar();

    }
    //calculate each Data -> array with values: id, name, color...
    
}





class Data [
    final int id;
    final String name;
    final double y;
    final Color color;

    const bar_Data({
        required this.id,
        required this.name,
        required this.y,
        required this.color,
    });
]