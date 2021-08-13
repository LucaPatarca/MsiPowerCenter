import 'package:myapp/model/EcConfig.dart';

abstract class EcController {
  void applyConfig(EcConfig config);
  EcConfig readConfig();
  void setCoolerBoost(bool value);
  bool isCoolerBoostEnabled();
  void setChargingLimit(int value);
  int getChargingLimit();
}
