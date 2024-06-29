import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fin_view/charts/data/bar_data.dart';
import 'package:fin_view/charts//bar_titles.dart';
import 'package:fin_view/user_data/timeframe_manager.dart';


class BarChartWidget extends StatelessWidget {
  
  
  final double barWidth = 30;
  final double barHeight;
  final double groupSpace = 50; // Space between the bars

  BarChartWidget({super.key})
      : barHeight = BarData.barHeight; // Calculate barHeight based on max spent in timeframe§

  @override

  Widget bottomTitles(double value, TitleMeta meta) {
    String selectedTimeframe = TimeframeManager().selectedTimeframe;
    int groupedSections = TimeframeManager().groupedSections;
    int timeshift = TimeframeManager().timeshift;
    print(groupedSections.toString());
    print(timeshift.toString());
    int currentYear = DateTime.now().year;
    int index = value.toInt();

    Map<String, dynamic> labeling = {
      'Last 30 Days': 'Week',
      'This Month': 'Week',
      'Last 7 Days': 'Day',
      'This Year': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
      'All Time': ['Jan-Feb', 'Mar-Apr', 'May-Jun', 'Jul-Aug', 'Sep-Oct', 'Nov-Dec'],
    };

    const style = TextStyle(fontSize: 10);
    String text = "";  
    
    if (selectedTimeframe == 'This Year' || (selectedTimeframe == 'All Time' && groupedSections == 12)) {
        text = "${labeling['This Year'][index]}";
    }
    else if (selectedTimeframe == 'All Time') {
      if (groupedSections <= 36 && timeshift == 30) {//years <= 2 //problem with timeshift to be solved
         if (index < 12) {
          if (groupedSections == 24) {
            text = "${labeling['This Year'][index]} ${currentYear - 1}";
          }
          else {
            text = "${labeling['This Year'][index]} ${currentYear - 2}";
          }   
        }
        else if (index < 24) {
          if (groupedSections == 24) {
            text = "${labeling['This Year'][index - 12]} $currentYear";
          }
          else {
            text = "${labeling['This Year'][index - 12]} ${currentYear - 1}";
          }
        }
        else if (index < 36) {//only if 3 years (years = 2)          
          text = "${labeling['This Year'][index - 24]} $currentYear";
        }
      }
      else if (groupedSections <= 30 && timeshift == 60) {//every two months (years <= 4)
        if (index < 6) {
          if (groupedSections == 24) {
            text = "${labeling['All Time'][index]} ${currentYear - 3}";
          }
          else {
            text = "${labeling['All Time'][index]} ${currentYear - 4}";
          }       
        }
      else if (index < 12) {
        if (groupedSections == 24) {
          text = "${labeling['All Time'][index - 6]} ${currentYear - 2}";
          }
          else {
            text = "${labeling['All Time'][index - 6]} ${currentYear - 3}";
          }   
        }
        else if (index < 18) {
          if (groupedSections == 24) {
            text = "${labeling['All Time'][index - 12]} ${currentYear - 1}";
          }
          else {
            text = "${labeling['All Time'][index - 12]} ${currentYear - 2}";
          }
        }
        else if (index < 24) {
          if (groupedSections == 24) {
            text = "${labeling['All Time'][index - 18]} $currentYear";
          }
          else {
            text = "${labeling['All Time'][index - 18]} ${currentYear - 1}";
          }          
        }        
        else if (index < 30) {//only if 5 years (years = 4)
          text = "${labeling['All Time'][index - 24]} $currentYear";
        }
      }
      else if (timeshift == 365) {
          text = "${currentYear - (groupedSections - (index + 1))}";
      }
    }
    else {
      text =
          '${labeling[selectedTimeframe]} ${(index + 1).toString()}';//month: Week, 7 days: Day, Year: array with Months
    }
      
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
       child: Text(text, style: style,)
      );
  }
  Widget topTitles(double index, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: const Text('', style: style),
    );
  }
  Widget build(BuildContext context) {
  // Calculate total width required for the chart
  double totalWidth = (BarData.barData.length * (barWidth + groupSpace));

  // Ensure totalWidth is at least the width of the screen
  double screenWidth = MediaQuery.of(context).size.width;
  totalWidth = totalWidth < screenWidth ? screenWidth : totalWidth;

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: SizedBox(
      width: totalWidth,
      child: BarChart(
        BarChartData(
          maxY: barHeight,
          minY: 0,
          groupsSpace: groupSpace,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: bottomTitles,
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48, // Increased reserved size to prevent cutting off
                getTitlesWidget: topTitles,
              ),
            ),
          ),
          gridData: FlGridData(
            checkToShowHorizontalLine: (index) => index % BarData.interval == 0,
            getDrawingHorizontalLine: (index) {
              return const FlLine(
                color: Color(0xff2a7747),
                strokeWidth: 0.8,
              );
            },
          ),
          barGroups: BarData.barData
              .map(
                (data) => BarChartGroupData(
                  x: data.id,
                  barsSpace: 0,
                  barRods: data.rodData
                      .map(
                        (rodData) => BarChartRodData(
                          toY: rodData.barHeight,
                          //width: barWidth,
                          rodStackItems: rodData.rodItems
                              .map(
                                (rodItem) => BarChartRodStackItem(
                                    rodItem.minY,
                                    rodItem.maxY,
                                    rodItem.color),
                              )
                              .toList(),
                        ),
                      )
                      .toList(),
                ),
              )
              .toList(),
        ),
      ),
    ),
  );
}

}


