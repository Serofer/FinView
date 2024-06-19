import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fin_view/charts/data/bar_data.dart';
import 'package:fin_view/charts//bar_titles.dart';
import 'package:fin_view/user_data/timeframe_manager.dart';


class BarChartWidget extends StatelessWidget {
  
  
  final double barWidth = 30;
  final double barHeight;
  final double groupSpace = 22; // Space between the bars

  BarChartWidget({super.key})
      : barHeight = BarData.barHeight; // Calculate barHeight based on max spent in timeframe§

  @override

  Widget bottomTitles(double value, TitleMeta meta) {
    String selectedTimeframe = TimeframeManager().selectedTimeframe;
    const style = TextStyle(fontSize: 10);
    String text;
    if (selectedTimeframe == 'This Year' || selectedTimeframe == 'All Time') {
      switch (value.toInt())  {
      case 0:
        text = 'Jan';
        break;
      case 1:
        text = 'Feb';
        break;
      case 2:
        text = 'Mar';
        break;
      case 3:
        text = 'Apr';
        break;
      case 4:
        text = 'May';
        break;
      case 5:
        text = 'Jun';
        break;
      case 6:
        text = 'Jul';
        break;
      case 7:
        text = 'Aug';
        break;
      case 8:
        text = 'Sep';
        break;
      case 9:
        text = 'Oct';
        break;
      case 10:
        text = 'Nov';
        break;
      case 11:
        text = 'Dec';
        break;
      default:
        text = 'lol';
        break;
    }
    } else if (selectedTimeframe == 'This Month' || selectedTimeframe == 'Last 30 Days') {
      switch (value.toInt())  {
      case 0:
        text = 'Week 1';
        break;
      case 1:
        text = 'Week 2';
        break;
      case 2:
        text = 'Week 3';
        break;
      case 3:
        text = 'Week 4';
        break;
      case 4:
        text = 'Week 5';
        break;
      case 5:
        text = 'Week 6';
        break;
      case 6:
        text = 'Week 7';
        break;
      case 7:
        text = 'Week 8';
        break;
      default:
        text = 'lol';
        break;
      }
    }
    else if (selectedTimeframe == 'Last 7 Days') {
      switch (value.toInt())  {
      case 0:
        text = 'Day 1';
        break;
      case 1:
        text = 'Day 2';
        break;
      case 2:
        text = 'Day 3';
        break;
      case 3:
        text = 'Day 4';
        break;
      case 4:
        text = 'Day 5';
        break;
      case 5:
        text = 'Day 6';
        break;
      case 6:
        text = 'Day 7';
        break;
      case 7:
        text = 'Day 8';
        break;
      default:
        text = 'lol';
        break;
      }
    }
    else {
      text = value.toInt().toString();
    }
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
       child: Text(text, style: style,)
      );
  }
  Widget topTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text('', style: style),
    );
  }
  Widget build(BuildContext context) {
    // Calculate total width required for the chart
    // Calculate total width required for the chart
    double totalWidth = (BarData.barData.length * (barWidth + groupSpace));
    
    // Ensure totalWidth is at least the width of the screen
    double screenWidth = MediaQuery.of(context).size.width;
    totalWidth = totalWidth < screenWidth ? screenWidth : totalWidth;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
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
              topTitles:  AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: topTitles,
                      ),
                  ), 
            ),
            
            gridData: FlGridData(
              checkToShowHorizontalLine: (value) => value % BarData.interval == 0,
              getDrawingHorizontalLine: (value) {
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


