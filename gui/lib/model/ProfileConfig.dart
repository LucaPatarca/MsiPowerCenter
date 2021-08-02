import 'package:flutter/material.dart';
import 'package:ini/ini.dart';
import 'package:myapp/model/CpuConfig.dart';
import 'package:myapp/model/EcConfig.dart';

class ProfileConfig {
  String name = "";
  CpuConfig cpu = CpuConfig.empty();
  EcConfig ec = EcConfig.empty();

  ProfileConfig(CpuConfig cpuConfig, EcConfig ecConfig) {
    this.name = "Unknown";
    this.cpu = cpuConfig;
    this.ec = ecConfig;
  }

  ProfileConfig.fromJson(Map<String, dynamic> json) {
    this.name = "Current";
    this.cpu = CpuConfig.fromJson(json);
    this.ec = EcConfig.fromJson(json);
  }

  ProfileConfig.fromConfig(Config config) {
    this.name = config.get("General", "Name");
    this.cpu = CpuConfig.fromConfig(config);
    this.ec = EcConfig.fromConfig(config);
  }

  ProfileConfig.empty() {
    name = "empty";
    cpu = CpuConfig.empty();
    ec = EcConfig.empty();
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileConfig &&
        this.cpu == other.cpu &&
        this.ec == other.ec;
  }

  @override
  int get hashCode => hashValues(ec, cpu);
}
