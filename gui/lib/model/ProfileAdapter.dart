import 'package:myapp/model/ProfileStruct.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'FanConfig.dart';

class ProfileAdapter {
  final _emptyFanList = [
    new FanConfig(46, 0),
    new FanConfig(55, 0),
    new FanConfig(64, 0),
    new FanConfig(73, 0),
    new FanConfig(82, 0),
    new FanConfig(91, 0),
    new FanConfig(100, 0),
  ];

  String name = "";
  List<FanConfig> cpuFanConfig = List.empty();
  List<FanConfig> gpuFanConfig = List.empty();
  bool coolerBoostEnabled = false;
  int cpuMaxFreq = 0;
  int cpuMinFreq = 0;
  String cpuGovernor = "null";
  String cpuEnergyPref = "null";
  int cpuMaxPerf = 0;
  int cpuMinPerf = 0;
  bool cpuTurboEnabled = false;

  ProfileAdapter(ProfileStruct p) {
    name = p.name.toDartString();
    var cpuTemps = p.cpuTemps.asTypedList(7);
    var gpuTemps = p.gpuTemps.asTypedList(7);
    var cpuSpeeds = p.cpuSpeeds.asTypedList(7);
    var gpuSpeeds = p.gpuSpeeds.asTypedList(7);
    cpuFanConfig = List.empty(growable: true);
    gpuFanConfig = List.empty(growable: true);
    for (var i = 0; i < 7; i++) {
      cpuFanConfig
          .add(FanConfig(cpuTemps.elementAt(i), cpuSpeeds.elementAt(i)));
      gpuFanConfig
          .add(FanConfig(gpuTemps.elementAt(i), gpuSpeeds.elementAt(i)));
    }
    coolerBoostEnabled = p.coolerBoostEnabled != 0;
    cpuMaxFreq = p.cpuMaxFreq;
    cpuMinFreq = p.cpuMinFreq;
    cpuGovernor = p.cpuGovernor.toDartString();
    cpuEnergyPref = p.cpuEnergyPref.toDartString();
    cpuMaxPerf = p.cpuMaxPerf;
    cpuMinPerf = p.cpuMinPerf;
    cpuTurboEnabled = p.cpuTurboEnabled != 0;
  }

  ProfileAdapter.empty() {
    name = "empty";
    cpuFanConfig = _emptyFanList;
    gpuFanConfig = _emptyFanList;
    coolerBoostEnabled = false;
    cpuMaxFreq = 0;
    cpuMinFreq = 0;
    cpuGovernor = "null";
    cpuEnergyPref = "null";
    cpuMaxPerf = 0;
    cpuMinPerf = 0;
    cpuTurboEnabled = false;
  }
}