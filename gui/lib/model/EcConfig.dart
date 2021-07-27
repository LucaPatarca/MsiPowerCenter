import 'package:ini/ini.dart';

import 'FanConfig.dart';

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

  EcConfig.empty() {
    cpuFanConfig = List.from(_emptyFanList);
    gpuFanConfig = List.from(_emptyFanList);
    coolerBoostEnabled = false;
    chargingThreshold = 0;
  }
}
