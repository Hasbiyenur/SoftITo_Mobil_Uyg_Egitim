import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/listing_entity.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/listing/listing_bloc.dart';
import '../../bloc/listing/listing_event.dart';

/// Kullanıcının evindeki müsait bir odayı veya evi kiraya vermek üzere sisteme yeni ilan eklediği ekran.
/// İlan başlığı, açıklama, kira bedeli, şehir/ilçe seçimi, tercih edilen kiracı cinsiyeti,
/// sigara ve evcil hayvan kuralları gibi alanları içerir.
class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();

  // Seçili konum ve kriterler
  String _selectedCity = 'İstanbul';
  String _selectedDistrict = 'Kadıköy';
  String _preferredGender = 'Farketmez';
  final String _preferredOccupation = 'Öğrenci veya Çalışan';
  bool _petAllowed = false;
  bool _smokingAllowed = false;
  final String _sleepSchedule = 'farketmez';
  final String _cleaningSensitivity = 'orta';
  final Set<String> _languages = {'Türkçe'};

  // Şehir ve bağlı ilçelerin listesi
  final Map<String, List<String>> _cityDistricts = {
    'İstanbul': ['Kadıköy', 'Beşiktaş', 'Şişli', 'Üsküdar', 'Beyoğlu', 'Sarıyer'],
    'Ankara': ['Çankaya', 'Yenimahalle', 'Keçiören', 'Etimesgut'],
    'İzmir': ['Karşıyaka', 'Bornova', 'Konak', 'Buca'],
    'Antalya': ['Muratpaşa', 'Konyaaltı'],
    'Bursa': ['Nilüfer', 'Osmangazi'],
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// Form alanlarını doğrular, ListingEntity nesnesini üretir ve ListingBloc'a ekler.
  void _submitListing() {
    if (_formKey.currentState?.validate() ?? false) {
      final authState = context.read<AuthBloc>().state;
      final user = authState is AuthenticatedState ? authState.user : null;

      final double price = double.tryParse(_priceController.text.trim()) ?? 10000;

      // Yeni kullanıcı ilanı nesnesi oluşturuluyor
      final newListing = ListingEntity(
        id: 'listing-${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        imageUrl:
            'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=800&q=80',
        monthlyRent: price,
        city: _selectedCity,
        district: _selectedDistrict,
        owner: OwnerInfo(
          id: user?.id ?? 'user-demo-1',
          name: user?.name ?? 'Ev Sahibi',
          email: user?.email ?? '',
          avatarUrl: user?.avatarUrl ??
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
          gender: user?.gender ?? 'Kadın',
          occupation: user?.occupation ?? 'Yazılım Mühendisi',
          isStudent: user?.isStudent ?? false,
        ),
        preferences: ListingPreferences(
          smokingAllowed: _smokingAllowed,
          petAllowed: _petAllowed,
          sleepSchedule: _sleepSchedule,
          cleaningSensitivity: _cleaningSensitivity,
          languages: _languages.toList(),
          preferredGender: _preferredGender,
          preferredOccupation: _preferredOccupation,
        ),
        isWinterDiscountEligible: true,
        createdAt: DateTime.now(),
        isUserCreated: true,
        isActive: true,
      );

      // BLoC'a yeni ilan olayını bildir
      context.read<ListingBloc>().add(AddNewListingEvent(newListing));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İlanınız başarıyla yayınlandı ve Keşfet\'e eklendi!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final districts = _cityDistricts[_selectedCity] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni İlan Ver'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ev & Oda Bilgileri',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Kiraya vermek istediğiniz odanın temel detaylarını girin.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              // İlan Başlığı
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'İlan Başlığı',
                  hintText: 'Örn: Kadıköy Moda\'da Ferah Aydınlık Oda',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Lütfen başlık girin.' : null,
              ),
              const SizedBox(height: 16),
              // İlan Açıklaması
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'İlan Açıklaması',
                  hintText: 'Evin durumu, konumu, aradığınız oda arkadaşı...',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Lütfen açıklama girin.' : null,
              ),
              const SizedBox(height: 16),
              // Kira Bedeli
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Aylık Kira Bedeli (TL)',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Lütfen kira bedeli girin.' : null,
              ),
              const SizedBox(height: 20),
              // Şehir ve İlçe Açılır Menüleri (Dropdowns)
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCity,
                      decoration: const InputDecoration(labelText: 'Şehir'),
                      items: _cityDistricts.keys.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (newCity) {
                        if (newCity != null) {
                          setState(() {
                            _selectedCity = newCity;
                            _selectedDistrict =
                                _cityDistricts[newCity]!.first;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedDistrict,
                      decoration: const InputDecoration(labelText: 'İlçe'),
                      items: districts.map((d) {
                        return DropdownMenuItem(value: d, child: Text(d));
                      }).toList(),
                      onChanged: (newDist) {
                        if (newDist != null) {
                          setState(() => _selectedDistrict = newDist);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const Divider(height: 36),
              // Tercih Edilen Oda Arkadaşı Kriterleri
              const Text(
                'Tercih Edilen Kiracı Kriterleri',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Cinsiyet Tercihi
              DropdownButtonFormField<String>(
                initialValue: _preferredGender,
                decoration:
                    const InputDecoration(labelText: 'Tercih Edilen Cinsiyet'),
                items: const [
                  DropdownMenuItem(value: 'Farketmez', child: Text('Farketmez')),
                  DropdownMenuItem(value: 'Kadın', child: Text('Yalnızca Kadın')),
                  DropdownMenuItem(value: 'Erkek', child: Text('Yalnızca Erkek')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _preferredGender = v);
                },
              ),
              const SizedBox(height: 16),
              // Sigara & Evcil Hayvan İzinleri
              SwitchListTile(
                title: const Text('Sigara Kullanılabilir mi?'),
                value: _smokingAllowed,
                activeThumbColor: primaryColor,
                onChanged: (v) => setState(() => _smokingAllowed = v),
              ),
              SwitchListTile(
                title: const Text('Evcil Hayvan Kabul Edilir mi?'),
                value: _petAllowed,
                activeThumbColor: primaryColor,
                onChanged: (v) => setState(() => _petAllowed = v),
              ),
              const SizedBox(height: 28),
              // İlanı Yayınla Butonu
              ElevatedButton(
                onPressed: _submitListing,
                child: const Text('İlanı Yayınla'),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
