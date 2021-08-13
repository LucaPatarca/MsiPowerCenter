import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:myapp/controller/interface/EcController.dart';
import 'package:myapp/model/FanConfig.dart';
import 'package:myapp/model/EcConfig.dart';

class EcControllerImpl implements EcController {
  static const EC_PATH = kDebugMode == true
      ? "/home/luca/MsiPowerCenter/mockFiles/io"
      : "/sys/kernel/debug/ec/ec0/io";
  static const CPU_TEMP_START = 0x6A;
  static const GPU_TEMP_START = 0x82;
  static const REALTIME_CPU_TEMP = 0x68;
  static const REALTIME_GPU_TEMP = 0x80;
  static const CPU_FAN_START = 0x72;
  static const GPU_FAN_START = 0x8A;
  static const REALTIME_CPU_FAN_SPEED = 0x71;
  static const REALTIME_GPU_FAN_SPEED = 0x89;
  static const COOLER_BOOST_ADDR = 0x98;
  static const CHARGING_THRESHOLD_ADDR = 0xEF;
  static const FAN_MODE_ADDR = 0xF4;
  static const COOLER_BOOST_ON = 0x80;
  static const COOLER_BOOST_OFF = 0x00;

  void applyConfig(EcConfig profile) {
    var ec = File(EC_PATH).openSync(mode: FileMode.write);
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
      ec.closeSync();
    } catch (e) {
      print(e);
    }
  }

  EcConfig readConfig() {
    var ec = File(EC_PATH).openSync(mode: FileMode.read);
    ec.setPositionSync(CPU_TEMP_START);
    var cpuTemps = ec.readSync(7);
    ec.setPositionSync(CPU_FAN_START);
    var cpuFans = ec.readSync(7);
    ec.setPositionSync(GPU_TEMP_START);
    var gpuTemps = ec.readSync(7);
    ec.setPositionSync(GPU_FAN_START);
    var gpuFans = ec.readSync(7);
    ec.setPositionSync(COOLER_BOOST_ADDR);
    var isCooolerBoostEnabled = ec.readByteSync() >= COOLER_BOOST_ON;
    ec.setPositionSync(CHARGING_THRESHOLD_ADDR);
    var chargingThreshold = ec.readByteSync() - 0x80;
    ec.closeSync();

    var profile = EcConfig.empty();
    profile = profile.copyWith(coolerBoost: isCooolerBoostEnabled);
    // profile.chargingThreshold = chargingThreshold;
    for (int i = 0; i < 7; i++) {
      profile.cpuFanConfig[i] = new FanConfig(cpuTemps[i], cpuFans[i]);
      profile.gpuFanConfig[i] = new FanConfig(gpuTemps[i], gpuFans[i]);
    }
    return profile;
  }

  void setCoolerBoost(bool value) {
    var ec = File(EC_PATH).openSync(mode: FileMode.append);
    ec.setPositionSync(COOLER_BOOST_ADDR);
    ec.writeByteSync(value ? COOLER_BOOST_ON : COOLER_BOOST_OFF);
    ec.closeSync();
  }

  bool isCoolerBoostEnabled() {
    var ec = File(EC_PATH).openSync(mode: FileMode.read);
    ec.setPositionSync(COOLER_BOOST_ADDR);
    var result = ec.readByteSync() >= COOLER_BOOST_ON;
    ec.closeSync();
    return result;
  }

  void setChargingLimit(int value) {
    var ec = File(EC_PATH).openSync(mode: FileMode.append);
    ec.setPositionSync(CHARGING_THRESHOLD_ADDR);
    ec.writeByteSync(value + 0x80);
    ec.closeSync();
  }

  int getChargingLimit() {
    var ec = File(EC_PATH).openSync(mode: FileMode.read);
    ec.setPositionSync(CHARGING_THRESHOLD_ADDR);
    var result = ec.readByteSync() - 0x80;
    ec.closeSync();
    return result;
  }
}
