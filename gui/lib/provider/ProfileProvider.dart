import 'package:flutter/material.dart';
import 'package:myapp/model/ProfileConfig.dart';
import 'package:myapp/service/ProfileService.dart';

import '../model/profiles.dart';

class ProfileProvider with ChangeNotifier {
  ProfileConfig _profile = ProfileConfig.empty();
  Profile _selection = Profile.Changing;
  ProfileService service = new ProfileService();

  ProfileProvider() {
    readProfile();
  }

  void setProfileSelection(Profile profile) {
    this._selection = profile;
    notifyListeners();
  }

  Profile getProfileSelection() {
    return _selection;
  }

  Future<ProfileConfig> readProfile() async {
    _profile = await service.getProfile();
    notifyListeners();
    return _profile;
  }

  ProfileConfig getCurrentProfile() {
    return _profile;
  }

  Future<void> setProfile(Profile profile) async {
    _profile = await service.setProfile(profile);
    setProfileSelection(profile);
    notifyListeners();
  }

  Future<void> toggleCoolerBoost() async {
    _profile.ecConfig.coolerBoostEnabled = await service
        .setCoolerBoostEnabled(!_profile.ecConfig.coolerBoostEnabled);
    notifyListeners();
  }
}
