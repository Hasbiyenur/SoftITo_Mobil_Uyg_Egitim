import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/user_entity.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../main_navigation_screen.dart';

/// 3 Aşamalı Kullanıcı Kayıt Ekranı (Multi-Step Stepper/Wizard):
/// Aşama 1: Kişisel Bilgiler (Ad, e-posta, telefon, şifre, yaş, cinsiyet, meslek)
/// Aşama 2: Yaşam Tarzı ve Alışkanlıklar (Sigara, öğrencilik, evcil hayvan, uyku düzeni, temizlik seviyesi, diller)
/// Aşama 3: Lokasyon Tercihi (İl ve ilçe seçimi)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 0; // 0: Bilgiler, 1: Alışkanlıklar, 2: Lokasyon

  // ================= AŞAMA 1 KONTROLCÜLERİ (KİŞİSEL BİLGİLER) =================
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _photoUrlController = TextEditingController();
  final _ageController = TextEditingController();
  final _occupationController = TextEditingController();
  String _gender = 'Kadın';

  // ================= AŞAMA 2 DEĞERLERİ (ALIŞKANLIKLAR & YAŞAM TARZI) =================
  bool _smoking = false;
  bool _isStudent = true;
  bool _hasPet = false;
  String _sleepSchedule = 'gece';
  String _cleaningSensitivity = 'orta';
  final Set<String> _selectedLanguages = {'Türkçe'};

  // ================= AŞAMA 3 DEĞERLERİ (İL VE İLÇE SEÇİMİ) =================
  final Map<String, List<String>> _cityDistricts = {
    'İstanbul': [
      'Kadıköy',
      'Beşiktaş',
      'Şişli',
      'Üsküdar',
      'Beyoğlu',
      'Sarıyer',
      'Maltepe',
    ],
    'Ankara': [
      'Çankaya',
      'Yenimahalle',
      'Keçiören',
      'Etimesgut',
      'Mamak',
    ],
    'İzmir': [
      'Karşıyaka',
      'Bornova',
      'Konak',
      'Buca',
      'Çiğli',
    ],
    'Antalya': [
      'Muratpaşa',
      'Konyaaltı',
      'Kepez',
    ],
    'Bursa': [
      'Nilüfer',
      'Osmangazi',
      'Yıldırım',
    ],
  };

  late String _selectedCity;
  late String _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _selectedCity = _cityDistricts.keys.first;
    _selectedDistrict = _cityDistricts[_selectedCity]!.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _photoUrlController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  /// Uyarı ve doğrulama mesajlarını SnackBar ile ekranda gösterir.
  void _showWarning(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Aktif adımdaki form alanlarını doğrular ve geçerliyse sonraki aşamaya geçirir.
  void _validateAndNext() {
    if (_currentStep == 0) {
      if (_nameController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty ||
          _phoneController.text.trim().isEmpty ||
          _passwordController.text.isEmpty ||
          _passwordConfirmController.text.isEmpty ||
          _ageController.text.trim().isEmpty ||
          _occupationController.text.trim().isEmpty) {
        _showWarning('Lütfen tüm alanları doldurun.');
        return;
      }
      if (_passwordController.text != _passwordConfirmController.text) {
        _showWarning('Şifreler birbiriyle eşleşmiyor.');
        return;
      }
      if (_passwordController.text.length < 6) {
        _showWarning('Şifre en az 6 karakter olmalıdır.');
        return;
      }
      setState(() {
        _currentStep = 1;
      });
    } else if (_currentStep == 1) {
      if (_selectedLanguages.isEmpty) {
        _showWarning('Lütfen konuştuğunuz en az bir dil seçin.');
        return;
      }
      setState(() {
        _currentStep = 2;
      });
    } else if (_currentStep == 2) {
      _submitRegister();
    }
  }

  /// Tüm aşamalar tamamlandığında UserEntity modelini oluşturur ve BLoC'a iletir.
  void _submitRegister() {
    final newUser = UserEntity(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      avatarUrl: _photoUrlController.text.trim().isNotEmpty
          ? _photoUrlController.text.trim()
          : (_gender == 'Kadın'
              ? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80'
              : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80'),
      age: int.tryParse(_ageController.text.trim()) ?? 20,
      gender: _gender,
      occupation: _occupationController.text.trim(),
      isStudent: _isStudent,
      smoking: _smoking,
      hasPet: _hasPet,
      sleepSchedule: _sleepSchedule,
      cleaningSensitivity: _cleaningSensitivity,
      languages: _selectedLanguages.toList(),
      city: _selectedCity,
      district: _selectedDistrict,
      preferredHouseType: '2+1 Daire',
      savedAddresses: ['$_selectedDistrict, $_selectedCity'],
    );

    context.read<AuthBloc>().add(RegisterSubmittedEvent(user: newUser));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthenticatedState) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
            (route) => false,
          );
        } else if (state is AuthErrorState) {
          _showWarning(state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoadingState;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Kayıt Ol'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                if (_currentStep > 0) {
                  setState(() {
                    _currentStep--;
                  });
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Aşama İlerleme Çubuğu (Step Indicator)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      _buildStepItem(0, 'Kullanıcı Bilgileri', primaryColor),
                      _buildStepDivider(_currentStep >= 1, primaryColor),
                      _buildStepItem(1, 'Alışkanlıklar', primaryColor),
                      _buildStepDivider(_currentStep >= 2, primaryColor),
                      _buildStepItem(2, 'Lokasyon', primaryColor),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Seçili Adımın Form İçeriği
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildCurrentStepContent(primaryColor, isDark),
                  ),
                ),
                // Alt Kontrol Butonları (Geri & Sonraki/Kayıt Ol)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
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
                                : () {
                                    setState(() {
                                      _currentStep--;
                                    });
                                  },
                            child: const Text('Geri'),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _validateAndNext,
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(_currentStep == 2
                                  ? 'Kayıt Ol'
                                  : 'Sonraki Aşama'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Adım numarasını ve tamamlanma durumunu gösteren yuvarlak simge
  Widget _buildStepItem(int stepIndex, String title, Color activeColor) {
    final isDone = _currentStep > stepIndex;
    final isActive = _currentStep == stepIndex;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone || isActive
                ? activeColor
                : Colors.grey.withAlpha(60),
          ),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : Text(
                  '${stepIndex + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : Colors.grey,
                  ),
                ),
        ),
      ],
    );
  }

  /// Adımlar arasındaki bağlantı çizgisini çizen yardımcı widget
  Widget _buildStepDivider(bool isCompleted, Color activeColor) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isCompleted ? activeColor : Colors.grey.withAlpha(50),
      ),
    );
  }

  /// O anki aktif adıma göre ilgili form bileşenini döndürür
  Widget _buildCurrentStepContent(Color primaryColor, bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildStep1UserInfo();
      case 1:
        return _buildStep2Habits(primaryColor, isDark);
      case 2:
        return _buildStep3Location(primaryColor);
      default:
        return const SizedBox();
    }
  }

  /// 1. Adım: Kişisel Bilgiler Formu
  Widget _buildStep1UserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kişisel Bilgileriniz',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Profilinizi oluşturmak için temel bilgilerinizi girin.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'İsim - Soyisim',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'E-posta Adresi',
            prefixIcon: Icon(Icons.alternate_email_rounded),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Telefon Numarası',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Şifre',
            prefixIcon: Icon(Icons.lock_outline_rounded),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordConfirmController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Şifre Tekrar',
            prefixIcon: Icon(Icons.lock_reset_rounded),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Yaş',
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(
                  labelText: 'Cinsiyet (Seçmeli)',
                  prefixIcon: Icon(Icons.wc_rounded),
                ),
                items: const [
                  DropdownMenuItem(value: 'Kadın', child: Text('Kadın')),
                  DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _gender = val);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _occupationController,
          decoration: const InputDecoration(
            labelText: 'Meslek / Okul Adı',
            prefixIcon: Icon(Icons.school_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _photoUrlController,
          decoration: const InputDecoration(
            labelText: 'Profil Fotoğrafı URL (İsteğe bağlı)',
            prefixIcon: Icon(Icons.image_outlined),
          ),
        ),
      ],
    );
  }

  /// 2. Adım: Alışkanlıklar ve Yaşam Tarzı Seçimleri Formu
  Widget _buildStep2Habits(Color primaryColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Yaşam Tarzı ve Alışkanlıklar',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Doğru ev ve oda arkadaşını bulmak için alışkanlıklarınızı belirtin.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        // Sigara kullanımı anahtarı
        SwitchListTile(
          title: const Text('Sigara Kullanımı'),
          subtitle: Text(_smoking ? 'Evet, sigara içiyorum' : 'Hayır, içmiyorum'),
          value: _smoking,
          activeThumbColor: primaryColor,
          onChanged: (val) => setState(() => _smoking = val),
        ),
        const Divider(),
        // Öğrenci durumu anahtarı
        SwitchListTile(
          title: const Text('Öğrenci misiniz?'),
          subtitle: Text(_isStudent
              ? 'Evet (Öğrenci %20 indiriminden faydalanırsınız)'
              : 'Hayır, çalışıyorum'),
          value: _isStudent,
          activeThumbColor: primaryColor,
          onChanged: (val) => setState(() => _isStudent = val),
        ),
        const Divider(),
        // Evcil hayvan durumu anahtarı
        SwitchListTile(
          title: const Text('Evcil Hayvan Durumu'),
          subtitle: Text(_hasPet
              ? 'Evet, evcil hayvanım var / besliyorum'
              : 'Hayır, evcil hayvanım yok'),
          value: _hasPet,
          activeThumbColor: primaryColor,
          onChanged: (val) => setState(() => _hasPet = val),
        ),
        const Divider(),
        const SizedBox(height: 12),
        // Uyku düzeni seçimi
        const Text(
          'Uyku Düzeni (Seçmeli)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['gece', 'sabah', 'yok'].map((schedule) {
            final isSelected = _sleepSchedule == schedule;
            return ChoiceChip(
              label: Text(
                schedule == 'gece'
                    ? 'Gece Kuşu (Gece)'
                    : (schedule == 'sabah' ? 'Erkenci (Sabah)' : 'Belirli Değil (Yok)'),
              ),
              selected: isSelected,
              selectedColor: primaryColor.withAlpha(50),
              onSelected: (selected) {
                if (selected) setState(() => _sleepSchedule = schedule);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        // Temizlik hassasiyeti seçimi
        const Text(
          'Temizlik Hassasiyeti (Seçmeli)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['yok', 'az', 'orta', 'çok'].map((clean) {
            final isSelected = _cleaningSensitivity == clean;
            return ChoiceChip(
              label: Text(clean.toUpperCase()),
              selected: isSelected,
              selectedColor: primaryColor.withAlpha(50),
              onSelected: (selected) {
                if (selected) setState(() => _cleaningSensitivity = clean);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        // Konuşulan diller seçimi
        const Text(
          'Konuştuğu Diller',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['Türkçe', 'İngilizce', 'Almanca', 'Fransızca', 'İspanyolca']
              .map((lang) {
            final isSelected = _selectedLanguages.contains(lang);
            return FilterChip(
              label: Text(lang),
              selected: isSelected,
              selectedColor: primaryColor.withAlpha(50),
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
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 3. Adım: Şehir ve İlçe Tercihi Formu
  Widget _buildStep3Location(Color primaryColor) {
    final districts = _cityDistricts[_selectedCity] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lokasyon Tercihi',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Arama ve eşleşmelerde kullanılacak il ve ilçenizi seçin.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 28),
        // İl Seçimi Dropdown
        DropdownButtonFormField<String>(
          initialValue: _selectedCity,
          decoration: const InputDecoration(
            labelText: 'İl Seçimi',
            prefixIcon: Icon(Icons.location_city_rounded),
          ),
          items: _cityDistricts.keys.map((city) {
            return DropdownMenuItem(value: city, child: Text(city));
          }).toList(),
          onChanged: (newCity) {
            if (newCity != null) {
              setState(() {
                _selectedCity = newCity;
                _selectedDistrict = _cityDistricts[newCity]!.first;
              });
            }
          },
        ),
        const SizedBox(height: 20),
        // İlçe Seçimi Dropdown
        DropdownButtonFormField<String>(
          initialValue: _selectedDistrict,
          decoration: const InputDecoration(
            labelText: 'İlçe Seçimi',
            prefixIcon: Icon(Icons.map_outlined),
          ),
          items: districts.map((district) {
            return DropdownMenuItem(value: district, child: Text(district));
          }).toList(),
          onChanged: (newDistrict) {
            if (newDistrict != null) {
              setState(() {
                _selectedDistrict = newDistrict;
              });
            }
          },
        ),
        const SizedBox(height: 36),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primaryColor.withAlpha(20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primaryColor.withAlpha(60)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: primaryColor),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Kayıt tamamlandığında hesabınız oluşturulacak ve doğrudan Keşfet ana sayfasına yönlendirileceksiniz.',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
