import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../shared/widgets/app_action_button.dart';
import 'auth_controller.dart';
import 'auth_scope.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _loadedRememberedPhone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadRememberedPhone(AuthScope.of(context));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = AuthScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: <Widget>[
                      _LoginHeader(
                        height: constraints.maxHeight < 720 ? 216 : 278,
                      ),
                      Expanded(
                        child: Transform.translate(
                          offset: const Offset(0, -42),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 430,
                                ),
                                child: _buildLoginCard(context, authController),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context, AuthController authController) {
    final bool isBusy = authController.isBusy;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: <BoxShadow>[AppColors.softShadow(opacity: 0.10, blur: 18)],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Welcome back',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Sign in to manage activity.',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: AppColors.textMute,
              ),
            ),
            if (authController.errorMessage != null) ...<Widget>[
              const SizedBox(height: 14),
              _LoginErrorMessage(message: authController.errorMessage!),
            ],
            const SizedBox(height: 24),
            _LoginTextField(
              controller: _phoneController,
              label: 'Phone number',
              hint: '+880 1712 345678',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: _validatePhone,
            ),
            const SizedBox(height: 14),
            _LoginTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter your password',
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outline_rounded,
              validator: _validatePassword,
              suffix: IconButton(
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.textMute,
                ),
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 34,
                  height: 34,
                  child: Checkbox(
                    value: _rememberMe,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    side: const BorderSide(color: AppColors.border, width: 1.5),
                    onChanged: (bool? value) {
                      setState(() => _rememberMe = value ?? false);
                    },
                  ),
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Remember this device',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMid,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Forgot?',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            AppActionButton(
              label: isBusy ? 'Signing In...' : 'Sign In',
              background: isBusy ? AppColors.textMute : AppColors.primary,
              foreground: Colors.white,
              onTap: isBusy ? null : () => _submit(authController),
            ),
            const SizedBox(height: 18),
            const _LoginSecurityNote(),
          ],
        ),
      ),
    );
  }

  String? _validatePhone(String? value) {
    final String phone = value?.trim() ?? '';
    final String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (phone.isEmpty) {
      return 'Phone number is required';
    }
    if (digits.length < 10 || digits.length > 15) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Password is required';
    }
    if ((value ?? '').length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _submit(AuthController authController) async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      final bool success = await authController.signIn(
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        rememberDevice: _rememberMe,
      );

      if (mounted && success) {
        context.go(RouteNames.home);
      }
    }
  }

  Future<void> _loadRememberedPhone(AuthController authController) async {
    if (_loadedRememberedPhone) {
      return;
    }
    _loadedRememberedPhone = true;

    final String? phone = await authController.readRememberedPhone();
    if (!mounted || phone == null || _phoneController.text.isNotEmpty) {
      return;
    }

    setState(() {
      _phoneController.text = phone;
      _rememberMe = true;
    });
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final bool isCompact = height < 240;

    return Container(
      height: height,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22, 24, 22, isCompact ? 40 : 76),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.primary,
            AppColors.primaryDk,
            Color(0xFF003830),
          ],
          stops: <double>[0, .62, 1],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -56,
            top: -52,
            child: _HeaderAccent(
              size: 190,
              color: Colors.white.withValues(alpha: .05),
            ),
          ),
          Positioned(
            left: -42,
            bottom: -60,
            child: _HeaderAccent(
              size: 170,
              color: AppColors.accent.withValues(alpha: .09),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _BrandMark(),
                  SizedBox(height: isCompact ? 12 : 18),
                  Text(
                    'Root Finance',
                    style: TextStyle(
                      fontSize: isCompact ? 24 : 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.08,
                    ),
                  ),
                  SizedBox(height: isCompact ? 6 : 8),
                  Text(
                    'Secure access for capital tracking and member operations.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: Color(0xCFFFFFFF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAccent extends StatelessWidget {
  const _HeaderAccent({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .22)),
      ),
      child: const Icon(
        Icons.account_balance_rounded,
        color: AppColors.accentLt,
        size: 28,
      ),
    );
  }
}

class _LoginTextField extends StatelessWidget {
  const _LoginTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.textMute),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textMute,
        ),
        hintStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textMute,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.red, width: 1.5),
        ),
      ),
    );
  }
}

class _LoginErrorMessage extends StatelessWidget {
  const _LoginErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.redLt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.red.withValues(alpha: .22)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.error_outline, size: 18, color: AppColors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w700,
                color: AppColors.textMid,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginSecurityNote extends StatelessWidget {
  const _LoginSecurityNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.greenLt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: .14)),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.verified_user_outlined, size: 18, color: AppColors.green),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Protected workspace for verified association admins.',
              style: TextStyle(
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w700,
                color: AppColors.textMid,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
