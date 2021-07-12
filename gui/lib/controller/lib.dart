import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/model/ProfileAdapter.dart';
import 'package:myapp/model/ProfileStruct.dart';
import 'package:myapp/profiles.dart';

typedef set_profile_type = Int32 Function(Pointer<Utf8> filepath);
typedef setProfileType = int Function(Pointer<Utf8> filepath);

typedef read_current_profile_type = Pointer<ProfileStruct> Function();

typedef set_cooler_boost_type = Int32 Function(Int32 value);
typedef setCoolerBoostType = int Function(int value);

typedef get_cooler_boost_type = Int32 Function();
typedef getCoolerBoostType = int Function();

final _libPath = kDebugMode == true
    ? "../cli/build/libmsictrl.so"
    : "/opt/MsiPowerCenter/lib/libmsictrl.so";
final _dylib = DynamicLibrary.open(_libPath);
final _setProfile =
    _dylib.lookupFunction<set_profile_type, setProfileType>("set_profile");
final _readCurrentProfile =
    _dylib.lookupFunction<read_current_profile_type, read_current_profile_type>(
        "read_current_profile");
final _setCoolerBoost =
    _dylib.lookupFunction<set_cooler_boost_type, setCoolerBoostType>(
        "set_cooler_boost");
final _getCoolerBoost =
    _dylib.lookupFunction<get_cooler_boost_type, getCoolerBoostType>(
        "get_cooler_boost");

class LibController {
  final _profilesPath =
      kDebugMode == true ? "../profiles/" : "/opt/MsiPowerCenter/profiles/";

  Future<ProfileAdapter> getProfile() async {
    var res = await compute(getProfileSync, null);
    var pointer = Pointer.fromAddress(res);
    ProfileStruct struct = pointer.cast<ProfileStruct>().ref;
    return new ProfileAdapter(struct);
  }

  Future<void> setProfile(Profile profile) async {
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
    return await compute(writeProfileSync, path);
  }

  Future<void> setCoolerBoost(bool value) async {
    return await compute(writeCoolerBoostSync, value);
  }

  Future<bool> getCoolerBoost() async {
    return await compute(getCoolerBoostSync, null);
  }
}

void writeProfileSync(String profilePath) {
  int res = _setProfile(profilePath.toNativeUtf8());
  if (res != 0) {
    throw Exception("Unable to set profile");
  }
}

int getProfileSync(void v) {
  return _readCurrentProfile().address;
}

void writeCoolerBoostSync(bool value) {
  int res = _setCoolerBoost(value ? 1 : 0);
  if (res != 0) {
    throw Exception("Unable to set cooler boost");
  }
}

bool getCoolerBoostSync(void v) {
  int res = _getCoolerBoost();
  return res != 0;
}
