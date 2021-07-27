import 'package:ini/ini.dart';
import 'package:myapp/model/CpuConfig.dart';
import 'package:myapp/model/EcConfig.dart';

class ProfileConfig {
  String name = "";
  CpuConfig cpuConfig = CpuConfig.empty();
  EcConfig ecConfig = EcConfig.empty();

  ProfileConfig(CpuConfig cpuConfig, EcConfig ecConfig) {
    this.name = "Unknown";
    this.cpuConfig = cpuConfig;
    this.ecConfig = ecConfig;
  }

  ProfileConfig.fromConfig(Config config) {
    this.name = config.get("General", "Name");
    this.cpuConfig = CpuConfig.fromConfig(config);
    this.ecConfig = EcConfig.fromConfig(config);
  }

  ProfileConfig.empty() {
    name = "empty";
    cpuConfig = CpuConfig.empty();
    ecConfig = EcConfig.empty();
  }
}
