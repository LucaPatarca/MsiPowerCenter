import 'dart:ui';

import 'package:ini/ini.dart';

class CpuConfig {
  int maxFreq = 0;
  int minFreq = 0;
  String governor = "null";
  String energyPref = "null";
  int maxPerf = 0;
  int minPerf = 0;
  bool turboEnabled = false;

  CpuConfig.fromConfig(Config config) {
    this.maxFreq = int.parse(config.get("Power", "CpuMaxFreq"));
    this.minFreq = int.parse(config.get("Power", "CpuMinFreq"));
    this.governor = config.get("Power", "CpuScalingGovernor");
    this.energyPref = config.get("Power", "CpuEnergyPreference");
    this.maxPerf = int.parse(config.get("Power", "CpuMaxPerf"));
    this.minPerf = int.parse(config.get("Power", "CpuMinPerf"));
    this.turboEnabled =
        config.get("Power", "CpuTurboEnabled").toLowerCase() == "true";
  }

  CpuConfig.fromJson(Map<String, dynamic> json) {
    this.maxFreq = json["maxFrequency"];
    this.minFreq = json["minFrequency"];
    this.governor = json["governor"];
    this.energyPref = json["energyPreference"];
    this.maxPerf = json["maxPerformance"];
    this.minPerf = json["minPerformance"];
    this.turboEnabled = json["turbo"];
  }

  CpuConfig.empty() {
    maxFreq = 0;
    minFreq = 0;
    governor = "null";
    energyPref = "null";
    maxPerf = 0;
    minPerf = 0;
    turboEnabled = false;
  }

  @override
  bool operator ==(Object other) {
    return other is CpuConfig &&
        this.maxFreq == other.maxFreq &&
        this.minFreq == other.minFreq &&
        this.governor == other.governor &&
        this.energyPref == other.energyPref &&
        this.maxPerf == other.maxPerf &&
        this.minPerf == other.minPerf &&
        this.turboEnabled == other.turboEnabled;
  }

  @override
  int get hashCode {
    return hashValues(
        maxFreq, minFreq, governor, energyPref, maxPerf, minPerf, turboEnabled);
  }
}
