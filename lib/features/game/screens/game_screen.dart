import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/game_card_model.dart';
import '../../../models/room_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/game_provider.dart';
import '../widgets/scratch_card_widget.dart';

class GameScreen extends StatefulWidget {
  final bool isSolo;

  const GameScreen({super.key, this.isSolo = true});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Tracks which card is being shown in the reveal modal (just revealed)
  GameCard? _justRevealedCard;

  void _onCardFullyScratched(GameCard card, GameProvider game) {
    game.revealCard(card.id, solo: widget.isSolo);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _showRevealModal(card, game);
      }
    });
  }

  void _showRevealModal(GameCard card, GameProvider game) {
    setState(() => _justRevealedCard = card);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(160),
      builder: (_) => _RevealModal(
        card: card,
        isSolo: widget.isSolo,
        onAccept: () {
          Navigator.pop(context);
          if (!widget.isSolo) game.nextTurn();
          setState(() => _justRevealedCard = null);
        },
        onSkip: () {
          Navigator.pop(context);
          if (!widget.isSolo) game.nextTurn();
          setState(() => _justRevealedCard = null);
        },
      ),
    ).whenComplete(() => setState(() => _justRevealedCard = null));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userId = auth.currentUser?.id ?? '';

    return Consumer<GameProvider>(
      builder: (context, game, _) {
        final cards = game.getCards(solo: widget.isSolo);
        final allRevealed = game.allRevealed;
        final myTurn = widget.isSolo || game.isMyTurn(userId);

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, game),
                _buildProgress(game),
                Expanded(
                  child: _buildCardGrid(context, cards, game, myTurn, userId),
                ),
                if (allRevealed) _buildFinishBar(context, game),
                if (!widget.isSolo && game.currentRoom != null)
                  _TurnIndicatorBar(
                    members: game.currentRoom!.members,
                    currentTurnIndex: game.currentTurnIndex,
                    myUserId: userId,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, GameProvider game) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              game.leaveRoom();
              context.go('/home');
            },
            icon: const Icon(Icons.close, color: AppColors.greyLight),
          ),
          const Spacer(),
          if (!widget.isSolo && game.currentRoom != null)
            _RoomCodeBadge(code: game.currentRoom!.code)
          else
            const Text(
              '🎯 Solo Oyun',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          const Spacer(),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.grey),
            color: AppColors.bgSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'reveal_all',
                child: Text('Hepsini Aç', style: TextStyle(color: AppColors.white)),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Text('Sıfırla', style: TextStyle(color: AppColors.white)),
              ),
            ],
            onSelected: (val) {
              if (val == 'reveal_all') {
                game.revealAllCards(solo: widget.isSolo);
              } else if (val == 'reset') {
                game.resetCards(solo: widget.isSolo);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(GameProvider game) {
    final revealed = game.revealedCount;
    final total = game.totalCards;
    final progress = total > 0 ? revealed / total : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$revealed / $total kart kazındı',
                style: const TextStyle(color: AppColors.grey, fontSize: 11),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.bgSurface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardGrid(
    BuildContext context,
    List<GameCard> cards,
    GameProvider game,
    bool myTurn,
    String userId,
  ) {
    if (cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😕', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text(
              'Kart yok!',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => context.go('/home'),
              child: const Text(
                'Ana Sayfaya Dön',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    final crossAxisCount = cards.length <= 4 ? 2 : 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: cards.length,
        itemBuilder: (context, i) {
          final card = cards[i];
          final isEnabled = myTurn && !card.isRevealed;
          return Stack(
            children: [
              ScratchCardWidget(
                key: ValueKey(card.id),
                card: card,
                compact: true,
                enabled: isEnabled,
                onFullyScratch: () => _onCardFullyScratched(card, game),
              ),
              // Revealed check badge
              if (card.isRevealed)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  ),
                ),
              // "Not your turn" overlay label
              if (!myTurn && !card.isRevealed)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(140),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Sıra sende değil',
                        style: TextStyle(color: Colors.white54, fontSize: 9),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFinishBar(BuildContext context, GameProvider game) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => _GameSummarySheet(game: game, isSolo: widget.isSolo),
        ),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: AppColors.success,
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withAlpha(80),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '🎉 Tüm Kartlar Kazındı — Özeti Gör',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Room code badge ──────────────────────────────────────────────────────────
class _RoomCodeBadge extends StatelessWidget {
  final String code;
  const _RoomCodeBadge({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bgBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.tag, color: AppColors.grey, size: 13),
          const SizedBox(width: 4),
          Text(
            code,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Turn indicator bottom bar ────────────────────────────────────────────────
class _TurnIndicatorBar extends StatelessWidget {
  final List<RoomMember> members;
  final int currentTurnIndex;
  final String myUserId;

  const _TurnIndicatorBar({
    required this.members,
    required this.currentTurnIndex,
    required this.myUserId,
  });

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();
    final activeIndex = currentTurnIndex % members.length;
    final isMyTurn = members[activeIndex].userId == myUserId;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.bgBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "Whose turn" label
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              isMyTurn
                  ? 'Sıra sende! Bir kartı kazı 🔥'
                  : '${members[activeIndex].username} kazıyor...',
              key: ValueKey(activeIndex),
              style: TextStyle(
                color: isMyTurn ? AppColors.primary : AppColors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Player pills row
          _PlayerPillRow(
            members: members,
            activeIndex: activeIndex,
            myUserId: myUserId,
          ),
        ],
      ),
    );
  }
}

class _PlayerPillRow extends StatelessWidget {
  final List<RoomMember> members;
  final int activeIndex;
  final String myUserId;

  const _PlayerPillRow({
    required this.members,
    required this.activeIndex,
    required this.myUserId,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const avatarSize = 44.0;
        const gap = 10.0;
        final totalW = members.length * avatarSize + (members.length - 1) * gap;
        final startX = (constraints.maxWidth - totalW) / 2;
        final pillX = startX + activeIndex * (avatarSize + gap);

        return SizedBox(
          height: avatarSize + 8,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Sliding pill background
              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutBack,
                left: pillX - 4,
                top: 0,
                child: Container(
                  width: avatarSize + 8,
                  height: avatarSize + 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: AppColors.primary.withAlpha(30),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              // Avatar circles
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: members.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final member = entry.value;
                    final isActive = idx == activeIndex;
                    final isMe = member.userId == myUserId;

                    return Padding(
                      padding: EdgeInsets.only(
                        right: idx < members.length - 1 ? gap : 0,
                      ),
                      child: _PlayerAvatar(
                        member: member,
                        size: avatarSize,
                        isActive: isActive,
                        isMe: isMe,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  final RoomMember member;
  final double size;
  final bool isActive;
  final bool isMe;

  const _PlayerAvatar({
    required this.member,
    required this.size,
    required this.isActive,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isActive ? AppColors.primary.withAlpha(20) : AppColors.bgSurface,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            member.avatarEmoji,
            style: TextStyle(fontSize: isActive ? 22 : 18),
          ),
          if (isMe)
            Container(
              margin: const EdgeInsets.only(top: 1),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Card reveal modal ────────────────────────────────────────────────────────
class _RevealModal extends StatelessWidget {
  final GameCard card;
  final bool isSolo;
  final VoidCallback onAccept;
  final VoidCallback onSkip;

  const _RevealModal({
    required this.card,
    required this.isSolo,
    required this.onAccept,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.bgBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.bgBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // "ilk görünüm" label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: card.rarityColor.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: card.rarityColor.withAlpha(80)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: card.rarityColor, size: 12),
                  const SizedBox(width: 5),
                  Text(
                    'ilk görünüm',
                    style: TextStyle(
                      color: card.rarityColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Big emoji
            Text(card.emoji, style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 12),
            // Card name
            Text(
              card.name,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            // Rarity badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: card.rarityColor.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                card.rarityLabel,
                style: TextStyle(
                  color: card.rarityColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Activity box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: card.color.withAlpha(60)),
              ),
              child: Text(
                card.activity,
                style: TextStyle(
                  color: card.color,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            // Action buttons
            Row(
              children: [
                // Skip / Pas
                Expanded(
                  child: GestureDetector(
                    onTap: onSkip,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.bgBorder),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🙅', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              isSolo ? 'Geç' : 'Pas',
                              style: const TextStyle(
                                color: AppColors.greyLight,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Accept / Yapacağım
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: onAccept,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withAlpha(80),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('✅', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 6),
                            Text(
                              'Yapacağım!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Game summary sheet ───────────────────────────────────────────────────────
class _GameSummarySheet extends StatelessWidget {
  final GameProvider game;
  final bool isSolo;

  const _GameSummarySheet({required this.game, required this.isSolo});

  @override
  Widget build(BuildContext context) {
    final cards = game.getCards(solo: isSolo);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.bgBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.bgBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('🎉', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 10),
            const Text(
              'Oyun Bitti!',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${cards.length} kart kazındı',
              style: const TextStyle(color: AppColors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            // Activity list
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.35,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: cards.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final card = cards[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: card.color.withAlpha(50)),
                    ),
                    child: Row(
                      children: [
                        Text(card.emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.name,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                card.activity,
                                style: const TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 11,
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
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      game.leaveRoom();
                      context.go('/home');
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.bgBorder),
                      ),
                      child: const Center(
                        child: Text(
                          'Ana Sayfa',
                          style: TextStyle(
                            color: AppColors.greyLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      game.resetCards(solo: isSolo);
                      if (isSolo) game.startSoloGame(cardCount: cards.length);
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: AppColors.primaryGradient),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(80),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Tekrar Oyna',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
