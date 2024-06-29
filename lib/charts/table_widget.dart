import 'package:flutter/material.dart';
import 'package:fin_view/charts/data/table_data.dart';

class TableWidget extends StatelessWidget {
  final List<String> categoriesExtra = ['Food', 'Event', 'Education', 'Other', 'Total'];

  TableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rowsHeight = DataForTable.tableData.length * 48.0; // 48.0 is the height of each DataRow
        final tableHeight = rowsHeight + 56.0; // Adding height for the headers

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
              minHeight: tableHeight,
            ),
            child: IntrinsicHeight(
              child: DataTable(
                columnSpacing: 30,
                columns: [
                  const DataColumn(
                    label: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        'Time',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                            fontSize: category == 'Total' ? 20 : 18,
                            fontWeight: category == 'Total' ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                rows: DataForTable.tableData.map((data) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          data.time,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: data.time == 'All' ? FontWeight.bold: FontWeight.normal,
                            ),
                        ),
                      ),
                      ...categoriesExtra.map((category) {
                        final value = data.categoryData[category] ?? 0.0;
                        return DataCell(
                          Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Colors.grey),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                value.toString(),
                                style: TextStyle(
                                  fontSize: category == 'Total' ? 20 : 18,
                                  fontWeight: category == 'Total' ? FontWeight.bold : FontWeight.normal,
                                  color: data.time == 'All'
                                    ? Colors.blue
                                    : value == 0.0
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}


