import 'package:flutter/material.dart';
import 'package:fin_view/charts/data/table_data.dart';

//work on this to display data

class TableWidget extends StatelessWidget {
  List categoriesExtra = ['Food', 'Event', 'Education', 'Other', 'Total'];

  TableWidget({super.key});
  @override
  Widget build(BuildContext context) => DataTable(
        columns: [
          const DataColumn(
            label: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3),
              child: Text(
                'Time',
                style: TextStyle(fontSize: 8),
              ),
            ),
          ),
          ...categoriesExtra.map(
            (category) => DataColumn(
              label: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
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
