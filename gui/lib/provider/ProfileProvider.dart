import 'package:flutter/material.dart';
import 'package:myapp/model/ProfileAdapter.dart';
import 'package:myapp/service/ProfileService.dart';

import '../profiles.dart';

class ProfileProvider with ChangeNotifier {
  ProfileClass _profile = ProfileClass.empty();
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

  Future<ProfileClass> readProfile() async {
    _profile = await service.getProfile();
    notifyListeners();
    return _profile;
  }

  ProfileClass getCurrentProfile() {
    return _profile;
  }

  Future<void> setProfile(Profile profile) async {
    _profile = await service.setProfile(profile);
    setProfileSelection(profile);
    notifyListeners();
  }

  Future<void> toggleCoolerBoost() async {
    _profile.coolerBoostEnabled =
        await service.setCoolerBoostEnabled(!_profile.coolerBoostEnabled);
    notifyListeners();
  }
}
