import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import 'package:myapp/model/profiles.dart';
import 'package:myapp/provider/ProfileProvider.dart';
import 'package:myapp/widgets/ProfileInfo.dart';
import 'widgets/FanCurve.dart';
import 'widgets/ProfileButton.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ProfileProvider()),
      ChangeNotifierProvider(create: (context) => ThemeModel())
    ],
    child: App(),
  ));
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NeumorphicApp(
      title: 'MSI Power Center',
      theme: NeumorphicThemeData(
        baseColor: Color(0xFFE9E0D9),
        accentColor: Colors.redAccent,
        lightSource: LightSource.topLeft,
        variantColor: Colors.redAccent[400]!,
        depth: 8,
      ),
      darkTheme: NeumorphicThemeData(
        accentColor: Colors.black,
        baseColor: Color(0xFF3E3E3E),
        lightSource: LightSource.topLeft,
        shadowDarkColor: Color(0xFF202020),
        shadowDarkColorEmboss: Color(0xFF202020),
        shadowLightColor: Color(0xFF505050),
        shadowLightColorEmboss: Color(0xFF505050),
        depth: 7,
        intensity: 0.7,
        variantColor: Colors.redAccent[400]!,
      ),
      themeMode: context.watch<ThemeModel>().mode,
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          Center(
            child: GestureDetector(
              onTap: () => context.read<ThemeModel>().toggleMode(),
              child: NeumorphicIcon(
                NeumorphicTheme.isUsingDark(context)
                    ? Icons.mode_night
                    : Icons.light_mode,
                style: NeumorphicStyle(
                  color: Theme.of(context).accentColor,
                ),
                size: 40,
              ),
            ),
          )
        ],
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

class ThemeModel with ChangeNotifier {
  ThemeMode _mode;
  ThemeMode get mode => _mode;
  ThemeModel({ThemeMode mode = ThemeMode.light}) : _mode = mode;

  void toggleMode() {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
