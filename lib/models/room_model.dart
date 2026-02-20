import 'game_card_model.dart';

enum RoomStatus {
  waiting,
  playing,
  finished,
}

class RoomMember {
  final String userId;
  final String username;
  final String avatarEmoji;
  final bool isHost;
  bool isReady;

  RoomMember({
    required this.userId,
    required this.username,
    required this.avatarEmoji,
    this.isHost = false,
    this.isReady = false,
  });
}

class Room {
  final String id;
  final String code;
  final String hostId;
  final List<RoomMember> members;
  final List<GameCard> cards;
  final RoomStatus status;
  final int maxPlayers;
  final DateTime createdAt;

  const Room({
    required this.id,
    required this.code,
    required this.hostId,
    required this.members,
    required this.cards,
    this.status = RoomStatus.waiting,
    this.maxPlayers = 8,
    required this.createdAt,
  });

  bool get isFull => members.length >= maxPlayers;
  bool get canStart => members.isNotEmpty && cards.isNotEmpty;

  Room copyWith({
    String? id,
    String? code,
    String? hostId,
    List<RoomMember>? members,
    List<GameCard>? cards,
    RoomStatus? status,
    int? maxPlayers,
    DateTime? createdAt,
  }) {
    return Room(
      id: id ?? this.id,
      code: code ?? this.code,
      hostId: hostId ?? this.hostId,
      members: members ?? this.members,
      cards: cards ?? this.cards,
      status: status ?? this.status,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
