import 'package:flutter/material.dart';
import 'package:ini/ini.dart';
import 'package:myapp/model/CpuConfig.dart';
import 'package:myapp/model/EcConfig.dart';

class ProfileConfig {
  final String name;
  final CpuConfig cpu;
  final EcConfig ec;

  const ProfileConfig(this.cpu, this.ec, {this.name = "unknown"});

  ProfileConfig.fromJson(Map<String, dynamic> json)
      : cpu = CpuConfig.fromJson(json["cpu"]),
        ec = EcConfig.fromJson(json["ec"]),
        name = json["name"];

  ProfileConfig.fromConfig(Config config)
      : name = config.get("General", "Name") ?? "unknown",
        cpu = CpuConfig.fromConfig(config),
        ec = EcConfig.fromConfig(config);

  const ProfileConfig.empty()
      : name = "empty",
        cpu = const CpuConfig.empty(),
        ec = const EcConfig.empty();

  ProfileConfig copyWith({bool? coolerBoost}) {
    if (coolerBoost != null) {
      return ProfileConfig(cpu, ec.copyWith(coolerBoost: coolerBoost),
          name: name);
    }
    return this;
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
