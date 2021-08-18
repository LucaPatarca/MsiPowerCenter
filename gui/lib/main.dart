import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:myapp/App.dart';
import 'package:myapp/provider/ConfigProvider.dart';
import 'package:myapp/provider/ProfileProvider.dart';
import 'package:myapp/provider/RealTimeInfoProvider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ProfileProvider()),
      ChangeNotifierProvider(create: (context) => ThemeModel()),
      ChangeNotifierProvider(create: (context) => RealTimeInfoProvider())
    ],
    child: App(),
  ));

  doWhenWindowReady(() {
    final initialSize = Size(1280, 720);
    appWindow.minSize = Size(700, 620);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "Msi Power Center";
    appWindow.show();
  });
}
