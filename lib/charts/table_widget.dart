import 'package:flutter/material.dart';
import 'package:fin_view/charts/data/table_data.dart';
import 'package:fin_view/categories.dart';

//work on this to display data

class TableWidget extends StatelessWidget {
  List categoriesExtra = ['Food', 'Event', 'Education', 'Other', 'Total'];
  @override
  Widget build(BuildContext context) => DataTable(
        columns: [
          DataColumn(
            label: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3),
              child: Text(
                'Time',
                style: const TextStyle(fontSize: 8),
              ),
            ),
          ),
          ...categoriesExtra.map(
            (category) => DataColumn(
              label: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  category,
                  style: const TextStyle(fontSize: 8),
                ),
              ),
            ),
          ),
          //make this with .map over a category class
          //Categories.categories.map()
        ],
        rows: DataForTable.tableData
            .map((data) => DataRow(cells: [
                  DataCell(
                    Text(data.time,
                        style: const TextStyle(
                          fontSize: 8,
                        )),
                  ),
                  ...categoriesExtra.map((category) {
                    final value = data.categoryData[category] ??
                        ''; // Get the value from categoryData map
                    return DataCell(Text(value.toString(),
                        style: const TextStyle(
                            fontSize: 8))); // Display the value in a DataCell
                  }),
                ]))
            .toList(),
      );
}
