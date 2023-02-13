import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:myapp/provider/ConfigProvider.dart';
import 'package:myapp/provider/ProfileProvider.dart';
import 'package:myapp/view/Home.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  late Future<void> loading;

  @override
  void initState() {
    super.initState();
    loading = Future.wait([
      this.context.read<ProfileProvider>().readProfile(),
      this.context.read<ThemeModel>().loadPrefs()
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loading,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return NeumorphicApp(
            title: 'MSI Power Center',
            theme: NeumorphicThemeData(
              baseColor: Color(0xFFDADADA),
              shadowLightColor: Color(0xFFFFFFFF),
              shadowLightColorEmboss: Color(0xFFF5F5F5),
              accentColor: Colors.redAccent,
              lightSource: LightSource.topLeft,
              variantColor: Colors.redAccent[700]!,
              depth: 8,
            ),
            darkTheme: NeumorphicThemeData(
              accentColor: Colors.redAccent[400]!,
              baseColor: Color(0xFF3E3E3E),
              lightSource: LightSource.topLeft,
              shadowDarkColor: Color(0xFF202020),
              shadowDarkColorEmboss: Color(0xFF202020),
              shadowLightColor: Color(0xFF505050),
              shadowLightColorEmboss: Color(0xFF505050),
              depth: 7,
              intensity: 0.7,
              variantColor: Colors.redAccent[700]!,
            ),
            themeMode: context.watch<ThemeModel>().mode,
            home: HomePage(title: 'MSI Power Center'),
            debugShowCheckedModeBanner: false,
          );
        } else {
          return Container();
        }
      },
    );
  }
}
