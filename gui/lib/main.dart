import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/lib.dart';

import 'package:myapp/profiles.dart';
import 'package:charts_flutter/flutter.dart';

LibManager manager = new LibManager();
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
        primarySwatch: Colors.blue,
      ),
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

  _HomePageState() {
    updateCurrentProfile();
  }

  void updateCurrentProfile() {
    getOnSecondaryIsolate().then((value) {
      setState(() {
        _currentProfile = value;
      });
    });
  }

  VoidCallback setProfileCallback(
      BuildContext context, AsyncSnapshot snapshot, Profile profile) {
    if (snapshot.connectionState == ConnectionState.done) {
      return () {
        setState(() {
          setProfileFuture = setOnSecondaryIsolate(profile).then((value) {
            _profile = profile;
            updateCurrentProfile();
          }).catchError((e) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Unable to set profile")));
          });
        });
      };
    } else {
      return null;
    }
  }

  Future<void> setOnSecondaryIsolate(Profile profile) async {
    setState(() {
      _profile = Profile.Changing;
    });
    return await compute(setProfile, profile);
  }

  Future<ProfileAdapter> getOnSecondaryIsolate() async {
    var res = await compute(getProfile, null);
    var pointer = Pointer.fromAddress(res);
    ProfileStruct struct = pointer.cast<ProfileStruct>().ref;
    return new ProfileAdapter(struct);
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
                createProfileButton(Profile.Performance),
                createProfileButton(Profile.Balanced),
                createProfileButton(Profile.Silent),
                createProfileButton(Profile.Battery)
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: PointsLineChart(_currentProfile.cpuFanConfig,
                        title: "Cpu Fans")),
                Expanded(
                    child: PointsLineChart(_currentProfile.gpuFanConfig,
                        title: "Gpu Fans"))
              ],
            )
          ],
        ),
      ),
    );
  }

  FutureBuilder createProfileButton(Profile profile) {
    return FutureBuilder(
      future: setProfileFuture,
      builder: (context, snapshot) {
        return TextButton(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  getIconData(profile),
                  color: _profile == profile
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

void setProfile(Profile profile) {
  manager.writeProfile(profile);
}

int getProfile(void v) {
  return manager.readCurrentProfile().address;
}

class PointsLineChart extends StatefulWidget {
  final List<FanConfig> data;
  final String title;

  PointsLineChart(this.data, {this.title = "", Key key = const Key("key")})
      : super(key: key);

  @override
  _PointsLineChartState createState() => _PointsLineChartState();
}

class _PointsLineChartState extends State<PointsLineChart> {
  List<Series<FanConfig, int>> series = List.empty();
  bool animate = false;

  void didUpdateWidget(covariant PointsLineChart old) {
    if (old.data != widget.data) {
      this.series = [
        new Series<FanConfig, int>(
          id: 'Fans',
          colorFn: (_, __) => MaterialPalette.blue.shadeDefault,
          domainFn: (FanConfig fc, _) => fc.temp,
          measureFn: (FanConfig fc, _) => fc.speed,
          data: widget.data,
        )
      ];
      animate = true;
    } else {
      animate = false;
    }
    super.didUpdateWidget(old);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: new LineChart(
        series,
        animate: animate,
        defaultRenderer: new LineRendererConfig(includePoints: true),
        domainAxis: NumericAxisSpec(
            tickProviderSpec: BasicNumericTickProviderSpec(zeroBound: false),
            tickFormatterSpec:
                BasicNumericTickFormatterSpec((i) => i.toString() + "C")),
        primaryMeasureAxis: NumericAxisSpec(
            tickFormatterSpec: BasicNumericTickFormatterSpec(
                (i) => i.toInt().toString() + "%")),
        behaviors: [
          ChartTitle(widget.title, behaviorPosition: BehaviorPosition.top)
        ],
      ),
    );
  }
}
