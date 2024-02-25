import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fin_view/charts/data/bar_data.dart';
import 'package:fin_view/charts/bar_titles.dart';

class BarChartWidget extends StatelessWidget {
  final double barWidth = 22;
  final double barHeight =
      100; //calculate barHeight based on max spent in timeframe
  final double groupSpace = 12; //is the space between the bars

  @override
  Widget build(BuildContext context) => BarChart(
        BarChartData(
            //alignment: BarChartAlignment.center,
            maxY: barHeight,
            minY: 0,
            groupsSpace: groupSpace,
            barTouchData: BarTouchData(enabled: true),
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
              checkToShowHorizontalLine: (value) =>
                  value % BarData.interval == 0,
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  color: Color(0xff2a7747),
                  strokeWidth: 0.8,
                );
              },
            ),

            /*barData has this format: barData = [{id: x, BarChartRodData: [{
                            barHeight: barHeight, rodStackItems: [{minY: value, maxY: value, color: widget.normal}, {...}]
                            ],
                        },
                    },
                ]
                
                Code test:*/
            barGroups: BarData.barData
                .map(
                  (data) => BarChartGroupData(
                    x: data.id,
                    barsSpace: 0,
                    barRods: data.rodData
                        .map(
                          (rodData) => BarChartRodData(
                            toY: rodData.barHeight,
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
                .toList()),

        /*barGroups: BarData.barData
                .map(
                  (data) => BarChartGroupData(
                    x: data.id,
                    barRods: [
                      //map again over every inner list

                      BarChartRodData(
                        toY: data.y,
                        width: barWidth,
                        color: data.color,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                )
                .toList()),*/
      );
}
