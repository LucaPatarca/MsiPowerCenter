import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:myapp/model/ProfileConfig.dart';
import 'package:myapp/provider/ProfileProvider.dart';
import 'package:provider/provider.dart';

class ProfileInfo extends StatelessWidget {
  final ProfileConfig profile;
  const ProfileInfo({Key? key, this.profile = const ProfileConfig.empty()})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: GridView.extent(
        maxCrossAxisExtent: 250,
        childAspectRatio: 2.5,
        shrinkWrap: true,
        children: [
          Neumorphic(
            style: NeumorphicStyle(depth: 2),
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text("Cpu Max Frequency"),
              subtitle: Text(profile.cpu.maxFreq.toString()),
            ),
          ),
          Neumorphic(
            style: NeumorphicStyle(depth: 2),
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text("Cpu Min Frequency"),
              subtitle: Text(profile.cpu.minFreq.toString()),
            ),
          ),
          Neumorphic(
            style: NeumorphicStyle(depth: 2),
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text("Cpu Max Performance"),
              subtitle: Text(profile.cpu.maxPerf.toString() + "%"),
            ),
          ),
          Neumorphic(
            style: NeumorphicStyle(depth: 2),
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text("Cpu Min Performance"),
              subtitle: Text(profile.cpu.minPerf.toString() + "%"),
            ),
          ),
          Neumorphic(
            style: NeumorphicStyle(depth: 2),
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text("Cpu Governor"),
              subtitle: Text(profile.cpu.governor),
            ),
          ),
          Neumorphic(
            style: NeumorphicStyle(depth: 2),
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text("Cpu Energy Pref"),
              subtitle: Text(profile.cpu.energyPref),
            ),
          ),
          Neumorphic(
            style: NeumorphicStyle(depth: 2),
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text("Cpu Turbo"),
              subtitle: Text(profile.cpu.turboEnabled ? "Enabled" : "Disabled"),
            ),
          ),
          NeumorphicButton(
            margin: EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "Cooler Boost",
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            onPressed: () =>
                context.read<ProfileProvider>().toggleCoolerBoost(),
            style: NeumorphicStyle(
              depth: context
                      .watch<ProfileProvider>()
                      .getCurrentProfile()
                      .ec
                      .coolerBoostEnabled
                  ? -6
                  : 6,
            ),
          ),
          Neumorphic(
            style: NeumorphicStyle(depth: 2),
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text("Charging Limit"),
              subtitle: Text(context
                  .watch<ProfileProvider>()
                  .getCurrentProfile()
                  .ec
                  .chargingThreshold
                  .toString()),
            ),
          ),
        ],
      ),
    );
  }
}
