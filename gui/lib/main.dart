import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/lib.dart';

import 'package:myapp/profiles.dart';

LibManager manager = new LibManager();
Future<void> computeFuture = Future.value();

void main() {
  final manager = new LibManager();
  ProfileStruct p = manager.readCurrentProfile();
  print(p.getCpuMaxPerf());
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
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Profile _profile = Profile.Changing;

  VoidCallback createCallback(
      BuildContext context, AsyncSnapshot snapshot, Profile profile) {
    if (snapshot.connectionState == ConnectionState.done) {
      return () {
        setState(() {
          computeFuture = computeOnSecondaryIsolate(profile)
              .then((value) => {_profile = profile})
              .catchError((e) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Unable to set profile")));
          });
        });
      };
    } else {
      return null;
    }
  }

  Future<void> computeOnSecondaryIsolate(Profile profile) async {
    setState(() {
      _profile = Profile.Changing;
    });
    return await compute(fun, profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            createProfileButton(Profile.Performance),
            createProfileButton(Profile.Balanced),
            createProfileButton(Profile.Silent),
            createProfileButton(Profile.Battery)
          ],
        ),
      ),
    );
  }

  FutureBuilder createProfileButton(Profile profile) {
    return FutureBuilder(
      future: computeFuture,
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
            onPressed: createCallback(context, snapshot, profile));
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
        return null;
    }
  }
}

void fun(Profile profile) {
  manager.writeProfile(profile);
}
