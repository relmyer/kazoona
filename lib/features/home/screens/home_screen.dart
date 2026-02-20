import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/game_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final username = auth.currentUser?.username ?? 'Kazooner';
    final avatar = auth.currentUser?.avatarEmoji ?? '😎';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1628), Color(0xFF231E35)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, username, avatar, auth),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildMainOptions(context),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Önerilen Desteler'),
                      const SizedBox(height: 14),
                      _buildDeckCards(context),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Son Aktiviteler'),
                      const SizedBox(height: 14),
                      _buildRecentActivity(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String username,
    String avatar,
    AuthProvider auth,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: AppColors.primaryGradient,
              ),
            ),
            child: Center(
              child: Text(avatar, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Merhaba, $username! 👋',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Ne oynayalım bugün?',
                style: TextStyle(color: AppColors.grey, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          // Settings
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF231E35),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) => _SettingsSheet(auth: auth),
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.settings_outlined,
                color: AppColors.grey,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainOptions(BuildContext context) {
    return Column(
      children: [
        // Create Room - Large card
        _MainOptionCard(
          emoji: '🏠',
          title: 'Oda Oluştur',
          subtitle: 'Arkadaşlarını davet et ve oyna',
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF8C35), Color(0xFFFFB800)],
          ),
          onTap: () => context.push('/create-room'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Join Room
            Expanded(
              child: _SmallOptionCard(
                emoji: '🔗',
                title: 'Odaya\nKatıl',
                color: AppColors.cardPurple,
                onTap: () => context.push('/join-room'),
              ),
            ),
            const SizedBox(width: 12),
            // Solo Play
            Expanded(
              child: _SmallOptionCard(
                emoji: '🎯',
                title: 'Tek\nOyna',
                color: AppColors.secondary,
                onTap: () {
                  context.read<GameProvider>().startSoloGame();
                  context.push('/game?solo=true');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildDeckCards(BuildContext context) {
    final decks = [
      {'emoji': '🎉', 'name': 'Parti Paketi', 'count': '10 kart', 'color': AppColors.cardOrange},
      {'emoji': '🧠', 'name': 'Zeka Soruları', 'count': '8 kart', 'color': AppColors.cardPurple},
      {'emoji': '🎵', 'name': 'Müzik Meydan Okuma', 'count': '12 kart', 'color': AppColors.cardPink},
      {'emoji': '🏋️', 'name': 'Spor Aktiviteleri', 'count': '6 kart', 'color': AppColors.cardGreen},
    ];

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: decks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final deck = decks[i];
          return _DeckCard(
            emoji: deck['emoji'] as String,
            name: deck['name'] as String,
            count: deck['count'] as String,
            color: deck['color'] as Color,
            onTap: () {
              final gameProvider = context.read<GameProvider>();
              gameProvider.startSoloGame(cardCount: 6);
              context.push('/game?solo=true');
            },
          );
        },
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {'emoji': '🎮', 'text': 'Parti Paketi oynandı', 'time': '2 saat önce'},
      {'emoji': '🏆', 'text': '3 kart kazınıldı', 'time': 'Dün'},
      {'emoji': '👥', 'text': 'Arkadaşlar ile oynandı', 'time': '3 gün önce'},
    ];

    return Column(
      children: activities.map((a) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.greyDark.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Text(a['emoji']!, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  a['text']!,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                a['time']!,
                style: TextStyle(color: AppColors.grey, fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _MainOptionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _MainOptionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 44)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1A1628),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: const Color(0xFF1A1628).withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF1A1628),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallOptionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _SmallOptionCard({
    required this.emoji,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color.withOpacity(0.15),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeckCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String count;
  final Color color;
  final VoidCallback onTap;

  const _DeckCard({
    required this.emoji,
    required this.name,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: color.withOpacity(0.15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const Spacer(),
            Text(
              name,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSheet extends StatelessWidget {
  final AuthProvider auth;

  const _SettingsSheet({required this.auth});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.greyDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            auth.currentUser?.username ?? '',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            auth.currentUser?.email ?? '',
            style: TextStyle(color: AppColors.grey, fontSize: 13),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Çıkış Yap',
                style: TextStyle(color: AppColors.white)),
            onTap: () async {
              Navigator.pop(context);
              await auth.logout();
              if (context.mounted) context.go('/welcome');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
