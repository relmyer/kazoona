import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/kazoona_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _pageController = PageController();
  int _step = 0; // 0-3

  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _avatarEmoji = '😎';
  Uint8List? _profileImageBytes;

  @override
  void dispose() {
    _pageController.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _step++);
    }
  }

  void _back() {
    if (_step == 0) {
      context.pop();
    } else {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _step--);
    }
  }

  Future<void> _register() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      username: _usernameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      avatarEmoji: _avatarEmoji,
      profileImageBytes: _profileImageBytes,
    );
    if (ok && mounted) context.go('/home');
  }

  static const List<IconData> _stepIcons = [
    Icons.person_outline,
    Icons.photo_camera_outlined,
    Icons.mail_outline,
    Icons.lock_outline,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top bar ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _back,
                    child: const Icon(Icons.chevron_left, color: AppColors.white, size: 28),
                  ),
                  const Spacer(),
                  // Step icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_stepIcons[_step], color: AppColors.greyLight, size: 20),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _step < 3 ? _next : null,
                    child: Text(
                      'Atla',
                      style: TextStyle(
                        color: _step < 3 ? AppColors.greyLight : Colors.transparent,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ─── Pages ───────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StepUsername(controller: _usernameCtrl, onNext: _next),
                  _StepPhoto(
                    avatarEmoji: _avatarEmoji,
                    profileImageBytes: _profileImageBytes,
                    onAvatarChanged: (e) => setState(() => _avatarEmoji = e),
                    onImagePicked: (bytes) => setState(() => _profileImageBytes = bytes),
                    onNext: _next,
                  ),
                  _StepEmail(controller: _emailCtrl, onNext: _next),
                  _StepPassword(controller: _passwordCtrl, onRegister: _register),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 1: Username ─────────────────────────────────────────────────────────
class _StepUsername extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onNext;

  const _StepUsername({required this.controller, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Kullanıcı adı yarat',
      child: _DarkTextField(
        controller: controller,
        hint: 'kullanıcı adı',
        icon: Icons.alternate_email,
        autofocus: true,
      ),
      onNext: onNext,
    );
  }
}

// ─── Step 2: Profile photo ────────────────────────────────────────────────────
class _StepPhoto extends StatelessWidget {
  final String avatarEmoji;
  final Uint8List? profileImageBytes;
  final void Function(String) onAvatarChanged;
  final void Function(Uint8List) onImagePicked;
  final VoidCallback onNext;

  const _StepPhoto({
    required this.avatarEmoji,
    required this.profileImageBytes,
    required this.onAvatarChanged,
    required this.onImagePicked,
    required this.onNext,
  });

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file != null) {
      final bytes = await file.readAsBytes();
      onImagePicked(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Bir profil fotoğrafı seç',
      onNext: onNext,
      child: Column(
        children: [
          // Photo circle
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.bgSurface,
                    border: Border.all(color: AppColors.bgBorder, width: 2),
                  ),
                  child: ClipOval(
                    child: profileImageBytes != null
                        ? Image.memory(profileImageBytes!, fit: BoxFit.cover)
                        : Center(
                            child: Text(avatarEmoji, style: const TextStyle(fontSize: 48)),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.bgDark, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Emoji picker
          Text('ya da emoji seç', style: TextStyle(color: AppColors.grey, fontSize: 12)),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: avatarEmojis.length,
              itemBuilder: (context, i) {
                final e = avatarEmojis[i];
                final sel = e == avatarEmoji && profileImageBytes == null;
                return GestureDetector(
                  onTap: () => onAvatarChanged(e),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: sel ? AppColors.primary.withAlpha(40) : AppColors.bgSurface,
                      border: Border.all(
                        color: sel ? AppColors.primary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(e, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 3: Email ────────────────────────────────────────────────────────────
class _StepEmail extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onNext;

  const _StepEmail({required this.controller, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Mail adresini gir',
      child: _DarkTextField(
        controller: controller,
        hint: 'ornek@mail.com',
        icon: Icons.mail_outline,
        keyboardType: TextInputType.emailAddress,
        autofocus: true,
      ),
      onNext: onNext,
    );
  }
}

// ─── Step 4: Password ─────────────────────────────────────────────────────────
class _StepPassword extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onRegister;

  const _StepPassword({required this.controller, required this.onRegister});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => _StepScaffold(
        title: 'Şifre oluştur',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DarkTextField(
              controller: controller,
              hint: '••••••••',
              icon: Icons.lock_outline,
              isPassword: true,
              autofocus: true,
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 10),
              Text(auth.error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
            ],
          ],
        ),
        onNext: auth.isLoading ? () {} : onRegister,
        nextLabel: auth.isLoading ? null : 'Kazoona\'ya Katıl!',
        loading: auth.isLoading,
      ),
    );
  }
}

// ─── Shared step scaffold ─────────────────────────────────────────────────────
class _StepScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onNext;
  final String? nextLabel;
  final bool loading;

  const _StepScaffold({
    required this.title,
    required this.child,
    required this.onNext,
    this.nextLabel,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 32),
          child,
          const Spacer(),
          _DevamButton(onTap: onNext, label: nextLabel ?? 'Devam', loading: loading),
          const SizedBox(height: 36),
        ],
      ),
    );
  }
}

// ─── Devam button ─────────────────────────────────────────────────────────────
class _DevamButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final bool loading;

  const _DevamButton({required this.onTap, required this.label, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(80),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Dark text field ──────────────────────────────────────────────────────────
class _DarkTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final bool autofocus;

  const _DarkTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.autofocus = false,
  });

  @override
  State<_DarkTextField> createState() => _DarkTextFieldState();
}

class _DarkTextFieldState extends State<_DarkTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscure,
      keyboardType: widget.keyboardType,
      autofocus: widget.autofocus,
      style: const TextStyle(color: AppColors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(color: AppColors.grey),
        filled: true,
        fillColor: AppColors.bgSurface,
        prefixIcon: Icon(widget.icon, color: AppColors.grey, size: 20),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.grey,
                  size: 20,
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.bgBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }
}
