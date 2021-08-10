import 'package:flutter/material.dart';
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
        return TextButton(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.profile.icon,
                  color:
                      context.watch<ProfileProvider>().getProfileSelection() ==
                              widget.profile
                          ? Theme.of(context).accentColor
                          : Theme.of(context).unselectedWidgetColor,
                  size: 120,
                ),
                Text(
                  widget.profile.name,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ],
            ),
            onPressed: setProfileCallback(context, snapshot, widget.profile));
      },
    );
  }
}
