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
    Profile selection = Profile.Changing;
    var i = 0;
    while (selection == Profile.Changing && i < Profile.values.length) {
      try {
        selection = Profile.values[i++];
        Config config =
            Config.fromStrings(File(selection.path).readAsLinesSync());
        var toTest = ProfileConfig.fromConfig(config);
        if (_profile != toTest) selection = Profile.Changing;
      } catch (e) {
        selection = Profile.Changing;
      }
    }
    _selection = selection;
    notifyListeners();
    return _profile;
  }

  ProfileConfig getCurrentProfile() {
    return _profile;
  }

  Future<void> setProfile(Profile profile) async {
    await service.applyProfile(profile);
    _profile = await service.readProfile();
    setProfileSelection(profile);
    notifyListeners();
  }

  Future<void> toggleCoolerBoost() async {
    await service.setCoolerBoostEnabled(!_profile.ec.coolerBoostEnabled);
    _profile.ec.coolerBoostEnabled = await service.isCoolerBoostEnabled();
    notifyListeners();
  }
}
