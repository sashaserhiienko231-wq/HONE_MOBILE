
/// Abstract base class for all instant games.
/// Provides a simple lifecycle that each game engine can implement.
abstract class GameEngine {
  /// Called once when the game is created.
  void init();

  /// Called on every frame, `dt` is the time delta in seconds.
  void update(double dt);

  /// Called when the UI needs to be rebuilt.
  /// Implementations should call `notifyListeners` if extending `ChangeNotifier`.
  void render();

  /// Called when the game is disposed.
  void dispose();
}
