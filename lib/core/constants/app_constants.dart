class AppConstants {
  // App Info
  static const String appName = 'Kazoona';
  static const String appVersion = '1.0.0';

  // Room
  static const int roomCodeLength = 5;
  static const int maxPlayersPerRoom = 8;
  static const int minCardsPerGame = 1;
  static const int maxCardsPerGame = 20;
  static const int defaultCardsPerGame = 6;

  // Card
  static const int scratchThreshold = 60; // % to consider scratched

  // Animation durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animShort = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 400);
  static const Duration animLong = Duration(milliseconds: 600);

  // Emojis for cards
  static const List<String> cardEmojis = [
    '🎉', '⭐', '🎯', '🏆', '💎', '🎮', '🎲', '🃏',
    '🌟', '🎸', '🔥', '⚡', '🌈', '🦄', '🐉', '🎭',
    '🍀', '🎪', '🎨', '🎬', '🚀', '🌙', '☀️', '🎁',
    '💫', '🎊', '🥳', '🤩', '😎', '🦁', '🐯', '🦊',
  ];

  // Predefined activities/events for cards
  static const List<String> defaultActivities = [
    '5 dakika dans et!',
    'Bir şarkı söyle!',
    'Arkadaşına iltifat et!',
    'Bir şaka anlat!',
    'En komik sesin çıkar!',
    'Hayran olduğun birini taklit et!',
    'Bir dilekte bulun!',
    'Grubun lideri ol!',
    'Bedava tur atla!',
    'Bir şey anlat!',
    'Emoji zinciri kır!',
    'Gizli yetenek göster!',
    'Sürpriz hediye kazan!',
    '30 saniye duraksatma!',
    'Favori anını paylaş!',
    'Gruba özel bir şey öğret!',
    'Bir meydan okuma seç!',
    'Kısa bir film çek!',
    'En iyi pozunu ver!',
    'Ödül kazan!',
  ];

  // Room activities
  static const List<String> roomActivities = [
    'Karaoke',
    'Trivia Quiz',
    'Çizim Oyunu',
    'Rol Yapma',
    'Hikaye Anlatımı',
    'Müzik Yarışması',
    'Yemek Meydan Okuması',
    'Film Gecesi',
  ];
}
