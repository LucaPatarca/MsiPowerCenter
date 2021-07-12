import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:myapp/profiles.dart';
import 'package:myapp/provider/ProfileProvider.dart';
import 'package:myapp/widgets/ProfileInfo.dart';
import 'widgets/FanCurve.dart';
import 'widgets/ProfileButton.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (context) => ProfileProvider())],
    child: App(),
  ));
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
  String selection = "cpu";

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
                ProfileButton(Profile.Performance),
                ProfileButton(Profile.Balanced),
                ProfileButton(Profile.Silent),
                ProfileButton(Profile.Battery)
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: FanCurve(
                      context.watch<ProfileProvider>().getCurrentProfile()),
                ),
                Expanded(
                  child: ProfileInfo(
                    profile:
                        context.watch<ProfileProvider>().getCurrentProfile(),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
