import 'package:myapp/model/ProfileConfig.dart';
import 'package:myapp/model/profiles.dart';

abstract class ProfileService {
  Future<void> applyProfile(Profile profile);

  Future<ProfileConfig> readProfile();

  Future<void> setCoolerBoostEnabled(bool value);

  Future<bool> isCoolerBoostEnabled();

  Future<void> setChargingLimit();

  Future<int> readChargingLimit();
}
