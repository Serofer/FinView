import 'package:flutter/material.dart';
import 'package:fin_view/charts/data/table_data.dart';

//work on this to display data

import 'package:flutter/material.dart';

class TableWidget extends StatelessWidget {
  final List<String> categoriesExtra = ['Food', 'Event', 'Education', 'Other', 'Total'];

  TableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rowsHeight = DataForTable.tableData.length * 48.0; // 48.0 is the height of each DataRow
        final tableHeight = rowsHeight + 56.0; // Adding height for the headers

        return SizedBox(
          height: tableHeight,
          child: DataTable(
            columnSpacing: 30,
            columns: [
              DataColumn(
                label: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    'Time',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ...categoriesExtra.map(
                (category) => DataColumn(
                  label: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: category == 'Total' ? 16 : 14,
                        fontWeight: category == 'Total' ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            rows: DataForTable.tableData
                .map(
                  (data) => DataRow(
                    cells: [
                      DataCell(
                        Text(
                          data.time,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      ...categoriesExtra.map(
                        (category) {
                          final value = data.categoryData[category] ?? '';
                          return DataCell(
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: Colors.grey),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Text(
                                  value.toString(),
                                  style: TextStyle(
                                    fontSize: category == 'Total' ? 16 : 14,
                                    fontWeight: category == 'Total' ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
