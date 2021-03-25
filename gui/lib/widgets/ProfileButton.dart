import 'package:flutter/material.dart';
import 'package:myapp/profiles.dart';
import 'package:myapp/service/lib.dart';

class ProfileButton extends StatefulWidget {
  final Profile profile;
  final bool selected;
  final void Function(Profile profile) afterProfileSet;
  final void Function() whileProfileSet;

  ProfileButton(this.profile,
      {this.selected, this.afterProfileSet, this.whileProfileSet});

  @override
  _ProfileButtonState createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<ProfileButton> {
  final LibManager manager = LibManager();
  Future<void> setProfileFuture = Future.value();

  VoidCallback setProfileCallback(
      BuildContext context, AsyncSnapshot snapshot, Profile profile) {
    if (snapshot.connectionState == ConnectionState.done) {
      return () {
        widget.whileProfileSet();
        setProfileFuture = manager.setOnSecondaryIsolate(profile).then((value) {
          widget.afterProfileSet(profile);
        }).catchError((e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Unable to set profile")));
        });
      };
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: setProfileFuture,
      builder: (context, snapshot) {
        return TextButton(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  getIconData(widget.profile),
                  color: widget.selected
                      ? Theme.of(context).accentColor
                      : Theme.of(context).unselectedWidgetColor,
                  size: 120,
                ),
                Text(
                  widget.profile.toString().replaceFirst("Profile.", ""),
                  style: Theme.of(context).textTheme.headline6,
                ),
              ],
            ),
            onPressed: setProfileCallback(context, snapshot, widget.profile));
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
        return Icons.error;
    }
  }
}
