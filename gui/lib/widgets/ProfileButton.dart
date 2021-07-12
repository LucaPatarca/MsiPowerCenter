import 'package:flutter/material.dart';
import 'package:myapp/profiles.dart';
import 'package:myapp/provider/ProfileProvider.dart';
import 'package:provider/provider.dart';

class ProfileButton extends StatefulWidget {
  final Profile profile;

  ProfileButton(this.profile);

  @override
  _ProfileButtonState createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<ProfileButton> {
  Future<void> setProfileFuture = Future.value();

  VoidCallback setProfileCallback(
      BuildContext context, AsyncSnapshot snapshot, Profile profile) {
    if (snapshot.connectionState == ConnectionState.done) {
      return () {
        ProfileProvider provider = context.read<ProfileProvider>();
        provider.setProfileSelection(Profile.Changing);
        setProfileFuture = provider.setProfile(profile).catchError((e) {
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
                  color:
                      context.watch<ProfileProvider>().getProfileSelection() ==
                              widget.profile
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
