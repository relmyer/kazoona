import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/game_card_model.dart';
import '../../../providers/game_provider.dart';

class CardCreatorScreen extends StatefulWidget {
  const CardCreatorScreen({super.key});

  @override
  State<CardCreatorScreen> createState() => _CardCreatorScreenState();
}

class _CardCreatorScreenState extends State<CardCreatorScreen> {
  final _nameController = TextEditingController();
  final _activityController = TextEditingController();
  final _uuid = const Uuid();

  Color _selectedColor = AppColors.cardGold;
  String _selectedEmoji = '⭐';
  CardRarity _selectedRarity = CardRarity.common;

  static const List<Color> _colorOptions = [
    AppColors.cardGold,
    AppColors.cardOrange,
    AppColors.cardPink,
    AppColors.cardPurple,
    AppColors.cardGreen,
    AppColors.cardBlue,
    AppColors.cardRed,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _activityController.dispose();
    super.dispose();
  }

  void _saveCard() {
    if (_nameController.text.isEmpty || _activityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kart adı ve aktivite gerekli!')),
      );
      return;
    }

    final card = GameCard(
      id: _uuid.v4(),
      name: _nameController.text.trim(),
      activity: _activityController.text.trim(),
      emoji: _selectedEmoji,
      color: _selectedColor,
      rarity: _selectedRarity,
    );

    context.read<GameProvider>().addCustomCard(card);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 "${card.name}" eklendi!'),
        backgroundColor: AppColors.success,
      ),
    );

    // Reset form
    _nameController.clear();
    _activityController.clear();
    setState(() {
      _selectedEmoji = '⭐';
      _selectedColor = AppColors.cardGold;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1628), Color(0xFF231E35)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card preview
                      Center(child: _buildCardPreview()),
                      const SizedBox(height: 28),
                      // Form
                      _buildForm(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Bitti'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: _saveCard,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              colors: AppColors.primaryGradient,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '+ Kart Ekle',
                              style: TextStyle(
                                color: Color(0xFF1A1628),
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Kart Oluştur',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildCardPreview() {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(begin: _selectedColor, end: _selectedColor),
      duration: const Duration(milliseconds: 300),
      builder: (context, color, _) {
        return Container(
          width: 160,
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _selectedColor,
                _selectedColor.withOpacity(0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _selectedColor.withOpacity(0.5),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),
              ),
              // Card content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rarity badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _selectedRarity == CardRarity.common
                            ? 'KAZOONA'
                            : _selectedRarity == CardRarity.rare
                                ? 'NADİR'
                                : _selectedRarity == CardRarity.epic
                                    ? 'EPİK'
                                    : 'EFSANE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Emoji
                    Text(
                      _selectedEmoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 8),
                    // Card name
                    Text(
                      _nameController.text.isEmpty
                          ? 'Kart Adı'
                          : _nameController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Activity preview
                    Text(
                      _activityController.text.isEmpty
                          ? 'Aktivite açıklaması...'
                          : _activityController.text,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card name
        const Text(
          'Kart Adı',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          style: const TextStyle(color: AppColors.white),
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Örn: Dans Kartı',
          ),
        ),
        const SizedBox(height: 20),
        // Activity
        const Text(
          'Aktivite / Görev',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _activityController,
          style: const TextStyle(color: AppColors.white),
          maxLines: 3,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Örn: 30 saniye dans et!',
          ),
        ),
        const SizedBox(height: 20),
        // Color selector
        const Text(
          'Kart Rengi',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _colorOptions.map((color) {
            final isSelected = _selectedColor == color;
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(
                    color: isSelected ? AppColors.white : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.6),
                            blurRadius: 12,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        // Emoji selector
        const Text(
          'Sembol',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: AppConstants.cardEmojis.length,
            itemBuilder: (context, i) {
              final emoji = AppConstants.cardEmojis[i];
              final isSelected = _selectedEmoji == emoji;
              return GestureDetector(
                onTap: () => setState(() => _selectedEmoji = emoji),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.bgSurface,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 20)),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        // Rarity
        const Text(
          'Nadirlik',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: CardRarity.values.map((rarity) {
            final isSelected = _selectedRarity == rarity;
            final color = _rarityColor(rarity);
            final label = _rarityLabel(rarity);
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedRarity = rarity),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isSelected ? color.withOpacity(0.2) : AppColors.bgCard,
                    border: Border.all(
                      color: isSelected ? color : AppColors.greyDark,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? color : AppColors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _rarityColor(CardRarity rarity) {
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

  String _rarityLabel(CardRarity rarity) {
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
}
