import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/model/ProfileAdapter.dart';
import 'package:myapp/model/ProfileStruct.dart';
import 'package:myapp/profiles.dart';

typedef set_profile = Int32 Function(Pointer<Utf8> filepath);
typedef setProfile = int Function(Pointer<Utf8> filepath);

typedef read_current_profile = Pointer<ProfileStruct> Function();

final _libPath = kDebugMode == true
    ? "../cli/vsbuild/libmsictrl.so"
    : "/opt/MsiPowerCenter/lib/libmsictrl.so";
final _dylib = DynamicLibrary.open(_libPath);
final _setProfile =
    _dylib.lookupFunction<set_profile, setProfile>("set_profile");
final _readCurrentProfile =
    _dylib.lookupFunction<read_current_profile, read_current_profile>(
        "read_current_profile");

class LibManager {
  final _profilesPath =
      kDebugMode == true ? "../profiles/" : "/opt/MsiPowerCenter/profiles/";

  Future<ProfileAdapter> getOnSecondaryIsolate() async {
    var res = await compute(getProfile, null);
    var pointer = Pointer.fromAddress(res);
    ProfileStruct struct = pointer.cast<ProfileStruct>().ref;
    return new ProfileAdapter(struct);
  }

  Future<void> setOnSecondaryIsolate(Profile profile) async {
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
    return await compute(writeProfile, path);
  }
}

void writeProfile(String profilePath) {
  int res = _setProfile(profilePath.toNativeUtf8());
  if (res != 0) {
    throw Exception("Unable to set profile");
  }
}

int getProfile(void v) {
  return _readCurrentProfile().address;
}
