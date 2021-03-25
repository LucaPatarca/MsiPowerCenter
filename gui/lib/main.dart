import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/service/lib.dart';

import 'package:myapp/profiles.dart';
import 'model/ProfileAdapter.dart';
import 'widgets/FanCurve.dart';
import 'widgets/ProfileButton.dart';

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
          primaryColor: Colors.black,
          buttonColor: Colors.redAccent[400],
          splashColor: Colors.red),
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
  String selection = "cpu";

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
                  child: FanCurve(_currentProfile),
                ),
                Expanded(
                  child: SizedBox(
                    height: 300,
                    child: GridView.extent(
                      maxCrossAxisExtent: 250,
                      childAspectRatio: 2.5,
                      shrinkWrap: true,
                      children: [
                        Card(
                          child: ListTile(
                            title: Text("Cpu Max Frequency"),
                            subtitle:
                                Text(_currentProfile.cpuMaxFreq.toString()),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: Text("Cpu Min Frequency"),
                            subtitle:
                                Text(_currentProfile.cpuMinFreq.toString()),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: Text("Cpu Max Performance"),
                            subtitle: Text(
                                _currentProfile.cpuMaxPerf.toString() + "%"),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: Text("Cpu Min Performance"),
                            subtitle: Text(
                                _currentProfile.cpuMinPerf.toString() + "%"),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: Text("Cpu governor"),
                            subtitle: Text(_currentProfile.cpuGovernor),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: Text("Cpu Energy Pref"),
                            subtitle: Text(_currentProfile.cpuEnergyPref),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: Text("Cpu turbo"),
                            subtitle: Text(_currentProfile.cpuTurboEnabled
                                ? "Enabled"
                                : "Disabled"),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: Text("Cooler Boost"),
                            subtitle: Text(_currentProfile.coolerBoostEnabled
                                ? "Enabled"
                                : "Disabled"),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
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
