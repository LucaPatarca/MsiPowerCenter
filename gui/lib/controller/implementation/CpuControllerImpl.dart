import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:myapp/controller/interface/CpuController.dart';
import 'package:myapp/model/CpuConfig.dart';

class CpuControllerImpl implements CpuController {
  final CPUFREQ_PATH = kDebugMode == true
      ? "/home/luca/MsiPowerCenter/mockFiles/cpufreq"
      : "/sys/devices/system/cpu/";
  final SCALING_MAX_FREQ = "/cpufreq/scaling_max_freq";
  final SCALING_MIN_FREQ = "/cpufreq/scaling_min_freq";
  final SCALING_GOVERNOR = "/cpufreq/scaling_governor";
  final CPUINFO_MAX_FREQ = "/cpufreq/cpuinfo_max_freq";
  final CPUINFO_MIN_FREQ = "/cpufreq/cpuinfo_min_freq";
  final SCALING_AVAILABLE_GOVERNORS = "/cpufreq/scaling_available_governors";
  final ENERGY_PREF = "/cpufreq/energy_performance_preference";
  final ENERGY_AVAILABLE_PREFS =
      "/cpufreq/energy_performance_available_preferences";
  final PSTATE_PATH = kDebugMode == true
      ? "/home/luca/MsiPowerCenter/mockFiles/intel_pstate"
      : "/sys/devices/system/cpu/intel_pstate";
  final PSTATE_MAX_PERF = "/max_perf_pct";
  final PSTATE_MIN_PERF = "/min_perf_pct";
  final PSTATE_NO_TURBO = "//no_turbo";

  void applyConfig(CpuConfig config) {
    _writeStringForCpus(SCALING_MAX_FREQ, config.maxFreq.toString());
    _writeStringForCpus(SCALING_MIN_FREQ, config.minFreq.toString());
    //TODO controllare che il governor e energypref siano disponibili
    _writeStringForCpus(SCALING_GOVERNOR, config.governor.toString());
    _writeStringForCpus(ENERGY_PREF, config.energyPref.toString());
    _writeInt(PSTATE_PATH + PSTATE_MAX_PERF, config.maxPerf);
    _writeInt(PSTATE_PATH + PSTATE_MIN_PERF, config.minPerf);
    _writeInt(PSTATE_PATH + PSTATE_NO_TURBO, config.turboEnabled ? 0 : 1);
  }

  CpuConfig readConfig() {
    var config = CpuConfig.empty();
    config.maxFreq = _readInt(CPUFREQ_PATH + "/cpu0" + SCALING_MAX_FREQ);
    config.minFreq = _readInt(CPUFREQ_PATH + "/cpu0" + SCALING_MIN_FREQ);
    config.maxPerf = _readInt(PSTATE_PATH + PSTATE_MAX_PERF);
    config.minPerf = _readInt(PSTATE_PATH + PSTATE_MIN_PERF);
    config.turboEnabled = _readInt(PSTATE_PATH + PSTATE_NO_TURBO) == 0;
    config.governor = _readString(CPUFREQ_PATH + "/cpu0" + SCALING_GOVERNOR);
    config.energyPref = _readString(CPUFREQ_PATH + "/cpu0" + ENERGY_PREF);
    return config;
  }

  int _readInt(String path) {
    return int.parse(_readString(path));
  }

  String _readString(String path) {
    var file = File(path);
    return file.readAsStringSync();
  }

  void _writeStringForCpus(String path, String value) {
    var regex = RegExp(r'/cpu\d+');
    for (var cpu in Directory(CPUFREQ_PATH).listSync().where((element) =>
        element.statSync().type == FileSystemEntityType.directory &&
        regex.hasMatch(element.path))) {
      var file = File(cpu.path + path);
      file.writeAsStringSync(value);
    }
  }

  void _writeInt(String path, int value) {
    var file = File(path);
    file.writeAsStringSync(value.toString());
  }
}
