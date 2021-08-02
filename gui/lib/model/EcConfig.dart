import 'dart:ui';

import 'package:ini/ini.dart';

import 'FanConfig.dart';
import 'package:collection/collection.dart';

class EcConfig {
  final _emptyFanList = [
    new FanConfig(46, 0),
    new FanConfig(55, 0),
    new FanConfig(64, 0),
    new FanConfig(73, 0),
    new FanConfig(82, 0),
    new FanConfig(91, 0),
    new FanConfig(100, 0),
  ];

  List<FanConfig> cpuFanConfig = List.empty();
  List<FanConfig> gpuFanConfig = List.empty();
  bool coolerBoostEnabled = false;
  int chargingThreshold = 0;

  EcConfig.fromConfig(Config config) {
    cpuFanConfig = List.empty(growable: true);
    gpuFanConfig = List.empty(growable: true);
    var cpuTemps = config.get("Temperature", "CpuTemps").split(";");
    var cpuSpeeds = config.get("Fan", "CpuFanSpeeds").split(";");
    for (int i = 0; i < 7; i++) {
      cpuFanConfig
          .add(new FanConfig(int.parse(cpuTemps[i]), int.parse(cpuSpeeds[i])));
    }
    var gpuTemps = config.get("Temperature", "GpuTemps").split(";");
    var gpuSpeeds = config.get("Fan", "GpuFanSpeeds").split(";");
    for (int i = 0; i < 7; i++) {
      gpuFanConfig
          .add(new FanConfig(int.parse(gpuTemps[i]), int.parse(gpuSpeeds[i])));
    }
    this.coolerBoostEnabled =
        config.get("Fan", "CoolerBoost").toLowerCase() == "true";
  }

  EcConfig.fromJson(Map<String, dynamic> json) {
    var jsonCpuList = json["cpuFanConfig"] as List<dynamic>;
    this.cpuFanConfig =
        jsonCpuList.map((e) => FanConfig(e["temp"], e["speed"])).toList();
    var jsonGpuList = json["gpuFanConfig"] as List<dynamic>;
    this.gpuFanConfig =
        jsonGpuList.map((e) => FanConfig(e["temp"], e["speed"])).toList();
    this.coolerBoostEnabled = json["coolerBoost"];
    //TODO sistemare
    this.chargingThreshold = 0;
  }

  EcConfig.empty() {
    cpuFanConfig = List.from(_emptyFanList);
    gpuFanConfig = List.from(_emptyFanList);
    coolerBoostEnabled = false;
    chargingThreshold = 0;
  }

  @override
  bool operator ==(Object other) {
    return other is EcConfig &&
        ListEquality().equals(this.cpuFanConfig, other.cpuFanConfig) &&
        ListEquality().equals(this.gpuFanConfig, other.gpuFanConfig) &&
        this.coolerBoostEnabled == other.coolerBoostEnabled;
  }

  @override
  int get hashCode {
    return hashValues(
        hashList(cpuFanConfig), hashList(gpuFanConfig), coolerBoostEnabled);
  }
}
