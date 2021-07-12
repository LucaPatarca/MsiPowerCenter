import 'dart:io';
import 'package:myapp/model/ProfileAdapter.dart';

class EcController {
  final EC_PATH = "/sys/kernel/debug/ec/ec0/io";
  final CPU_TEMP_START = 0x6A;
  final CPU_TEMP_END = 0x70;
  final GPU_TEMP_START = 0x82;
  final GPU_TEMP_END = 0x88;
  final REALTIME_CPU_TEMP = 0x68;
  final REALTIME_GPU_TEMP = 0x80;
  final CPU_FAN_START = 0x72;
  final CPU_FAN_END = 0x78;
  final GPU_FAN_START = 0x8A;
  final GPU_FAN_END = 0x90;
  final REALTIME_CPU_FAN_SPEED = 0x71;
  final REALTIME_GPU_FAN_SPEED = 0x89;
  final COOLER_BOOST_ADDR = 0x98;
  final CHARGING_THRESHOLD_ADDR = 0xEF;
  final FAN_MODE_ADDR = 0xF4;
  final COOLER_BOOST_ON = 0x80;
  final COOLER_BOOST_OFF = 0x00;

  void applyProfile(ProfileClass profile) async {
    var ec = _openEC();
    try {
      ec.setPositionSync(CPU_TEMP_START);
      ec.writeFromSync(profile.cpuFanConfig.map((e) => e.temp).toList());
      ec.setPositionSync(CPU_FAN_START);
      ec.writeFromSync(profile.cpuFanConfig.map((e) => e.speed).toList());

      ec.setPositionSync(GPU_TEMP_START);
      ec.writeFromSync(profile.gpuFanConfig.map((e) => e.temp).toList());
      ec.setPositionSync(GPU_FAN_START);
      ec.writeFromSync(profile.gpuFanConfig.map((e) => e.speed).toList());

      ec.setPositionSync(COOLER_BOOST_ADDR);
      ec.writeByteSync(
          profile.coolerBoostEnabled ? COOLER_BOOST_ON : COOLER_BOOST_OFF);
    } catch (e) {
      print(e);
    }
  }

  RandomAccessFile _openEC() {
    return File(EC_PATH).openSync(mode: FileMode.write);
  }
}
