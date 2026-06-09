import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hone_mobile/core/models/game_profile.dart';
import 'package:hone_mobile/core/app/providers/overlay_settings_provider.dart';

final gameProfilesProvider = Provider<List<GameProfile>>((ref) {
  // Temporary in-memory sample data. Replace with persistence later.
  return [
    GameProfile(
      id: '2048',
      displayName: '2048',
      playTimeMinutes: 142,
      achievementsUnlocked: 3,
      overlayEnabled: true,
      overlayOpacity: 0.9,
      overlayModules: {'fps': true, 'ram': true, 'cpu': true, 'temp': false, 'battery': true},
    ),
    GameProfile(
      id: 'sudoku',
      displayName: 'Sudoku',
      playTimeMinutes: 80,
      achievementsUnlocked: 1,
      overlayEnabled: false,
    ),
  ];
});

/// Apply a game profile's overlay settings to the global overlay settings provider.
Future<void> applyProfileOverlay(WidgetRef ref, GameProfile profile) async {
  final notifier = ref.read(overlaySettingsProvider.notifier);
  if (profile.overlayEnabled != null) notifier.setEnabled(profile.overlayEnabled!);
  if (profile.overlayOpacity != null) notifier.setOpacity(profile.overlayOpacity!);
  if (profile.overlayModules != null) {
    for (final e in profile.overlayModules!.entries) {
      notifier.setModuleEnabled(e.key, e.value);
    }
  }
}
