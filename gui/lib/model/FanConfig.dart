import 'package:flutter/material.dart';

class FanConfig {
  const FanConfig(this.temp, this.speed);
  final int temp;
  final int speed;

  @override
  bool operator ==(Object other) {
    return other is FanConfig &&
        this.temp == other.temp &&
        this.speed == other.speed;
  }

  @override
  int get hashCode {
    return hashValues(temp, speed);
  }
}
