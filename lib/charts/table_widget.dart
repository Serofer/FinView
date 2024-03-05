import 'package:flutter/material.dart';
import 'package:fin_view/charts/data/table_data.dart';
import 'package:fin_view/categories.dart';


class TableWidget extends StatelessWidget {
    @override
    Widget build(BuildContext context) => DataTable(
        columns: [
            DataColumn(label: Text('Time'));
            //make this with .map over a category class
            //Categories.categories.map()
        ],
        
    );

}