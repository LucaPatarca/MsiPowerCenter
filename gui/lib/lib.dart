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

  String getName() {
    return name.toDartString();
  }

  List<int> getCpuTemps() {
    return cpuTemps.asTypedList(7);
  }

  List<int> getGpuTemps() {
    return gpuTemps.asTypedList(7);
  }

  List<int> getCpuFanSpeeds() {
    return cpuSpeeds.asTypedList(7);
  }

  List<int> getGpuFanSpeeds() {
    return gpuSpeeds.asTypedList(7);
  }

  bool isCoolerBoostEnabled() {
    return coolerBoostEnabled != 0;
  }

  int getCpuMaxFreq() {
    return cpuMaxFreq;
  }

  int getCpuMinFreq() {
    return cpuMinFreq;
  }

  String getCpuGovernor() {
    return cpuGovernor.toDartString();
  }

  String getCpuEnergyPref() {
    return cpuEnergyPref.toDartString();
  }

  int getCpuMaxPerf() {
    return cpuMaxPerf;
  }

  int getCpuMinPerf() {
    return cpuMinPerf;
  }

  bool isCpuTurboEnabled() {
    return cpuTurboEnabled != 0;
  }
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
    print(_libPath);
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

  ProfileStruct readCurrentProfile() {
    Pointer<ProfileStruct> p = _readCurrentProfile();
    return p.ref;
  }
}
