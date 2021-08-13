import 'package:myapp/model/CpuConfig.dart';

abstract class CpuController {
  void applyConfig(CpuConfig config);

  CpuConfig readConfig();
}
