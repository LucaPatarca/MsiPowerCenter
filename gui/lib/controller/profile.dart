import 'dart:io';

import 'package:myapp/model/ProfileAdapter.dart';

import '../profiles.dart';
import 'package:ini/ini.dart';

class ProfileController {
  ProfileClass readProfile(Profile profile) {
    Config config = Config.fromStrings(File(profile.path).readAsLinesSync());
    return ProfileClass.fromConfig(config);
  }
}
