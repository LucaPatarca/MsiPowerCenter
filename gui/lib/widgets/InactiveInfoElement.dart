import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class InactiveInfoElement extends StatelessWidget {
  final Widget child;

  const InactiveInfoElement({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: 1.5,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16.0)),
      ),
      margin: EdgeInsets.all(6.0),
      child: this.child,
    );
  }
}
