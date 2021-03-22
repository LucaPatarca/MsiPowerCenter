import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/lib.dart';

import 'package:myapp/profiles.dart';

Future<void> setProfileFuture = Future.value();
Future<ProfileStruct> getProfileFuture = Future.value();

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MSI Power Center',
      theme: ThemeData(
          brightness: Brightness.light, accentColor: Colors.redAccent),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          accentColor: Colors.redAccent[400],
          primaryColor: Colors.red[700]),
      themeMode: ThemeMode.dark,
      home: HomePage(title: 'MSI Power Center'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key = const Key("key"), this.title = "Title"})
      : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Profile _profile = Profile.Changing;
  ProfileAdapter _currentProfile = ProfileAdapter.empty();
  LibManager manager = new LibManager();

  _HomePageState() {
    updateCurrentProfile();
  }

  void updateCurrentProfile() {
    manager.getOnSecondaryIsolate().then((value) {
      setState(() {
        _currentProfile = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProfileButton(
                  Profile.Performance,
                  selected: _profile == Profile.Performance,
                  afterProfileSet: defaultAfterProfileSet,
                  whileProfileSet: defaultWhileProfileChanging,
                ),
                ProfileButton(
                  Profile.Balanced,
                  selected: _profile == Profile.Balanced,
                  afterProfileSet: defaultAfterProfileSet,
                  whileProfileSet: defaultWhileProfileChanging,
                ),
                ProfileButton(
                  Profile.Silent,
                  selected: _profile == Profile.Silent,
                  afterProfileSet: defaultAfterProfileSet,
                  whileProfileSet: defaultWhileProfileChanging,
                ),
                ProfileButton(
                  Profile.Battery,
                  selected: _profile == Profile.Battery,
                  afterProfileSet: defaultAfterProfileSet,
                  whileProfileSet: defaultWhileProfileChanging,
                )
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: PointsLineChart(_currentProfile.cpuFanConfig,
                        title: "Cpu Fan")),
                Expanded(
                    child: PointsLineChart(_currentProfile.gpuFanConfig,
                        title: "Gpu Fan"))
              ],
            )
          ],
        ),
      ),
    );
  }

  void defaultWhileProfileChanging() {
    setState(() {
      _profile = Profile.Changing;
    });
  }

  void defaultAfterProfileSet(Profile profile) {
    setState(() {
      _profile = profile;
      updateCurrentProfile();
    });
  }
}

class ProfileButton extends StatelessWidget {
  final Profile profile;
  final bool selected;
  final void Function(Profile profile) afterProfileSet;
  final void Function() whileProfileSet;
  final LibManager manager = LibManager();

  ProfileButton(this.profile,
      {this.selected, this.afterProfileSet, this.whileProfileSet});
  VoidCallback setProfileCallback(
      BuildContext context, AsyncSnapshot snapshot, Profile profile) {
    if (snapshot.connectionState == ConnectionState.done) {
      return () {
        whileProfileSet();
        setProfileFuture = manager.setOnSecondaryIsolate(profile).then((value) {
          afterProfileSet(profile);
        }).catchError((e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Unable to set profile")));
        });
      };
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: setProfileFuture,
      builder: (context, snapshot) {
        return TextButton(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  getIconData(profile),
                  color: selected
                      ? Theme.of(context).accentColor
                      : Theme.of(context).unselectedWidgetColor,
                  size: 120,
                ),
                Text(
                  profile.toString().replaceFirst("Profile.", ""),
                  style: Theme.of(context).textTheme.headline6,
                ),
              ],
            ),
            onPressed: setProfileCallback(context, snapshot, profile));
      },
    );
  }

  IconData getIconData(Profile profile) {
    switch (profile) {
      case Profile.Performance:
        return Icons.speed;
      case Profile.Balanced:
        return Icons.equalizer;
      case Profile.Silent:
        return Icons.hearing_disabled;
      case Profile.Battery:
        return Icons.battery_full;
      default:
        return Icons.error;
    }
  }
}

class PointsLineChart extends StatefulWidget {
  final List<FanConfig> data;
  final String title;

  PointsLineChart(this.data, {this.title = "", Key key}) : super(key: key);

  @override
  _PointsLineChartState createState() => _PointsLineChartState();
}

class _PointsLineChartState extends State<PointsLineChart> {
  List<Color> gradientColors = [
    Colors.green[300],
    Colors.yellow,
    Colors.red[300],
  ];

  double getDataMinTemp() {
    return widget.data
        .reduce((value, element) => value.temp < element.temp ? value : element)
        .temp
        .toDouble();
  }

  double getDataMaxTemp() {
    return widget.data
        .reduce((value, element) => value.temp > element.temp ? value : element)
        .temp
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 300,
        child: LineChart(LineChartData(
          gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingVerticalLine: (value) {
                return FlLine(
                    color: Theme.of(context).dividerColor, strokeWidth: 1);
              },
              getDrawingHorizontalLine: (value) {
                return FlLine(
                    color: Theme.of(context).dividerColor, strokeWidth: 1);
              },
              horizontalInterval: 25,
              verticalInterval: 10),
          axisTitleData: FlAxisTitleData(
              topTitle: AxisTitle(
                  showTitle: true,
                  titleText: widget.title,
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
              border:
                  Border.all(color: Theme.of(context).dividerColor, width: 1)),
          minX: getDataMinTemp(),
          maxX: getDataMaxTemp(),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
                spots: widget.data
                    .map((e) => FlSpot(e.temp.toDouble(), e.speed.toDouble()))
                    .toList(),
                isCurved: true,
                barWidth: 5,
                colors: gradientColors,
                colorStops: [0, 0.5, 1],
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  colors: gradientColors
                      .map((color) => color.withOpacity(0.2))
                      .toList(),
                ))
          ],
        )),
      ),
    );
  }
}
