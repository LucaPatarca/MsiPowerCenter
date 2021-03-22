import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/profiles.dart';

typedef set_profile = Int32 Function(Pointer<Utf8> filepath);
typedef setProfile = int Function(Pointer<Utf8> filepath);

typedef read_current_profile = Pointer<ProfileStruct> Function();

class ProfileStruct extends Struct {
  Pointer<Utf8> name;
  Pointer<Int8> cpuTemps;
  Pointer<Int8> gpuTemps;
  Pointer<Int8> cpuSpeeds;
  Pointer<Int8> gpuSpeeds;
  @Int32()
  int coolerBoostEnabled;
  @Int32()
  int cpuMaxFreq;
  @Int32()
  int cpuMinFreq;
  Pointer<Utf8> cpuGovernor;
  Pointer<Utf8> cpuEnergyPref;
  @Int32()
  int cpuMaxPerf;
  @Int32()
  int cpuMinPerf;
  @Int32()
  int cpuTurboEnabled;
}

class LibManager {
  DynamicLibrary _dylib;
  var _setProfile;
  var _readCurrentProfile;
  final _libPath = kDebugMode == true
      ? "../cli/vsbuild/libmsictrl.so"
      : "/opt/MsiPowerCenter/lib/libmsictrl.so";
  final _profilesPath =
      kDebugMode == true ? "../profiles/" : "/opt/MsiPowerCenter/profiles/";
  LibManager() {
    _dylib = DynamicLibrary.open(_libPath);
    _setProfile = _dylib.lookupFunction<set_profile, setProfile>("set_profile");
    _readCurrentProfile =
        _dylib.lookupFunction<read_current_profile, read_current_profile>(
            "read_current_profile");
  }

  void writeProfile(Profile profile) {
    String path = _profilesPath;
    switch (profile) {
      case Profile.Performance:
        path = path + "performance.ini";
        break;
      case Profile.Balanced:
        path = path + "balanced.ini";
        break;
      case Profile.Silent:
        path = path + "silent.ini";
        break;
      case Profile.Battery:
        path = path + "battery.ini";
        break;
      default:
        break;
    }
    int res = _setProfile(path.toNativeUtf8());
    if (res != 0) {
      throw Exception("Unable to set profile");
    }
  }

  Pointer<ProfileStruct> readCurrentProfile() {
    Pointer<ProfileStruct> p = _readCurrentProfile();
    return p;
  }
}

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

class FanConfig {
  FanConfig(this.temp, this.speed);
  final int temp;
  final int speed;
}
