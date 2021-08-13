import 'dart:ui';

import 'package:ini/ini.dart';

class CpuConfig {
  final int maxFreq;
  final int minFreq;
  final String governor;
  final String energyPref;
  final int maxPerf;
  final int minPerf;
  final bool turboEnabled;

  CpuConfig.fromConfig(Config config)
      : maxFreq = int.parse(config.get("Power", "CpuMaxFreq") ?? "0"),
        minFreq = int.parse(config.get("Power", "CpuMinFreq") ?? "0"),
        governor = config.get("Power", "CpuScalingGovernor") ?? "unknown",
        energyPref = config.get("Power", "CpuEnergyPreference") ?? "unknown",
        maxPerf = int.parse(config.get("Power", "CpuMaxPerf") ?? "0"),
        minPerf = int.parse(config.get("Power", "CpuMinPerf") ?? "0"),
        turboEnabled =
            config.get("Power", "CpuTurboEnabled")?.toLowerCase() == "true";

  CpuConfig.fromJson(Map<String, dynamic> json)
      : maxFreq = json["max_freq"],
        minFreq = json["min_freq"],
        governor = json["governor"],
        energyPref = json["energy_pref"],
        maxPerf = json["max_perf"],
        minPerf = json["min_perf"],
        turboEnabled = json["turbo"];

  const CpuConfig.empty()
      : maxFreq = 0,
        minFreq = 0,
        governor = "null",
        energyPref = "null",
        maxPerf = 0,
        minPerf = 0,
        turboEnabled = false;

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
