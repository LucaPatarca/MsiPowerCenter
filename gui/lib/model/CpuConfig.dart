import 'package:ini/ini.dart';

class CpuConfig {
  int cpuMaxFreq = 0;
  int cpuMinFreq = 0;
  String cpuGovernor = "null";
  String cpuEnergyPref = "null";
  int cpuMaxPerf = 0;
  int cpuMinPerf = 0;
  bool cpuTurboEnabled = false;

  CpuConfig.fromConfig(Config config) {
    this.cpuMaxFreq = int.parse(config.get("Power", "CpuMaxFreq"));
    this.cpuMinFreq = int.parse(config.get("Power", "CpuMinFreq"));
    this.cpuGovernor = config.get("Power", "CpuScalingGovernor");
    this.cpuEnergyPref = config.get("Power", "CpuEnergyPreference");
    this.cpuMaxPerf = int.parse(config.get("Power", "CpuMaxPerf"));
    this.cpuMinPerf = int.parse(config.get("Power", "CpuMinPerf"));
    this.cpuTurboEnabled =
        config.get("Power", "CpuTurboEnabled").toLowerCase() == "true";
  }

  CpuConfig.empty() {
    cpuMaxFreq = 0;
    cpuMinFreq = 0;
    cpuGovernor = "null";
    cpuEnergyPref = "null";
    cpuMaxPerf = 0;
    cpuMinPerf = 0;
    cpuTurboEnabled = false;
  }
}
