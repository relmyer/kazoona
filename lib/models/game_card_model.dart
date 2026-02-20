import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum CardState {
  hidden,     // Kazınmamış hali
  scratching, // Kazınıyor
  revealed,   // Kazınmış hali
}

enum CardRarity {
  common,
  rare,
  epic,
  legendary,
}

class GameCard {
  final String id;
  final String name;
  final String activity;
  final String emoji;
  final Color color;
  final CardRarity rarity;
  CardState state;
  double scratchProgress; // 0.0 - 1.0

  GameCard({
    required this.id,
    required this.name,
    required this.activity,
    required this.emoji,
    required this.color,
    this.rarity = CardRarity.common,
    this.state = CardState.hidden,
    this.scratchProgress = 0.0,
  });

  bool get isRevealed => state == CardState.revealed;
  bool get isHidden => state == CardState.hidden;
  bool get isScratching => state == CardState.scratching;

  Color get rarityColor {
    switch (rarity) {
      case CardRarity.common:
        return AppColors.greyLight;
      case CardRarity.rare:
        return AppColors.cardBlue;
      case CardRarity.epic:
        return AppColors.cardPurple;
      case CardRarity.legendary:
        return AppColors.cardGold;
    }
  }

  String get rarityLabel {
    switch (rarity) {
      case CardRarity.common:
        return 'NORMAL';
      case CardRarity.rare:
        return 'NADİR';
      case CardRarity.epic:
        return 'EPİK';
      case CardRarity.legendary:
        return 'EFSANE';
    }
  }

  GameCard copyWith({
    String? id,
    String? name,
    String? activity,
    String? emoji,
    Color? color,
    CardRarity? rarity,
    CardState? state,
    double? scratchProgress,
  }) {
    return GameCard(
      id: id ?? this.id,
      name: name ?? this.name,
      activity: activity ?? this.activity,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      rarity: rarity ?? this.rarity,
      state: state ?? this.state,
      scratchProgress: scratchProgress ?? this.scratchProgress,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'activity': activity,
      'emoji': emoji,
      'color': color.toARGB32(),
      'rarity': rarity.index,
      'state': state.index,
    };
  }

  factory GameCard.fromMap(Map<String, dynamic> map) {
    return GameCard(
      id: map['id'],
      name: map['name'],
      activity: map['activity'],
      emoji: map['emoji'],
      color: Color(map['color']),
      rarity: CardRarity.values[map['rarity']],
      state: CardState.values[map['state']],
    );
  }
}
