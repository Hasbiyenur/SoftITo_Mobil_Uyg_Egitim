import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/style/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/listing_bloc.dart';
import '../bloc/rental_bloc.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'main_scaffold.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    return email.contains('@') && password.length >= 4;
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        LoginEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  void _fillDemoUser() {
    setState(() {
      _emailController.text = 'deniz.kaya@roomio.demo';
      _passwordController.text = '123456';
    });
    _onLogin();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.read<ListingBloc>().add(LoadListingsEvent());
            context.read<RentalBloc>().add(LoadRentalsEvent(state.user.id));
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainScaffold()),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenMargin,
                  vertical: AppSpacing.standard,
                ),
                child: Form(
                  key: _formKey,
                  onChanged: () => setState(() {}),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // App Logo
                      Center(
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.home_work_rounded,
                                  size: 48,
                                  color: AppColors.primary,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.standard),

                      // Welcome Title
                      Text(
                        'Roomio\'ya Hoş Geldin',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hesabına giriş yap veya hemen yeni bir hesap oluştur',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.65,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Email Field
                      CustomTextField(
                        label: 'E-posta Adresi veya Kullanıcı Adı',
                        hint: 'ornek@email.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Lütfen e-posta adresinizi giriniz.';
                          }
                          if (!val.contains('@')) {
                            return 'Geçerli bir e-posta adresi giriniz.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.standard),

                      // Password Field
                      CustomTextField(
                        label: 'Şifre',
                        hint: '••••••••',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Lütfen şifrenizi giriniz.';
                          }
                          if (val.trim().length < 4) {
                            return 'Şifre en az 4 karakter olmalıdır.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // "Hesabın yok mu? Kayıt Ol" link (located right above Giriş Yap button as required in screen.md Section 2)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hesabın yok mu? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.75,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Kayıt Ol',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Giriş Yap Button (enabled only when form format is valid as per screen.md Section 2)
                      CustomButton(
                        text: 'Giriş Yap',
                        isLoading: isLoading,
                        onPressed: _isFormValid ? _onLogin : null,
                      ),
                      const SizedBox(height: AppSpacing.standard),

                      // Quick 1-Tap Demo Auto-Fill & Login
                      OutlinedButton.icon(
                        icon: const Icon(
                          Icons.play_circle_fill_rounded,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                        label: const Text(
                          'Örnek Demo Kullanıcı ile Hızlı Giriş',
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          foregroundColor: theme.colorScheme.onSurface,
                          side: BorderSide(color: theme.colorScheme.outline),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoading ? null : _fillDemoUser,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
