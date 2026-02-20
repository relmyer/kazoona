import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/game_card_model.dart';
import '../models/room_model.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';

class GameProvider extends ChangeNotifier {
  Room? _currentRoom;
  List<GameCard> _soloCards = [];
  bool _isLoading = false;
  int _currentTurnIndex = 0;

  Room? get currentRoom => _currentRoom;
  List<GameCard> get soloCards => _soloCards;
  bool get isLoading => _isLoading;
  bool get isInRoom => _currentRoom != null;
  int get currentTurnIndex => _currentTurnIndex;

  RoomMember? get currentPlayer {
    if (_currentRoom == null || _currentRoom!.members.isEmpty) return null;
    return _currentRoom!.members[_currentTurnIndex % _currentRoom!.members.length];
  }

  bool isMyTurn(String userId) => currentPlayer?.userId == userId;

  /// Move to next player's turn
  void nextTurn() {
    if (_currentRoom == null || _currentRoom!.members.isEmpty) return;
    _currentTurnIndex = (_currentTurnIndex + 1) % _currentRoom!.members.length;
    notifyListeners();
  }

  final _uuid = const Uuid();
  final _rng = Random();

  // Card accent colors
  static const List<Color> _cardColors = [
    AppColors.cardOrange,
    AppColors.cardGold,
    AppColors.cardGreen,
    AppColors.cardBlue,
    AppColors.cardPurple,
    AppColors.cardPink,
    AppColors.cardRed,
  ];

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(5, (_) => chars[_rng.nextInt(chars.length)]).join();
  }

  List<GameCard> _generateRandomCards(int count) {
    final activities = List.from(AppConstants.defaultActivities)..shuffle(_rng);
    final emojis = List.from(AppConstants.cardEmojis)..shuffle(_rng);

    return List.generate(count, (i) {
      return GameCard(
        id: _uuid.v4(),
        name: 'Kazoona #${i + 1}',
        activity: activities[i % activities.length],
        emoji: emojis[i % emojis.length],
        color: _cardColors[i % _cardColors.length],
        rarity: _randomRarity(),
      );
    });
  }

  CardRarity _randomRarity() {
    final r = _rng.nextDouble();
    if (r < 0.05) return CardRarity.legendary;
    if (r < 0.15) return CardRarity.epic;
    if (r < 0.35) return CardRarity.rare;
    return CardRarity.common;
  }

  Future<Room> createRoom({
    required String hostId,
    required String hostUsername,
    required String hostAvatar,
    int cardCount = 6,
    List<GameCard>? customCards,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    final cards = customCards ?? _generateRandomCards(cardCount);
    final room = Room(
      id: _uuid.v4(),
      code: _generateRoomCode(),
      hostId: hostId,
      members: [
        RoomMember(
          userId: hostId,
          username: hostUsername,
          avatarEmoji: hostAvatar,
          isHost: true,
          isReady: true,
        ),
      ],
      cards: cards,
      createdAt: DateTime.now(),
    );

    _currentRoom = room;
    _currentTurnIndex = 0;
    _isLoading = false;
    notifyListeners();
    return room;
  }

  Future<bool> joinRoom({
    required String code,
    required String userId,
    required String username,
    required String avatarEmoji,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    if (code.length == 5) {
      final fakeRoom = Room(
        id: _uuid.v4(),
        code: code.toUpperCase(),
        hostId: 'host-1',
        members: [
          RoomMember(
            userId: 'host-1',
            username: 'Arkadaş',
            avatarEmoji: '🦁',
            isHost: true,
            isReady: true,
          ),
          RoomMember(
            userId: userId,
            username: username,
            avatarEmoji: avatarEmoji,
            isReady: false,
          ),
        ],
        cards: _generateRandomCards(6),
        createdAt: DateTime.now(),
      );
      _currentRoom = fakeRoom;
      _currentTurnIndex = 0;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void startSoloGame({int cardCount = 6, List<GameCard>? customCards}) {
    _soloCards = customCards ?? _generateRandomCards(cardCount);
    notifyListeners();
  }

  /// Reveal a card (called after scratch completes)
  void revealCard(String cardId, {bool solo = false}) {
    if (solo) {
      final idx = _soloCards.indexWhere((c) => c.id == cardId);
      if (idx == -1 || _soloCards[idx].isRevealed) return;
      _soloCards[idx].state = CardState.revealed;
      _soloCards[idx].scratchProgress = 1.0;
    } else {
      if (_currentRoom == null) return;
      final idx = _currentRoom!.cards.indexWhere((c) => c.id == cardId);
      if (idx == -1 || _currentRoom!.cards[idx].isRevealed) return;
      _currentRoom!.cards[idx].state = CardState.revealed;
      _currentRoom!.cards[idx].scratchProgress = 1.0;
    }
    notifyListeners();
  }

  void scratchCard(String cardId, double progress, {bool solo = false}) {
    if (solo) {
      final idx = _soloCards.indexWhere((c) => c.id == cardId);
      if (idx == -1 || _soloCards[idx].isRevealed) return;
      _soloCards[idx].scratchProgress = progress;
      if (_soloCards[idx].state == CardState.hidden) {
        _soloCards[idx].state = CardState.scratching;
      }
    } else {
      if (_currentRoom == null) return;
      final idx = _currentRoom!.cards.indexWhere((c) => c.id == cardId);
      if (idx == -1 || _currentRoom!.cards[idx].isRevealed) return;
      _currentRoom!.cards[idx].scratchProgress = progress;
      if (_currentRoom!.cards[idx].state == CardState.hidden) {
        _currentRoom!.cards[idx].state = CardState.scratching;
      }
    }
    notifyListeners();
  }

  void addCustomCard(GameCard card) {
    if (_currentRoom != null) {
      _currentRoom!.cards.add(card);
    } else {
      _soloCards.add(card);
    }
    notifyListeners();
  }

  void resetCards({bool solo = false}) {
    if (solo) {
      for (final c in _soloCards) {
        c.state = CardState.hidden;
        c.scratchProgress = 0;
      }
    } else {
      if (_currentRoom != null) {
        for (final c in _currentRoom!.cards) {
          c.state = CardState.hidden;
          c.scratchProgress = 0;
        }
        _currentTurnIndex = 0;
      }
    }
    notifyListeners();
  }

  void revealAllCards({bool solo = false}) {
    if (solo) {
      for (final c in _soloCards) {
        c.state = CardState.revealed;
        c.scratchProgress = 1.0;
      }
    } else {
      if (_currentRoom != null) {
        for (final c in _currentRoom!.cards) {
          c.state = CardState.revealed;
          c.scratchProgress = 1.0;
        }
      }
    }
    notifyListeners();
  }

  void leaveRoom() {
    _currentRoom = null;
    _currentTurnIndex = 0;
    notifyListeners();
  }

  List<GameCard> getCards({bool solo = false}) {
    if (solo) return _soloCards;
    return _currentRoom?.cards ?? [];
  }

  int get revealedCount {
    final cards = _currentRoom?.cards ?? _soloCards;
    return cards.where((c) => c.isRevealed).length;
  }

  int get totalCards {
    final cards = _currentRoom?.cards ?? _soloCards;
    return cards.length;
  }

  bool get allRevealed {
    final cards = _currentRoom?.cards ?? _soloCards;
    return cards.isNotEmpty && cards.every((c) => c.isRevealed);
  }
}
