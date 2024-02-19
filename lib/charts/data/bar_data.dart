import 'package:flutter/material.dart';

class BarData {
    static int interval = 5;
    late List<dynamic> dataFromBase;
    static late List<Data> barData;
    String timeframe = "month"

    Future<void> createBarData(timeframe) async {
        dataFromBase = await SpentDatabase.instance.queryForBar();

        barData = [
            Data(
                id: 0,
                name: 'Mon',
                y: 15,
                color: Color(0xff19bfff),
            ),
        ];

    }
    //calculate each Data -> array with values: id, name, color...
    
}





class Data [
    final int id;
    final String name;
    final double y;
    final Color color;

    const Data({
        required this.id,
        required this.name,
        required this.y,
        required this.color,
    });
]