import 'package:flutter/material.dart';
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
          Card(
            child: ListTile(
              title: Text("Cpu Max Frequency"),
              subtitle: Text(profile.cpu.maxFreq.toString()),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("Cpu Min Frequency"),
              subtitle: Text(profile.cpu.minFreq.toString()),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("Cpu Max Performance"),
              subtitle: Text(profile.cpu.maxPerf.toString() + "%"),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("Cpu Min Performance"),
              subtitle: Text(profile.cpu.minPerf.toString() + "%"),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("Cpu Governor"),
              subtitle: Text(profile.cpu.governor),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("Cpu Energy Pref"),
              subtitle: Text(profile.cpu.energyPref),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("Cpu Turbo"),
              subtitle: Text(profile.cpu.turboEnabled ? "Enabled" : "Disabled"),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("Cooler Boost"),
              subtitle: Text(context
                      .watch<ProfileProvider>()
                      .getCurrentProfile()
                      .ec
                      .coolerBoostEnabled
                  ? "Enabled"
                  : "Disabled"),
              onTap: () => context.read<ProfileProvider>().toggleCoolerBoost(),
            ),
          ),
          Card(
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
