import 'package:flutter/material.dart';
import 'package:fin_view/db/spent_database.dart';
import 'package:fin_view/model/spent.dart';

class PieData {
  //add logit to which timespan was given

  Future<List<dynamic>> calculatePercentages() async {
    List categories = ['Food', 'Event', 'Education', 'Other'];
    List percentages = [];
    late List<Expenditure> expenses;
    expenses = await SpentDatabase.instance.readAllExpenditure();
    for (int i = 0; i < categories.length; i++) {
      List<dynamic> spentOnCat =
          await SpentDatabase.instance.readCategory(categories[i]);
      double spentCat = spentOnCat[0];
      List countAll = await SpentDatabase.instance.readAmount();
      double totAmount = countAll[0];
      double toAdd = (spentCat / totAmount) * 100;
      percentages.add(toAdd);
    }

    print(percentages);

    List<Data> data = [
      Data(name: 'Food', percent: percentages[0], color: Color(0xff0293ee)),
      Data(name: 'Event', percent: percentages[1], color: Color(0xfff8b250)),
      Data(
          name: 'Education', percent: percentages[2], color: Color(0xff845bef)),
      Data(name: 'Other', percent: percentages[3], color: Color(0xff13d38e)),
    ];

    return data;
  }

  createData() async {
    List<dynamic> data = await PieData().calculatePercentages();
    return data;
  }

  static List<Data> data = PieData().createData();
}

class Data {
  final String name;
  final double percent;
  final Color color;

  Data({required this.name, required this.percent, required this.color});
}
