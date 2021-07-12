import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:myapp/model/ProfileAdapter.dart';
import 'package:myapp/model/ProfileStruct.dart';

typedef read_current_profile_type = Pointer<ProfileStruct> Function();

typedef set_cooler_boost_type = Int32 Function(Int32 value);
typedef setCoolerBoostType = int Function(int value);

typedef get_cooler_boost_type = Int32 Function();
typedef getCoolerBoostType = int Function();

final _libPath = kDebugMode == true
    ? "../cli/build/libmsictrl.so"
    : "/opt/MsiPowerCenter/lib/libmsictrl.so";
final _dylib = DynamicLibrary.open(_libPath);
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
  Future<ProfileClass> getProfile() async {
    var res = await compute(getProfileSync, null);
    var pointer = Pointer.fromAddress(res);
    ProfileStruct struct = pointer.cast<ProfileStruct>().ref;
    return new ProfileClass(struct);
  }

  Future<void> setCoolerBoost(bool value) async {
    return await compute(writeCoolerBoostSync, value);
  }

  Future<bool> getCoolerBoost() async {
    return await compute(getCoolerBoostSync, null);
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
