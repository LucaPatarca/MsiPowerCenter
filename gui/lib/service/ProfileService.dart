import 'package:myapp/model/ProfileConfig.dart';
import 'package:myapp/model/profiles.dart';

abstract class ProfileService {
  Future<ProfileConfig> applyProfile(Profile profile);

  Future<ProfileConfig> readProfile();

  Future<bool> setCoolerBoostEnabled(bool value);

  Future<bool> isCoolerBoostEnabled();

  Future<int> setChargingLimit(int value);

  Future<int> readChargingLimit();
}
