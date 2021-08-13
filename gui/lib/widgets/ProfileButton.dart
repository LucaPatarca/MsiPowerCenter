import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:myapp/model/profiles.dart';
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

  VoidCallback? setProfileCallback(
      BuildContext context, AsyncSnapshot snapshot, Profile profile) {
    if (snapshot.connectionState == ConnectionState.done) {
      return () {
        ProfileProvider provider = context.read<ProfileProvider>();
        var oldSelection = provider.getProfileSelection();
        provider.setProfileSelection(Profile.Changing);
        setProfileFuture = provider.setProfile(profile).catchError((e) {
          provider.setProfileSelection(oldSelection);
          print(e);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
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
        return NeumorphicButton(
          padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 26.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeumorphicIcon(
                widget.profile.icon,
                style: NeumorphicStyle(
                  color:
                      context.watch<ProfileProvider>().getProfileSelection() ==
                              widget.profile
                          ? Theme.of(context).accentColor
                          : Theme.of(context).unselectedWidgetColor,
                  depth:
                      context.watch<ProfileProvider>().getProfileSelection() ==
                              widget.profile
                          ? 6
                          : 0,
                ),
                size: 120,
              ),
              Text(
                widget.profile.name,
                style: Theme.of(context).textTheme.headline6,
              ),
            ],
          ),
          onPressed: setProfileCallback(context, snapshot, widget.profile),
          style: NeumorphicStyle(
            depth: context.watch<ProfileProvider>().getProfileSelection() ==
                    widget.profile
                ? -7
                : 5,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(32.0)),
          ),
        );
      },
    );
  }
}
