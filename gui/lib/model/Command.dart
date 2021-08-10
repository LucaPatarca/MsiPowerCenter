enum CommandCategory { Profile, CoolerBoost, ChargingLimit, AvailableProfiles }

extension CommandCategoryExtension on CommandCategory {
  String get name {
    return [
      "Profile",
      "CoolerBoost",
      "ChargingLimit",
      "AvailableProfiles"
    ][this.index];
  }
}

class Command {
  final ToGet? toGet;
  final ToSet? toSet;

  const Command({this.toGet, this.toSet});

  Map toJson() => {"toSet": toSet?.toJson(), "toGet": toGet?.toJson()};
}

class ToGet {
  final CommandCategory category;

  const ToGet(this.category);

  Map toJson() => {"category": category.name};
}

class ToSet {
  final CommandCategory category;
  final dynamic value;

  const ToSet(this.category, this.value);

  Map toJson() => {"category": category.name, "value": value};
}
