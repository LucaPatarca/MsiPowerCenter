import 'dart:convert';
import 'dart:io';

import 'package:myapp/model/profiles.dart';
import 'package:myapp/model/ProfileConfig.dart';
import 'package:myapp/service/ProfileService.dart';

const QUIT = 0;
const GET = 1;
const SET = 2;
const PERFORMANCE = 3;
const BALANCED = 4;
const SILENCE = 5;
const BATTERY = 6;
const COOLER_BOOST = 7;
const CHARGING_LIMIT = 8;
const PROFILE = 9;

class ProfileServiceDaemon implements ProfileService {
  final input = File("../cli/build/input");
  final output = File("../cli/build/output");

  @override
  Future<void> applyProfile(Profile profile) async {
    writeInput(SET);
    switch (profile) {
      case Profile.Performance:
        writeInput(PERFORMANCE);
        break;
      case Profile.Balanced:
        writeInput(BALANCED);
        break;
      case Profile.Silent:
        writeInput(SILENCE);
        break;
      case Profile.Battery:
        writeInput(BATTERY);
        break;
      case Profile.Changing:
        break;
    }
  }

  @override
  Future<bool> isCoolerBoostEnabled() {
    // TODO: implement isCoolerBoostEnabled
    throw UnimplementedError();
  }

  @override
  Future<int> readChargingLimit() {
    // TODO: implement readChargingLimit
    throw UnimplementedError();
  }

  @override
  Future<ProfileConfig> readProfile() async {
    writeInput(GET);
    writeInput(PROFILE);
    String jsonString = await readOutput();
    var json = jsonDecode(jsonString);
    return ProfileConfig.fromJson(json);
  }

  @override
  Future<void> setChargingLimit() {
    // TODO: implement setChargingLimit
    throw UnimplementedError();
  }

  @override
  Future<void> setCoolerBoostEnabled(bool value) {
    // TODO: implement setCoolerBoostEnabled
    throw UnimplementedError();
  }

  void writeInput(int value) {
    input.writeAsBytesSync([value]);
  }

  Future<String> readOutput() async {
    var stream = output
        .openRead()
        .takeWhile((element) => element != "\n".codeUnits)
        .timeout(Duration(seconds: 5));
    return String.fromCharCodes(await stream.first);
  }
}
