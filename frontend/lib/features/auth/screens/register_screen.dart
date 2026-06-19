import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:le_nhat_truong/features/auth/providers/auth_provider.dart';
import 'package:le_nhat_truong/core/theme/app_theme.dart';
import 'package:le_nhat_truong/core/constants/constants.dart';
import 'package:le_nhat_truong/core/utils/social_auth.dart';
import 'package:le_nhat_truong/features/auth/screens/login_screen.dart';
import 'package:le_nhat_truong/features/shop/screens/main_page.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isPressed = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthProvider>().clearError();

    final success = await context.read<AuthProvider>().register(
          _nameCtrl.text.trim(),
          _emailCtrl.text.trim().toLowerCase(),
          _passwordCtrl.text,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đăng ký thành công! Hãy đăng nhập.'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else if (mounted) {
      final error = context.read<AuthProvider>().errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    try {
      final redirectUri = kIsWeb
          ? '${AppConstants.baseUrl}/oauth2/redirect.html'
          : 'authapp://oauth2/redirect';
      final url =
          '${AppConstants.baseUrl}/oauth2/authorization/$provider?redirect_uri=${Uri.encodeComponent(redirectUri)}';
      final result = await authenticateWithPopup(
        url: url,
        callbackUrlScheme: kIsWeb ? 'http' : 'authapp',
      );

      final uri = Uri.parse(result);
      final token = uri.queryParameters['token'];
      final refreshToken = uri.queryParameters['refreshToken'];

      if (token != null && token.isNotEmpty) {
        final authProvider = context.read<AuthProvider>();
        await authProvider.saveTokens(token, refreshToken ?? '');
        await authProvider.checkAuthStatus();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainPage()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng nhập thất bại: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale =
            ((constraints.maxWidth - 32) / 375).clamp(0.5, 1.5).toDouble();
        return Scaffold(
          backgroundColor: const Color(0xFFF9F9F9),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  width: (375 * scale).clamp(200, 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _signUpHeader(scale),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildField(
                                scale: scale,
                                label: 'Name',
                                controller: _nameCtrl,
                                hint: '',
                                showCheck: _nameCtrl.text.isNotEmpty,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Vui lòng nhập tên'
                                        : null,
                              ),
                              SizedBox(height: 16 * scale),
                              _buildField(
                                scale: scale,
                                label: 'Email',
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Vui lòng nhập email';
                                  }
                                  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                      .hasMatch(v.trim())) {
                                    return 'Email không hợp lệ';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16 * scale),
                              _buildField(
                                scale: scale,
                                label: 'Password',
                                controller: _passwordCtrl,
                                obscure: true,
                                validator: (v) => (v == null || v.length < 8)
                                    ? 'Mật khẩu phải có ít nhất 8 ký tự'
                                    : null,
                              ),
                              SizedBox(height: 16 * scale),
                              _alreadyHaveAccount(scale),
                              SizedBox(height: 32 * scale),
                              _signUpButton(scale),
                              SizedBox(height: 124 * scale),
                              _socialSection(scale),
                              SizedBox(height: 32 * scale),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _signUpHeader(double scale) {
    return Container(
      height: 219 * scale,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 44 * scale,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24 * scale),
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: EdgeInsets.all(8 * scale),
                  child: Icon(
                    Icons.chevron_left,
                    size: 24 * scale,
                    color: const Color(0xFF222222),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 14 * scale,
            top: 106 * scale,
            child: Text(
              'Sign up',
              style: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 34 * scale,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF222222),
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required double scale,
    required String label,
    required TextEditingController controller,
    String hint = '',
    bool obscure = false,
    bool showCheck = false,
    TextInputType? keyboardType,
    FormFieldValidator<String>? validator,
  }) {
    return Container(
      width: 343 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000),
            blurRadius: 8 * scale,
            offset: Offset(0, 1 * scale),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure ? _obscurePassword : false,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: (_) => setState(() {}),
        style: TextStyle(
          fontFamily: 'Metropolis',
          fontSize: 14 * scale,
          color: const Color(0xFF2D2D2D),
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 14 * scale,
            color: const Color(0xFF9B9B9B),
          ),
          floatingLabelStyle: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 11 * scale,
            color: const Color(0xFF9B9B9B),
          ),
          hintStyle: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 14 * scale,
            color: const Color(0xFF2D2D2D),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          contentPadding: EdgeInsets.symmetric(
              horizontal: 20 * scale, vertical: 21 * scale),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4 * scale),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4 * scale),
            borderSide: BorderSide(color: const Color(0xFFE0E0E0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4 * scale),
            borderSide: BorderSide(color: const Color(0xFFDB3022), width: 1.5),
          ),
          suffixIcon: showCheck
              ? Padding(
                  padding: EdgeInsets.all(16 * scale),
                  child: Icon(
                    Icons.check_circle,
                    color: const Color(0xFF2AA952),
                    size: 24 * scale,
                  ),
                )
              : (obscure
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20 * scale,
                        color: const Color(0xFF9B9B9B),
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    )
                  : null),
        ),
      ),
    );
  }

  Widget _alreadyHaveAccount(double scale) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Already have an account?',
              style: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 14 * scale,
                color: const Color(0xFF222222),
                height: 1.43,
              ),
            ),
            SizedBox(width: 4 * scale),
            Icon(
              Icons.arrow_forward,
              size: 24 * scale,
              color: const Color(0xFFDB3022),
            ),
          ],
        ),
      ),
    );
  }

  Widget _signUpButton(double scale) {
    return SizedBox(
      width: 343 * scale,
      height: 48 * scale,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 80),
          child: ElevatedButton(
            onPressed: _register,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDB3022),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25 * scale),
              ),
              elevation: 4,
              shadowColor: const Color(0xFFD32626).withValues(alpha: 0.25),
            ),
            child: Text(
              'SIGN UP',
              style: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 14 * scale,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialSection(double scale) {
    return Column(
      children: [
        Text(
          'Or sign up with social account',
          style: TextStyle(
            fontFamily: 'Metropolis',
            fontSize: 14 * scale,
            color: const Color(0xFF222222),
            height: 1.43,
          ),
        ),
        SizedBox(height: 16 * scale),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialButton(
              scale: scale,
              child: Image(
                image: const AssetImage('assets/images/gg.png'),
                width: 28 * scale,
                height: 28 * scale,
              ),
              onTap: () => _handleSocialLogin('google'),
            ),
            SizedBox(width: 16 * scale),
            _socialButton(
              scale: scale,
              child: Image(
                image: const AssetImage('assets/images/fb.png'),
                width: 28 * scale,
                height: 28 * scale,
              ),
              onTap: () => _handleSocialLogin('facebook'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _socialButton({
    required double scale,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 92 * scale,
        height: 64 * scale,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24 * scale),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0D000000),
              blurRadius: 8 * scale,
              offset: Offset(0, 1 * scale),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
