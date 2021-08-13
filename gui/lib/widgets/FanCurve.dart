import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:myapp/model/FanConfig.dart';
import 'package:myapp/model/ProfileConfig.dart';

class FanCurve extends StatefulWidget {
  final ProfileConfig profile;

  FanCurve(this.profile, {Key? key}) : super(key: key);

  @override
  _FanCurveState createState() => _FanCurveState();
}

class _FanCurveState extends State<FanCurve> {
  String selection = "cpu";

  List<Color> gradientColors = [
    Colors.green[300]!,
    Colors.yellow,
    Colors.red[300]!,
  ];

  double getDataMinTemp() {
    double min = double.maxFinite;
    getData().forEach((list) {
      var res = list
          .reduce(
              (value, element) => value.temp < element.temp ? value : element)
          .temp
          .toDouble();
      if (res < min) min = res;
    });
    return min;
  }

  double getDataMaxTemp() {
    double max = 0;
    getData().forEach((list) {
      var res = list
          .reduce(
              (value, element) => value.temp > element.temp ? value : element)
          .temp
          .toDouble();
      if (res > max) max = res;
    });
    return max;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 300,
        child: Stack(
          children: [
            LineChart(LineChartData(
                gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                          color: Theme.of(context).dividerColor,
                          strokeWidth: 1);
                    },
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                          color: Theme.of(context).dividerColor,
                          strokeWidth: 1);
                    },
                    horizontalInterval: 25,
                    verticalInterval: 10),
                axisTitleData: FlAxisTitleData(
                    topTitle: AxisTitle(
                        showTitle: true,
                        textAlign: TextAlign.center,
                        textStyle: TextStyle(
                            fontSize: 19,
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.bold))),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTextStyles: (value) => TextStyle(
                        color: Theme.of(context).hintColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                    getTitles: (value) => value.toInt().toString() + "C",
                    interval: 10,
                    margin: 8,
                  ),
                  leftTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 18,
                    getTextStyles: (value) => TextStyle(
                        color: Theme.of(context).hintColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                    getTitles: (value) => value.toInt().toString() + "%",
                    interval: 25,
                    margin: 16,
                  ),
                ),
                borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                        color: Theme.of(context).dividerColor, width: 1)),
                minX: getDataMinTemp(),
                maxX: getDataMaxTemp(),
                minY: 0,
                maxY: 100,
                lineBarsData: getData()
                    .map((e) => LineChartBarData(
                        spots: e
                            .map((e) =>
                                FlSpot(e.temp.toDouble(), e.speed.toDouble()))
                            .toList(),
                        isCurved: true,
                        barWidth: 5,
                        colors: gradientColors,
                        colorStops: [0, 0.4, 1],
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          colors: gradientColors
                              .map((color) => color.withOpacity(0.2))
                              .toList(),
                        )))
                    .toList(),
                lineTouchData: LineTouchData(enabled: false))),
            Positioned(
                top: 28,
                left: 45,
                child: NeumorphicButton(
                  onPressed: () {
                    setState(() {
                      if (selection == "cpu")
                        selection = "gpu";
                      else if (selection == "gpu")
                        selection = "all";
                      else if (selection == "all") selection = "cpu";
                    });
                  },
                  child: Text(
                    this.selection,
                    style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  List<List<FanConfig>> getData() {
    if (selection == "cpu")
      return [widget.profile.ec.cpuFanConfig];
    else if (selection == "gpu")
      return [widget.profile.ec.gpuFanConfig];
    else
      return [widget.profile.ec.cpuFanConfig, widget.profile.ec.gpuFanConfig];
  }
}
