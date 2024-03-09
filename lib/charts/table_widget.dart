import 'package:flutter/material.dart';
import 'package:fin_view/charts/data/table_data.dart';
import 'package:fin_view/categories.dart';
//work on this to display data

class TableWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => DataTable(
        columns: [
          DataColumn(label: Text('Time')),
          DataColumn(
            label: Text('Category'),
          )
          //make this with .map over a category class
          //Categories.categories.map()
        ],
        rows: [
          DataRow(cells: [
            DataCell(Text('Monday')),
            DataCell(Text('Food')),
          ]),
        ],
      );
}
