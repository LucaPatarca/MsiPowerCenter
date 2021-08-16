import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:myapp/provider/ConfigProvider.dart';
import 'package:provider/provider.dart';

class DarkModeButton extends StatelessWidget {
  const DarkModeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      padding: EdgeInsets.all(6.0),
      onPressed: () => context.read<ThemeModel>().toggleMode(),
      child: NeumorphicIcon(
        NeumorphicTheme.isUsingDark(context)
            ? Icons.mode_night
            : Icons.light_mode,
        style: NeumorphicStyle(
          color: Theme.of(context).accentColor,
        ),
        size: 34,
      ),
      style: NeumorphicStyle(
        depth: 4,
        boxShape: NeumorphicBoxShape.circle(),
      ),
    );
  }
}
