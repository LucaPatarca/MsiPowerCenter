import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myapp/model/RealTimeInfo.dart';
import 'package:myapp/service/RealTimeInfoService.dart';

class RealTimeInfoProvider with ChangeNotifier {
  RealTimeInfo _info = RealTimeInfo.empty();
  RealTimeInfoService _service = RealTimeInfoService();

  RealTimeInfo get info => _info;

  Future<void> _updateInfo() async {
    _info = await _service.getInfo();
    notifyListeners();
  }

  void start() {
    Timer.periodic(Duration(seconds: 2), (timer) async => await _updateInfo());
  }
}
