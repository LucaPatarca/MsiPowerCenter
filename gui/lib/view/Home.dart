import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:myapp/model/profiles.dart';
import 'package:myapp/provider/ConfigProvider.dart';
import 'package:myapp/provider/ProfileProvider.dart';
import 'package:myapp/provider/RealTimeInfoProvider.dart';
import 'package:myapp/widgets/CloseButton.dart';
import 'package:myapp/widgets/DarkModeButton.dart';
import '../widgets/ProfileButton.dart';
import '../widgets/FanChart.dart';
import '../widgets/ProfileInfo.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key = const Key("key"), this.title = "Title"})
      : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    this.context.read<RealTimeInfoProvider>().start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: MoveWindow(child: Center(child: Text(widget.title))),
        centerTitle: true,
        actions: [
          Center(child: DarkModeButton()),
          Center(child: CloseAppButton()),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  child: FanChart(
                    profile: context.watch<ProfileProvider>().profile,
                    selection: context.watch<ThemeModel>().fanCurveSelection,
                  ),
                ),
                Expanded(
                  child: ProfileInfo(
                    profile: context.watch<ProfileProvider>().profile,
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
