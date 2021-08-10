import 'dart:ui';

import 'package:ini/ini.dart';

import 'FanConfig.dart';
import 'package:collection/collection.dart';

class EcConfig {
  static const _emptyFanList = [
    const FanConfig(46, 0),
    const FanConfig(55, 0),
    const FanConfig(64, 0),
    const FanConfig(73, 0),
    const FanConfig(82, 0),
    const FanConfig(91, 0),
    const FanConfig(100, 0),
  ];

  final List<FanConfig> cpuFanConfig;
  final List<FanConfig> gpuFanConfig;
  final bool coolerBoostEnabled;
  final int chargingThreshold = 0;

  const EcConfig(this.cpuFanConfig, this.gpuFanConfig, this.coolerBoostEnabled);

  EcConfig.fromConfig(Config config)
      : cpuFanConfig = List.from(_emptyFanList),
        gpuFanConfig = List.from(_emptyFanList),
        coolerBoostEnabled =
            config.get("Fan", "CoolerBoost")?.toLowerCase() == "true" {
    var cpuTemps = config.get("Temperature", "CpuTemps")?.split(";");
    var cpuSpeeds = config.get("Fan", "CpuFanSpeeds")?.split(";");
    if (cpuTemps != null && cpuSpeeds != null) {
      for (int i = 0; i < 7; i++) {
        cpuFanConfig.add(
            new FanConfig(int.parse(cpuTemps[i]), int.parse(cpuSpeeds[i])));
      }
    }
    var gpuTemps = config.get("Temperature", "GpuTemps")?.split(";");
    var gpuSpeeds = config.get("Fan", "GpuFanSpeeds")?.split(";");
    if (gpuTemps != null && gpuSpeeds != null) {
      for (int i = 0; i < 7; i++) {
        gpuFanConfig.add(
            new FanConfig(int.parse(gpuTemps[i]), int.parse(gpuSpeeds[i])));
      }
    }
  }

  EcConfig.fromJson(Map<String, dynamic> json)
      : cpuFanConfig = (json["cpu_fan_config"] as List<dynamic>)
            .map((e) => FanConfig(e["temp"], e["speed"]))
            .toList(),
        gpuFanConfig = (json["gpu_fan_config"] as List<dynamic>)
            .map((e) => FanConfig(e["temp"], e["speed"]))
            .toList(),
        this.coolerBoostEnabled = json["cooler_boost"];

  const EcConfig.empty()
      : cpuFanConfig = const [
          const FanConfig(46, 0),
          const FanConfig(55, 0),
          const FanConfig(64, 0),
          const FanConfig(73, 0),
          const FanConfig(82, 0),
          const FanConfig(91, 0),
          const FanConfig(100, 0),
        ],
        gpuFanConfig = const [
          const FanConfig(46, 0),
          const FanConfig(55, 0),
          const FanConfig(64, 0),
          const FanConfig(73, 0),
          const FanConfig(82, 0),
          const FanConfig(91, 0),
          const FanConfig(100, 0),
        ],
        coolerBoostEnabled = false;

  EcConfig copyWith({bool? coolerBoost}) {
    if (coolerBoost != null) {
      return EcConfig(this.cpuFanConfig, this.gpuFanConfig, coolerBoost);
    } else {
      return this;
    }
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
