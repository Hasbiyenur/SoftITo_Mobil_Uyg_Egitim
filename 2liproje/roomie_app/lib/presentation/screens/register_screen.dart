import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../core/style/app_radius.dart';
import '../../core/style/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_constants.dart';
import '../../core/utils/image_storage_helper.dart';
import '../../data/models/user_model.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/listing_bloc.dart';
import '../bloc/rental_bloc.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'main_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep =
      0; // 0: Kullanıcı Bilgileri, 1: Alışkanlıklar, 2: Lokasyon & Belgeler
  final _uuid = const Uuid();

  // Step 1 Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordRepeatController = TextEditingController();
  final _ageController = TextEditingController(text: '22');
  final _occupationController = TextEditingController();
  String _gender = 'Kadın';
  bool _isStudent = true;
  String? _avatarPath;

  // Step 2 Habits
  bool _smoking = false;
  bool _hasPets = false;
  String _sleepHabit = 'Gece';
  String _cleanliness = 'Çok';
  final List<String> _selectedLanguages = ['Türkçe', 'İngilizce'];

  // Step 3 Location & Documents
  String _selectedCity = 'İstanbul';
  String _selectedDistrict = 'Kadıköy';
  bool _hasUploadedCriminalDoc = false;
  bool _hasUploadedStudentDoc = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordRepeatController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final xFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (xFile != null) {
        final permPath = await ImageStorageHelper.saveImagePermanently(
          xFile.path,
        );
        setState(() {
          _avatarPath = permPath;
        });
      }
    } catch (_) {
      // Fallback preset
      setState(() {
        _avatarPath = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80';
      });
    }
  }

  Future<void> _launchExternalUrl(
    String urlString,
    VoidCallback onVerified,
  ) async {
    final uri = Uri.parse(urlString);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
    // Simulate document attached successfully in demo
    onVerified();
  }

  void _validateAndProceedStep1() {
    if (_fullNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _passwordRepeatController.text.trim().isEmpty ||
        _ageController.text.trim().isEmpty ||
        _occupationController.text.trim().isEmpty) {
      _showWarning('Lütfen tüm alanları doldurun.');
      return;
    }

    if (!_emailController.text.contains('@')) {
      _showWarning('Lütfen geçerli bir e-posta adresi giriniz.');
      return;
    }

    if (_passwordController.text != _passwordRepeatController.text) {
      _showWarning('Girdiğiniz şifreler birbiriyle eşleşmiyor.');
      return;
    }

    setState(() => _currentStep = 1);
  }

  void _validateAndProceedStep2() {
    if (_selectedLanguages.isEmpty) {
      _showWarning('Lütfen en az bir dil seçiniz.');
      return;
    }
    setState(() => _currentStep = 2);
  }

  void _submitRegistration() {
    if (!_hasUploadedCriminalDoc) {
      _showWarning('Adli sicil belgesi yüklenmesi zorunludur.');
      return;
    }

    if (_isStudent && !_hasUploadedStudentDoc) {
      _showWarning(
        'Öğrenci olduğunu belirten kullanıcıların öğrenci belgesi yüklemesi zorunludur.',
      );
      return;
    }

    final user = UserModel(
      id: _uuid.v4(),
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim().toLowerCase(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      avatar: _avatarPath ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
      age: int.tryParse(_ageController.text.trim()) ?? 22,
      gender: _gender,
      occupation: _occupationController.text.trim(),
      isStudent: _isStudent,
      habits: HabitsModel(
        smoking: _smoking,
        hasPets: _hasPets,
        sleepHabit: _sleepHabit,
        cleanliness: _cleanliness,
        languages: _selectedLanguages,
      ),
      city: _selectedCity,
      district: _selectedDistrict,
      hasCriminalRecordDoc: _hasUploadedCriminalDoc,
      hasStudentDoc: _hasUploadedStudentDoc,
      addresses: [
        AddressModel(
          id: 'addr-main',
          title: 'Birincil Adres',
          city: _selectedCity,
          district: _selectedDistrict,
          addressDetail: 'Merkez Mah.',
        ),
      ],
      savedCards: const [
        SavedCardModel(
          id: 'card-default',
          cardHolder: 'HESAP SAHİBİ',
          maskedNumber: '•••• •••• •••• 4242',
          expiry: '12/28',
        ),
      ],
      createdAt: DateTime.now(),
    );

    context.read<AuthBloc>().add(RegisterEvent(user));
  }

  void _showWarning(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Hesap Oluştur'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.read<ListingBloc>().add(LoadListingsEvent());
            context.read<RentalBloc>().add(LoadRentalsEvent(state.user.id));
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainScaffold()),
              (route) => false,
            );
          } else if (state is AuthError) {
            _showWarning(state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Column(
              children: [
                // Step Progress Indicator
                _buildStepHeader(theme),

                // Step Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.screenMargin),
                    child: _buildCurrentStep(theme),
                  ),
                ),

                // Navigation Buttons Bottom Bar
                Container(
                  padding: const EdgeInsets.all(AppSpacing.standard),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (_currentStep > 0) ...[
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: isLoading
                                ? null
                                : () => setState(() => _currentStep--),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Geri'),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        flex: 2,
                        child: CustomButton(
                          text: _currentStep == 2
                              ? 'Kayıt Ol ve Başla'
                              : 'Sonraki Aşama',
                          isLoading: isLoading,
                          onPressed: () {
                            if (_currentStep == 0) {
                              _validateAndProceedStep1();
                            } else if (_currentStep == 1) {
                              _validateAndProceedStep2();
                            } else {
                              _submitRegistration();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepHeader(ThemeData theme) {
    final steps = ['Kişisel', 'Alışkanlıklar', 'Lokasyon & Belge'];
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.standard,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isPassed = index <= _currentStep;
          final isCurrent = index == _currentStep;

          return Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: isPassed
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.4),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isPassed
                          ? Colors.white
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    steps[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: isCurrent
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                if (index < steps.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep(ThemeData theme) {
    switch (_currentStep) {
      case 0:
        return _buildStep1Personal(theme);
      case 1:
        return _buildStep2Habits(theme);
      case 2:
        return _buildStep3LocationAndDocs(theme);
      default:
        return const SizedBox();
    }
  }

  // STEP 1: Kullanıcı Bilgileri
  Widget _buildStep1Personal(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar Picker
        Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 46,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.15,
                ),
                backgroundImage: _avatarPath != null
                    ? (_avatarPath!.startsWith('http')
                          ? NetworkImage(_avatarPath!) as ImageProvider
                          : FileImage(File(_avatarPath!)))
                    : null,
                child: _avatarPath == null
                    ? Icon(
                        Icons.person_rounded,
                        size: 50,
                        color: theme.colorScheme.primary,
                      )
                    : null,
              ),
              InkWell(
                onTap: _pickAvatar,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Profil Fotoğrafı (İsteğe Bağlı)',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.standard),

        CustomTextField(
          label: 'İsim ve Soyisim',
          hint: 'Adınız Soyadınız',
          controller: _fullNameController,
          prefixIcon: const Icon(Icons.person_outline_rounded),
        ),
        const SizedBox(height: AppSpacing.md),

        CustomTextField(
          label: 'E-posta Adresi',
          hint: 'ornek@email.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined),
        ),
        const SizedBox(height: AppSpacing.md),

        CustomTextField(
          label: 'Telefon Numarası',
          hint: '+90 5XX XXX XX XX',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_outlined),
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Yaş',
                controller: _ageController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.cake_outlined),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cinsiyet',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Kadın', child: Text('Kadın')),
                      DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _gender = val);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        CustomTextField(
          label: 'Meslek veya Okul Adı',
          hint: 'Örn: Bilgisayar Mühendisliği / İTÜ',
          controller: _occupationController,
          prefixIcon: const Icon(Icons.work_outline_rounded),
        ),
        const SizedBox(height: AppSpacing.md),

        // Student switch
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Üniversite Öğrencisiyim',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: const Text(
            'Öğrencilere %20 kira desteği kampanyası sunulur',
            style: TextStyle(fontSize: 12),
          ),
          value: _isStudent,
          activeThumbColor: AppColors.primary,
          onChanged: (val) => setState(() => _isStudent = val),
        ),
        const SizedBox(height: AppSpacing.md),

        CustomTextField(
          label: 'Şifre',
          hint: '••••••••',
          controller: _passwordController,
          obscureText: true,
          prefixIcon: const Icon(Icons.lock_outline_rounded),
        ),
        const SizedBox(height: AppSpacing.md),

        CustomTextField(
          label: 'Şifre Tekrar',
          hint: '••••••••',
          controller: _passwordRepeatController,
          obscureText: true,
          prefixIcon: const Icon(Icons.lock_reset_rounded),
        ),
      ],
    );
  }

  // STEP 2: Alışkanlıklar
  Widget _buildStep2Habits(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Yaşam Tarzı ve Alışkanlıkların',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Doğru oda arkadaşını bulabilmek için alışkanlıklarını dürüstçe belirt.',
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: AppSpacing.standard),

        // Sigara
        const Text(
          'Sigara Kullanımı',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildChoiceChip(
              'Hayır, kullanmıyorum',
              !_smoking,
              () => setState(() => _smoking = false),
            ),
            const SizedBox(width: 8),
            _buildChoiceChip(
              'Evet, kullanıyorum',
              _smoking,
              () => setState(() => _smoking = true),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.standard),

        // Evcil Hayvan
        const Text(
          'Evcil Hayvan Durumu',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildChoiceChip(
              'Hayır, yok',
              !_hasPets,
              () => setState(() => _hasPets = false),
            ),
            const SizedBox(width: 8),
            _buildChoiceChip(
              'Evet, var / sorun etmem',
              _hasPets,
              () => setState(() => _hasPets = true),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.standard),

        // Uyku Düzeni
        const Text(
          'Uyku Düzeni',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: AppConstants.sleepHabits.map((habit) {
            return _buildChoiceChip(
              habit,
              _sleepHabit == habit,
              () => setState(() => _sleepHabit = habit),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.standard),

        // Temizlik Hassasiyeti
        const Text(
          'Temizlik Hassasiyeti',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: ['Yok', 'Az', 'Orta', 'Çok'].map((c) {
            return _buildChoiceChip(
              c,
              _cleanliness == c,
              () => setState(() => _cleanliness = c),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.standard),

        // Konuştuğu Diller
        const Text(
          'Konuştuğun Diller',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.availableLanguages.map((lang) {
            final isSelected = _selectedLanguages.contains(lang);
            return FilterChip(
              label: Text(lang),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedLanguages.add(lang);
                  } else {
                    if (_selectedLanguages.length > 1) {
                      _selectedLanguages.remove(lang);
                    }
                  }
                });
              },
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // STEP 3: Lokasyon & Belgeler
  Widget _buildStep3LocationAndDocs(ThemeData theme) {
    final availableDistricts =
        AppConstants.turkeyLocations[_selectedCity] ?? ['Merkez'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Konum Tercihi ve Doğrulama Belgeleri',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Topluluk güvenliği için belgelerinizi doğrulayın ve ev aradığınız şehri seçin.',
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: AppSpacing.standard),

        // İl Dropdown
        const Text(
          'Bulunduğunuz / Aradığınız İl',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedCity,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: AppConstants.turkeyLocations.keys
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedCity = val;
                _selectedDistrict = AppConstants.turkeyLocations[val]!.first;
              });
            }
          },
        ),
        const SizedBox(height: AppSpacing.md),

        // İlçe Dropdown
        const Text(
          'İlçe',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: availableDistricts.contains(_selectedDistrict)
              ? _selectedDistrict
              : availableDistricts.first,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: availableDistricts
              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedDistrict = val);
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        // Zorunlu Adli Sicil Belgesi
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _hasUploadedCriminalDoc
                ? AppColors.successLight
                : theme.colorScheme.surface,
            borderRadius: AppRadius.cardRadius,
            border: Border.all(
              color: _hasUploadedCriminalDoc
                  ? AppColors.success
                  : theme.colorScheme.outline,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _hasUploadedCriminalDoc
                        ? Icons.check_circle_rounded
                        : Icons.gavel_rounded,
                    color: _hasUploadedCriminalDoc
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Zorunlu Adli Sicil Kaydı Belgesi',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Topluluk güvenliği için tüm üyeler adli sicil kaydı sunmalıdır.',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: Text(
                  _hasUploadedCriminalDoc
                      ? 'Belge Doğrulandı (e-Devlet)'
                      : 'e-Devlet İle Belge Doğrula',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasUploadedCriminalDoc
                      ? AppColors.success
                      : AppColors.primary,
                  minimumSize: const Size(double.infinity, 42),
                ),
                onPressed: () {
                  _launchExternalUrl(AppConstants.eDevletSabikaUrl, () {
                    setState(() => _hasUploadedCriminalDoc = true);
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Zorunlu Öğrenci Belgesi (if student)
        if (_isStudent) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _hasUploadedStudentDoc
                  ? AppColors.successLight
                  : theme.colorScheme.surface,
              borderRadius: AppRadius.cardRadius,
              border: Border.all(
                color: _hasUploadedStudentDoc
                    ? AppColors.success
                    : theme.colorScheme.outline,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _hasUploadedStudentDoc
                          ? Icons.check_circle_rounded
                          : Icons.school_rounded,
                      color: _hasUploadedStudentDoc
                          ? AppColors.success
                          : AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Zorunlu Öğrenci Belgesi',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Öğrenci indirimi (%20) hakkından faydalanabilmek için öğrenci belgenizi bağlayın.',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: Text(
                    _hasUploadedStudentDoc
                        ? 'Öğrenci Belgesi Doğrulandı'
                        : 'YÖK / e-Devlet İle Doğrula',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasUploadedStudentDoc
                        ? AppColors.success
                        : AppColors.secondary,
                    minimumSize: const Size(double.infinity, 42),
                  ),
                  onPressed: () {
                    _launchExternalUrl(AppConstants.eDevletOgrenciUrl, () {
                      setState(() => _hasUploadedStudentDoc = true);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChoiceChip(
    String label,
    bool isSelected,
    VoidCallback onSelected,
  ) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
      ),
      side: BorderSide(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withValues(alpha: 0.5),
      ),
    );
  }
}
