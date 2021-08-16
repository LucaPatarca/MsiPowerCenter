import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class CloseAppButton extends StatelessWidget {
  const CloseAppButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      padding: EdgeInsets.all(6.0),
      onPressed: () => appWindow.close(),
      child: NeumorphicIcon(
        Icons.close,
        style: NeumorphicStyle(
          color: NeumorphicTheme.isUsingDark(context)
              ? Color(0xFFE0E0E0)
              : Color(0xFF1F1F1F),
        ),
        size: 34,
      ),
      style: NeumorphicStyle(
        depth: 6,
        boxShape: NeumorphicBoxShape.circle(),
      ),
    );
  }
}
