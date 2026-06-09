class DiscoverGame {
  final String id;
  final String name;
  final String genre;
  final double size; // in MB
  final double rating;
  final String developer;
  final String playStoreUrl;
  final String icon;
  final String description;
  final List<String> screenshots;

  const DiscoverGame({
    required this.id,
    required this.name,
    required this.genre,
    required this.size,
    required this.rating,
    required this.developer,
    required this.playStoreUrl,
    required this.icon,
    required this.description,
    required this.screenshots,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'genre': genre,
      'size': size,
      'rating': rating,
      'developer': developer,
      'playStoreUrl': playStoreUrl,
      'icon': icon,
      'description': description,
      'screenshots': screenshots,
    };
  }

  factory DiscoverGame.fromJson(Map<String, dynamic> json) {
    return DiscoverGame(
      id: json['id'] as String,
      name: json['name'] as String,
      genre: json['genre'] as String,
      size: (json['size'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      developer: json['developer'] as String,
      playStoreUrl: json['playStoreUrl'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String,
      screenshots: List<String>.from(json['screenshots']),
    );
  }
}

// Sample Database
final List<DiscoverGame> discoverGamesDatabase = [
  const DiscoverGame(
    id: 'com.activision.callofduty.shooter',
    name: 'Call of Duty Mobile',
    genre: 'FPS',
    size: 2500,
    rating: 4.8,
    developer: 'Activision Publishing, Inc.',
    playStoreUrl: 'https://play.google.com/store/apps/details?id=com.activision.callofduty.shooter',
    icon: '🎮',
    description: 'Call of Duty®: Mobile brings the thrilling FPS action of the franchise to mobile devices.',
    screenshots: [],
  ),
  const DiscoverGame(
    id: 'com.supercell.brawlstars',
    name: 'Brawl Stars',
    genre: 'Action',
    size: 800,
    rating: 4.6,
    developer: 'Supercell',
    playStoreUrl: 'https://play.google.com/store/apps/details?id=com.supercell.brawlstars',
    icon: '⭐',
    description: 'Fast-paced 3v3 multiplayer and battle royale made for mobile!',
    screenshots: [],
  ),
  const DiscoverGame(
    id: 'com.ea.gp.fifamobile',
    name: 'FC Mobile',
    genre: 'Sports',
    size: 1200,
    rating: 4.5,
    developer: 'ELECTRONIC ARTS',
    playStoreUrl: 'https://play.google.com/store/apps/details?id=com.ea.gp.fifamobile',
    icon: '⚽',
    description: 'Build your Ultimate Team™ and play authentic football.',
    screenshots: [],
  ),
  const DiscoverGame(
    id: 'com.mojang.minecraftpe',
    name: 'Minecraft',
    genre: 'Arcade',
    size: 900,
    rating: 4.7,
    developer: 'Mojang',
    playStoreUrl: 'https://play.google.com/store/apps/details?id=com.mojang.minecraftpe',
    icon: '🟫',
    description: 'Explore infinite worlds and build everything from the simplest of homes to the grandest of castles.',
    screenshots: [],
  ),
];
