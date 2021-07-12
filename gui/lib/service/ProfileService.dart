import 'package:myapp/controller/lib.dart';
import 'package:myapp/model/ProfileAdapter.dart';

import '../profiles.dart';

class ProfileService {
  LibController controller = new LibController();

  Future<ProfileAdapter> setProfile(Profile profile) async {
    await controller.setProfile(profile);
    return await controller.getProfile();
  }

  Future<ProfileAdapter> getProfile() async {
    return await controller.getProfile();
  }

  Future<bool> setCoolerBoostEnabled(bool value) async {
    await controller.setCoolerBoost(value);
    return await controller.getCoolerBoost();
  }
}
