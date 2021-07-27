import 'dart:io';

import 'package:ini/ini.dart';
import 'package:myapp/controller/cpu.dart';
import 'package:myapp/controller/ec.dart';
import 'package:myapp/model/ProfileConfig.dart';

import '../model/profiles.dart';

class ProfileService {
  final ecController = new EcController();
  final cpuController = new CpuController();

  ProfileConfig setProfile(Profile profile) {
    Config config = Config.fromStrings(File(profile.path).readAsLinesSync());
    var profileConfig = ProfileConfig.fromConfig(config);
    ecController.applyConfig(profileConfig.ecConfig);
    cpuController.applyConfig(profileConfig.cpuConfig);
    return getProfile();
  }

  ProfileConfig getProfile() {
    var ecConfig = ecController.readConfig();
    var cpuConfig = cpuController.readConfig();
    return ProfileConfig(cpuConfig, ecConfig);
  }

  bool setCoolerBoostEnabled(bool value) {
    ecController.setCoolerBoost(value);
    return ecController.isCoolerBoostEnabled();
  }
}
