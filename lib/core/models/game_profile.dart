class GameProfile {
  final String id;
  final String displayName;
  final int playTimeMinutes;
  final int achievementsUnlocked;
  final bool? overlayEnabled;
  final double? overlayOpacity;
  final Map<String, bool>? overlayModules;

  GameProfile({
    required this.id,
    required this.displayName,
    this.playTimeMinutes = 0,
    this.achievementsUnlocked = 0,
    this.overlayEnabled,
    this.overlayOpacity,
    this.overlayModules,
  });
}
