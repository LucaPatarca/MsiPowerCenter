import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:myapp/model/RealTimeInfo.dart';

class RealTimeInfoService {
  final realtime = File(
      kDebugMode ? "../realtime_debug" : "/opt/MsiPowerCenter/pipes/realtime");

  Future<RealTimeInfo> getInfo() async {
    var string = await _readOutput();
    var length = string.length;
    Map<String, dynamic> json = jsonDecode(string);
    return RealTimeInfo.fromJson(json);
  }

  Future<String> _readOutput() async {
    return await realtime.readAsString();
  }
}
