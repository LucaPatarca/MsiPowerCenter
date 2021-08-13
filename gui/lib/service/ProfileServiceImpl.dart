import 'dart:io';

import 'package:ini/ini.dart';
import 'package:myapp/controller/implementation/CpuControllerImpl.dart';
import 'package:myapp/controller/implementation/EcControllerImpl.dart';
import 'package:myapp/model/ProfileConfig.dart';
import 'package:myapp/service/ProfileService.dart';

import '../model/profiles.dart';

class ProfileServiceImpl implements ProfileService {
  final ecController = new EcControllerImpl();
  final cpuController = new CpuControllerImpl();

  Future<ProfileConfig> applyProfile(Profile profile) async {
    Config config = Config.fromStrings(File(profile.path).readAsLinesSync());
    var profileConfig = ProfileConfig.fromConfig(config);
    ecController.applyConfig(profileConfig.ec);
    cpuController.applyConfig(profileConfig.cpu);
    return profileConfig;
  }

  Future<ProfileConfig> readProfile() async {
    var ecConfig = ecController.readConfig();
    var cpuConfig = cpuController.readConfig();
    return ProfileConfig(cpuConfig, ecConfig);
  }

  Future<bool> setCoolerBoostEnabled(bool value) async {
    ecController.setCoolerBoost(value);
    return ecController.isCoolerBoostEnabled();
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
  Future<int> setChargingLimit(int value) {
    // TODO: implement setChargingLimit
    throw UnimplementedError();
  }
}
