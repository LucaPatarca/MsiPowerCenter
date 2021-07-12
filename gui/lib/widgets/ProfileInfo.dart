import 'package:flutter/material.dart';
import 'package:myapp/model/ProfileAdapter.dart';
import 'package:myapp/provider/ProfileProvider.dart';
import 'package:provider/provider.dart';

class ProfileInfo extends StatelessWidget {
  final ProfileAdapter profile;
  const ProfileInfo({Key key, this.profile}) : super(key: key);

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
              subtitle: Text(profile.cpuMaxFreq.toString()),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("Cpu Min Frequency"),
              subtitle: Text(profile.cpuMinFreq.toString()),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("Cpu Max Performance"),
              subtitle: Text(profile.cpuMaxPerf.toString() + "%"),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("Cpu Min Performance"),
              subtitle: Text(profile.cpuMinPerf.toString() + "%"),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("Cpu governor"),
              subtitle: Text(profile.cpuGovernor),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("Cpu Energy Pref"),
              subtitle: Text(profile.cpuEnergyPref),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("Cpu turbo"),
              subtitle: Text(profile.cpuTurboEnabled ? "Enabled" : "Disabled"),
            ),
          ),
          Card(
            child: ListTile(
              title: Text("Cooler Boost"),
              subtitle: Text(context
                      .watch<ProfileProvider>()
                      .getCurrentProfile()
                      .coolerBoostEnabled
                  ? "Enabled"
                  : "Disabled"),
              onTap: () => context.watch<ProfileProvider>().toggleCoolerBoost(),
            ),
          ),
        ],
      ),
    );
  }
}
