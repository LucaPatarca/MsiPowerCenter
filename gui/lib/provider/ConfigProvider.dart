import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModel with ChangeNotifier {
  ThemeMode _mode;
  String _fanCurveSelection = "cpu";
  late SharedPreferences prefs;
  ThemeMode get mode => _mode;
  String get fanCurveSelection => _fanCurveSelection;

  void nextFanCurveSelection() {
    if (_fanCurveSelection == "cpu")
      _fanCurveSelection = "gpu";
    else if (_fanCurveSelection == "gpu")
      _fanCurveSelection = "all";
    else if (_fanCurveSelection == "all") _fanCurveSelection = "cpu";
    prefs.setString("fanCurveSelection", _fanCurveSelection);
    notifyListeners();
  }

  ThemeModel({ThemeMode mode = ThemeMode.light}) : _mode = mode;

  Future<void> loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    bool dark = prefs.getBool("dark") ?? false;
    _mode = dark ? ThemeMode.dark : ThemeMode.light;
    _fanCurveSelection = prefs.getString("fanCurveSelection") ?? "cpu";
  }

  void toggleMode() {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    bool dark = _mode == ThemeMode.dark;
    prefs.setBool("dark", dark);
    notifyListeners();
  }
}
