import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/game_provider.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final List<TextEditingController> _controllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());
  bool _isJoining = false;
  String? _error;

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code =>
      _controllers.map((c) => c.text.toUpperCase()).join();

  Future<void> _joinRoom() async {
    if (_code.length < 5) {
      setState(() => _error = 'Lütfen tam kodu gir');
      return;
    }

    setState(() {
      _isJoining = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    final game = context.read<GameProvider>();

    final success = await game.joinRoom(
      code: _code,
      userId: auth.currentUser!.id,
      username: auth.currentUser!.username,
      avatarEmoji: auth.currentUser!.avatarEmoji,
    );

    if (!mounted) return;
    setState(() => _isJoining = false);

    if (success) {
      context.push('/room-lobby');
    } else {
      setState(() => _error = 'Oda bulunamadı. Kodu kontrol et.');
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      const Text('🔗', style: TextStyle(fontSize: 52)),
                      const SizedBox(height: 16),
                      const Text(
                        'Odaya Katıl',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Arkadaşının paylaştığı 5 haneli\noda kodunu gir.',
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Code input boxes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (i) {
                          return _CodeBox(
                            controller: _controllers[i],
                            focusNode: _focusNodes[i],
                            onChanged: (val) {
                              if (val.isNotEmpty && i < 4) {
                                _focusNodes[i + 1].requestFocus();
                              }
                              if (val.isEmpty && i > 0) {
                                _focusNodes[i - 1].requestFocus();
                              }
                              setState(() {});
                            },
                          );
                        }),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const Spacer(),
                      // Join button
                      GestureDetector(
                        onTap: _isJoining ? null : _joinRoom,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: _code.length == 5
                                  ? AppColors.primaryGradient
                                  : [
                                      AppColors.greyDark,
                                      AppColors.greyDark,
                                    ],
                            ),
                            boxShadow: _code.length == 5
                                ? [
                                    BoxShadow(
                                      color:
                                          AppColors.primary.withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: _isJoining
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF1A1628),
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    'Katıl!',
                                    style: TextStyle(
                                      color: _code.length == 5
                                          ? const Color(0xFF1A1628)
                                          : AppColors.grey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
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

class _CodeBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;

  const _CodeBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 70,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        maxLength: 1,
        textCapitalization: TextCapitalization.characters,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.bgCard,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.greyDark,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
        ),
        onChanged: (val) {
          onChanged(val);
        },
      ),
    );
  }
}
