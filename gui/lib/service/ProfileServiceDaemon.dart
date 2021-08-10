import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:myapp/model/Command.dart';
import 'package:myapp/model/profiles.dart';
import 'package:myapp/model/ProfileConfig.dart';
import 'package:myapp/service/ProfileService.dart';

class ProfileServiceDaemon implements ProfileService {
  final input =
      File(kDebugMode ? "../input_debug" : "/opt/MsiPowerCenter/pipes/input");
  final output =
      File(kDebugMode ? "../output_debug" : "/opt/MsiPowerCenter/pipes/output");

  @override
  Future<ProfileConfig> applyProfile(Profile profile) async {
    var command = Command(
        toSet: ToSet(CommandCategory.Profile, profile.name),
        toGet: ToGet(CommandCategory.Profile));
    _sendCommand(command);
    return _readProfile();
  }

  @override
  Future<bool> isCoolerBoostEnabled() async {
    var command = Command(toGet: ToGet(CommandCategory.CoolerBoost));
    _sendCommand(command);
    return _readCoolerBoost();
  }

  Future<bool> _readCoolerBoost() async {
    return jsonDecode(await _readOutput());
  }

  @override
  Future<int> readChargingLimit() async {
    var command = Command(toGet: ToGet(CommandCategory.ChargingLimit));
    _sendCommand(command);
    return _readChargingLimit();
  }

  Future<int> _readChargingLimit() async {
    return jsonDecode(await _readOutput());
  }

  @override
  Future<ProfileConfig> readProfile() async {
    var command = Command(toGet: ToGet(CommandCategory.Profile));
    _sendCommand(command);
    return _readProfile();
  }

  Future<ProfileConfig> _readProfile() async {
    String jsonString = await _readOutput();
    Map<String, dynamic> json = jsonDecode(jsonString);
    if (json.containsKey("error")) {
      throw Exception(json["error"]);
    }
    return ProfileConfig.fromJson(json);
  }

  @override
  Future<int> setChargingLimit(int value) async {
    var command = Command(
        toSet: ToSet(CommandCategory.CoolerBoost, value),
        toGet: ToGet(CommandCategory.ChargingLimit));
    _sendCommand(command);
    return _readChargingLimit();
  }

  @override
  Future<bool> setCoolerBoostEnabled(bool value) async {
    var command = Command(
        toSet: ToSet(CommandCategory.CoolerBoost, value),
        toGet: ToGet(CommandCategory.CoolerBoost));
    _sendCommand(command);
    return _readCoolerBoost();
  }

  void _sendCommand(Command command) {
    var json = jsonEncode(command);
    json += "\n";
    input.writeAsStringSync(json);
  }

  Future<String> _readOutput() async {
    var result = output
        .readAsString()
        .timeout(Duration(seconds: 5), onTimeout: () => "");
    return result;
  }
}
