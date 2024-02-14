import 'package:flutter/material.dart';
import 'package:fin_view/db/spent_database.dart';
import 'package:fin_view/model/spent.dart';
/*
class PieData {
    final db = await instance.database;

    List categories = ['Food', 'Event', 'Education', 'Other'];
    List percentages = [];
    //add logit to which timespan was given
    final result = await db.query(tableExpenditure, orderBy: '${ExpenditureFields.date} ASC');

    for (int i = 0; i < categories.length; i++)
    {
        int countCat = await db.rawQuery("SELECT COUNT(_id) FROM expenditure WHERE category = '$categories[i]'");
        int countAll = await db.rawQuery("SELECT COUNT(_id) FROM expenditure");
        int percentages[i] = (countCat / countAll) * 100; 
    }
    print(result);
    print(percentages)

    static List<Data> data = [
        Data(name: 'Food', percent: percentages[0], color: const Colors.blue),
        Data(name: 'Event', percent: percentages[1], color: const Colors.red),
        Data(name: 'Education', percent: percentages[2], color: const Colors.black),
        Data(name: 'Other', percent: percentages[3], color: const Colors.green),
    ];

}

class Data {
    final String name;
    final double percent;
    final Color color;

    Data({this.name, this.percent, this.color});
}*/