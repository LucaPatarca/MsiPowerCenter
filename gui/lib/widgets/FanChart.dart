import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:myapp/model/FanConfig.dart';
import 'package:myapp/model/ProfileConfig.dart';
import 'package:myapp/provider/ConfigProvider.dart';
import 'package:myapp/provider/RealTimeInfoProvider.dart';
import 'package:provider/provider.dart';

class FanChart extends StatelessWidget {
  final List<Color> gradientColors = [
    Colors.green[300]!,
    Colors.yellow,
    Colors.red[300]!,
  ];
  final ProfileConfig profile;
  final String selection;

  FanChart(
      {this.profile = const ProfileConfig.empty(),
      this.selection = "cpu",
      Key? key})
      : super(key: key);

  double getDataMinTemp() {
    double min = double.maxFinite;
    getRawData().forEach((list) {
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
    getRawData().forEach((list) {
      var res = list
          .reduce(
              (value, element) => value.temp > element.temp ? value : element)
          .temp
          .toDouble();
      if (res > max) max = res;
    });
    return max;
  }

  List<List<FanConfig>> getRawData() {
    if (selection == "cpu")
      return [profile.ec.cpuFanConfig];
    else if (selection == "gpu")
      return [profile.ec.gpuFanConfig];
    else
      return [profile.ec.cpuFanConfig, profile.ec.gpuFanConfig];
  }

  List<LineChartBarData> getDataWidget(BuildContext context) {
    var data = getRawData()
        .map(
          (e) => LineChartBarData(
            spots: e
                .map((e) => FlSpot(e.temp.toDouble(), e.speed.toDouble()))
                .toList(),
            isCurved: true,
            barWidth: 5,
            gradient: LinearGradient(colors: gradientColors),
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: gradientColors
                    .map((color) => color.withOpacity(0.2))
                    .toList(),
              ),
            ),
          ),
        )
        .toList();
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(48.0, 16.0, 16.0, 32.0),
      child: SizedBox(
        height: 300,
        child: Stack(
          children: [
            LineChart(
              LineChartData(
                gridData: FlGridData(
                    show: false,
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
                // axisTitleData: FlAxisTitleData(
                //   topTitle: AxisTitle(
                //     showTitle: true,
                //     textAlign: TextAlign.center,
                //     textStyle: TextStyle(
                //         fontSize: 19,
                //         color: Theme.of(context).hintColor,
                //         fontWeight: FontWeight.bold),
                //   ),
                // ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (double value, TitleMeta meta) =>
                          SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          value.toInt().toString() + "C",
                          style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ),
                      interval: 10,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 18,
                      getTitlesWidget: (double value, TitleMeta meta) =>
                          SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          value.toInt().toString() + "%",
                          style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                      interval: 25,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                    show: false,
                    border: Border.all(
                        color: Theme.of(context).dividerColor, width: 1)),
                minX: getDataMinTemp(),
                maxX: getDataMaxTemp(),
                minY: 0,
                maxY: 100,
                lineBarsData: getDataWidget(context)
                  ..add(LineChartBarData(
                      spots: [
                        FlSpot(
                            context
                                .watch<RealTimeInfoProvider>()
                                .info
                                .cpuTemp
                                .toDouble(),
                            context
                                .watch<RealTimeInfoProvider>()
                                .info
                                .cpuFanSpeed
                                .toDouble()),
                      ],
                      barWidth: 0.01,
                      gradient: LinearGradient(colors: gradientColors),
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false))),
                lineTouchData: LineTouchData(enabled: false),
              ),
            ),
            Positioned(
              top: 28,
              left: 45,
              child: NeumorphicButton(
                onPressed: () =>
                    context.read<ThemeModel>().nextFanCurveSelection(),
                child: Text(
                  context.watch<ThemeModel>().fanCurveSelection,
                  style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                style: NeumorphicStyle(
                  depth: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
