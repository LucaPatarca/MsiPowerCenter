import 'package:flutter/material.dart';

enum Profile { Performance, Balanced, Silent, Battery, Changing }

extension ProfileExtention on Profile {
  String get name {
    return [
      "Performance",
      "Balanced",
      "Silent",
      "Battery",
      "Changing"
    ][this.index];
  }

  String get path {
    return "/opt/MsiPowerCenter/profiles/" +
        [
          "performance",
          "balanced",
          "silent",
          "battery",
          "changing"
        ][this.index] +
        ".ini";
  }

  IconData get icon {
    return [
      Icons.speed,
      Icons.equalizer,
      Icons.hearing_disabled,
      Icons.battery_full,
      Icons.speed
    ][this.index];
  }
}
