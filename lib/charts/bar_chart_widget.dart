import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fin_view/charts/data/bar_data.dart';
import 'package:fin_view/charts//bar_titles.dart';


class BarChartWidget extends StatelessWidget {
  
  
  final double barWidth = 30;
  final double barHeight;
  final double groupSpace = 22; // Space between the bars

  BarChartWidget({super.key})
      : barHeight = BarData.barHeight; // Calculate barHeight based on max spent in timeframe

  @override

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    String text;
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
            /*titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: BarTitles.getBottomTitles(),    
                    ),
                ),
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: BarTitles.getleftTitles(),
                    ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: const SideTitles(
                        showTitles: false,
                    ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: const SideTitles(
                    showTitles: false,
                  ),
                )
            ),*/
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


