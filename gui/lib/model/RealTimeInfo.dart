class RealTimeInfo {
  final int cpuTemp;
  final int gpuTemp;
  final int cpuFanSpeed;
  final int gpuFanSpeed;
  final int cpuFreq;

  RealTimeInfo(this.cpuTemp, this.gpuTemp, this.cpuFanSpeed, this.gpuFanSpeed,
      this.cpuFreq);

  RealTimeInfo.fromJson(Map<String, dynamic> json)
      : cpuTemp = json["cpu_temp"],
        gpuTemp = json["gpu_temp"],
        cpuFanSpeed = json["cpu_fan_speed"],
        gpuFanSpeed = json["gpu_fan_speed"],
        cpuFreq = json["freq"];

  const RealTimeInfo.empty()
      : cpuTemp = 0,
        gpuTemp = 0,
        cpuFanSpeed = 0,
        gpuFanSpeed = 0,
        cpuFreq = 0;
}
