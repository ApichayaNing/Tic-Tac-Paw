enum Team { cat, dog }
enum Mark { x, o }
enum Difficulty { easy, medium, hard }

/// Used to pass arguments into the GamePage
class GameArgs {
  final Team team;
  final Mark playerMark;
  final Difficulty difficulty;

  const GameArgs({
    required this.team,
    required this.playerMark,
    required this.difficulty,
  });
}
