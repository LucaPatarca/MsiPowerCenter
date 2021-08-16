import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:myapp/model/ProfileConfig.dart';
import 'package:myapp/provider/ProfileProvider.dart';
import 'package:myapp/widgets/InactiveInfoElement.dart';
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
        padding: EdgeInsets.fromLTRB(16.0, 8.0, 32.0, 0),
        children: [
          NeumorphicButton(
            margin: EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "Cooler Boost",
                style: TextStyle(
                  color: context
                          .watch<ProfileProvider>()
                          .getCurrentProfile()
                          .ec
                          .coolerBoostEnabled
                      ? null
                      : Theme.of(context).accentColor,
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
              color: context
                      .watch<ProfileProvider>()
                      .getCurrentProfile()
                      .ec
                      .coolerBoostEnabled
                  ? Theme.of(context).accentColor
                  : null,
              boxShape:
                  NeumorphicBoxShape.roundRect(BorderRadius.circular(16.0)),
            ),
          ),
          InactiveInfoElement(
            child: ListTile(
              title: Text("Charging Limit"),
              subtitle: Text(context
                  .watch<ProfileProvider>()
                  .getCurrentProfile()
                  .ec
                  .chargingThreshold
                  .toString()),
              enabled: false,
            ),
          ),
          InactiveInfoElement(
            child: ListTile(
              title: Text("Max Frequency"),
              subtitle: Text(toGhz(profile.cpu.maxFreq)),
            ),
          ),
          InactiveInfoElement(
            child: ListTile(
              title: Text("Min Frequency"),
              subtitle: Text(toGhz(profile.cpu.minFreq)),
            ),
          ),
          InactiveInfoElement(
            child: ListTile(
              title: Text("Max Performance"),
              subtitle: NeumorphicProgress(
                percent: profile.cpu.maxPerf / 100,
              ),
            ),
          ),
          InactiveInfoElement(
            child: ListTile(
              title: Text("Min Performance"),
              subtitle: NeumorphicProgress(
                percent: profile.cpu.minPerf / 100,
              ),
            ),
          ),
          InactiveInfoElement(
            child: ListTile(
              title: Text("Cpu Governor"),
              subtitle: Text(profile.cpu.governor),
            ),
          ),
          InactiveInfoElement(
            child: ListTile(
              title: Text("Energy Preferences"),
              subtitle: Text(profile.cpu.energyPref),
            ),
          ),
          InactiveInfoElement(
            child: ListTile(
              title: Text("Turbo"),
              trailing: context
                      .watch<ProfileProvider>()
                      .getCurrentProfile()
                      .cpu
                      .turboEnabled
                  ? Icon(
                      Icons.toggle_on_outlined,
                      color: Theme.of(context).accentColor,
                      size: 30,
                    )
                  : Icon(
                      Icons.toggle_off_outlined,
                      size: 30,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String toGhz(int value) {
    return (value / 1000000).toString() + " Ghz";
  }
}
