import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/game_provider.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  int _cardCount = 6;
  bool _useRandomCards = true;
  bool _isCreating = false;

  Future<void> _createRoom() async {
    setState(() => _isCreating = true);
    final auth = context.read<AuthProvider>();
    final game = context.read<GameProvider>();

    await game.createRoom(
      hostId: auth.currentUser!.id,
      hostUsername: auth.currentUser!.username,
      hostAvatar: auth.currentUser!.avatarEmoji,
      cardCount: _cardCount,
    );

    if (mounted) {
      setState(() => _isCreating = false);
      context.push('/room-lobby');
    }
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Oda Oluştur 🏠',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Arkadaşlarını bekle ve birlikte kazo!',
                        style: TextStyle(color: AppColors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 32),
                      // Card count selector
                      _SectionCard(
                        title: 'Kart Sayısı',
                        icon: '🃏',
                        child: _CardCountSelector(
                          value: _cardCount,
                          onChanged: (v) => setState(() => _cardCount = v),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Card type
                      _SectionCard(
                        title: 'Kart Türü',
                        icon: '🎲',
                        child: Column(
                          children: [
                            _RadioOption(
                              label: 'Rastgele Kartlar',
                              subtitle: 'Hazır etkinlik listesinden seç',
                              selected: _useRandomCards,
                              onTap: () =>
                                  setState(() => _useRandomCards = true),
                            ),
                            const SizedBox(height: 10),
                            _RadioOption(
                              label: 'Kendi Kartlarım',
                              subtitle: 'Özel kartlar oluştur',
                              selected: !_useRandomCards,
                              onTap: () {
                                setState(() => _useRandomCards = false);
                                context.push('/card-creator');
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Room info
                      _SectionCard(
                        title: 'Oda Bilgisi',
                        icon: '📋',
                        child: Column(
                          children: [
                            _InfoRow(
                              label: 'Maks. Oyuncu',
                              value: '8 kişi',
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              label: 'Kart Sayısı',
                              value: '$_cardCount kart',
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              label: 'Oda Türü',
                              value: 'Özel',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: _GradientButton(
                  label: _isCreating ? 'Oluşturuluyor...' : 'Oda Oluştur!',
                  loading: _isCreating,
                  onTap: _isCreating ? () {} : _createRoom,
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
        ],
      ),
    );
  }
}

class RoomLobbyScreen extends StatelessWidget {
  const RoomLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final room = game.currentRoom;

    if (room == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        game.leaveRoom();
                        context.go('/home');
                      },
                      icon: const Icon(Icons.close, color: AppColors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Oda Kodu',
                        style: TextStyle(color: AppColors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      // Room code
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: room.code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kod kopyalandı!')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: AppColors.primaryGradient,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                room.code,
                                style: const TextStyle(
                                  color: Color(0xFF1A1628),
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 8,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.copy,
                                color: Color(0xFF1A1628),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Arkadaşlarına bu kodu paylaş',
                        style: TextStyle(color: AppColors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 32),
                      // Members
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Oyuncular (${room.members.length}/${room.maxPlayers})',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Expanded(
                              child: ListView.separated(
                                itemCount: room.members.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, i) {
                                  final member = room.members[i];
                                  return _MemberTile(
                                    name: member.username,
                                    avatar: member.avatarEmoji,
                                    isHost: member.isHost,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Start button
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _GradientButton(
                          label: '🎮 Oyunu Başlat!',
                          onTap: () => context.push('/game?solo=false'),
                        ),
                      ),
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
}

class _MemberTile extends StatelessWidget {
  final String name;
  final String avatar;
  final bool isHost;

  const _MemberTile({
    required this.name,
    required this.avatar,
    required this.isHost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: isHost
            ? Border.all(color: AppColors.primary.withOpacity(0.5))
            : null,
      ),
      child: Row(
        children: [
          Text(avatar, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (isHost)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'HOST',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            const Icon(Icons.check_circle, color: AppColors.success, size: 20),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyDark.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _CardCountSelector extends StatelessWidget {
  final int value;
  final void Function(int) onChanged;

  const _CardCountSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            if (value > AppConstants.minCardsPerGame) onChanged(value - 1);
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.remove, color: AppColors.white),
          ),
        ),
        Column(
          children: [
            Text(
              '$value',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'kart',
              style: TextStyle(color: AppColors.grey, fontSize: 12),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            if (value < AppConstants.maxCardsPerGame) onChanged(value + 1);
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add, color: AppColors.white),
          ),
        ),
      ],
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RadioOption({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.grey,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? AppColors.primary : AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.grey, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;

  const _GradientButton({
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: AppColors.primaryGradient),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Color(0xFF1A1628),
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF1A1628),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}
