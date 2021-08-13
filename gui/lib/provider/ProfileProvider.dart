import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ini/ini.dart';
import 'package:myapp/model/ProfileConfig.dart';
import 'package:myapp/service/ProfileService.dart';
import 'package:myapp/service/ProfileServiceDaemon.dart';

import '../model/profiles.dart';

class ProfileProvider with ChangeNotifier {
  ProfileConfig _profile = ProfileConfig.empty();
  Profile _selection = Profile.Changing;
  ProfileService service = new ProfileServiceDaemon();

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
    _profile = await service.readProfile();
    _selection = Profile.values.firstWhere(
        (element) => element.name == _profile.name,
        orElse: () => Profile.Changing);
    notifyListeners();
    return _profile;
  }

  ProfileConfig getCurrentProfile() {
    return _profile;
  }

  Future<void> setProfile(Profile profile) async {
    _profile = await service.applyProfile(profile);
    setProfileSelection(profile);
    notifyListeners();
  }

  Future<void> toggleCoolerBoost() async {
    bool result =
        await service.setCoolerBoostEnabled(!_profile.ec.coolerBoostEnabled);
    _profile = _profile.copyWith(coolerBoost: result);
    notifyListeners();
  }
}
