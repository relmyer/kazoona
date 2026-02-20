class AppUser {
  final String id;
  final String username;
  final String email;
  final String avatarEmoji;
  final int totalGamesPlayed;
  final int totalCardsScratched;

  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    this.avatarEmoji = '😎',
    this.totalGamesPlayed = 0,
    this.totalCardsScratched = 0,
  });

  AppUser copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarEmoji,
    int? totalGamesPlayed,
    int? totalCardsScratched,
  }) {
    return AppUser(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalCardsScratched: totalCardsScratched ?? this.totalCardsScratched,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatarEmoji': avatarEmoji,
      'totalGamesPlayed': totalGamesPlayed,
      'totalCardsScratched': totalCardsScratched,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      avatarEmoji: map['avatarEmoji'] ?? '😎',
      totalGamesPlayed: map['totalGamesPlayed'] ?? 0,
      totalCardsScratched: map['totalCardsScratched'] ?? 0,
    );
  }
}

// Available avatar emojis
const List<String> avatarEmojis = [
  '😎', '🤩', '🥳', '😄', '😊', '🤗',
  '🦁', '🐯', '🦊', '🐺', '🦝', '🐸',
  '🚀', '⚡', '🌟', '🔥', '💎', '🎯',
  '🎭', '🎪', '🎨', '🎬', '🎮', '🎲',
];
