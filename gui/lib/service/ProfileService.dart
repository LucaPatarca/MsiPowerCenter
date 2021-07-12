import 'package:myapp/controller/ec.dart';
import 'package:myapp/controller/lib.dart';
import 'package:myapp/controller/profile.dart';
import 'package:myapp/model/ProfileAdapter.dart';

import '../profiles.dart';

class ProfileService {
  LibController controller = new LibController();
  final ecController = new EcController();

  Future<ProfileClass> setProfile(Profile profile) async {
    var profileClass = ProfileController().readProfile(profile);
    await ecController.applyProfile(profileClass);
    return await controller.getProfile();
  }

  Future<ProfileClass> getProfile() async {
    return await controller.getProfile();
  }

  Future<bool> setCoolerBoostEnabled(bool value) async {
    await controller.setCoolerBoost(value);
    return await controller.getCoolerBoost();
  }
}
