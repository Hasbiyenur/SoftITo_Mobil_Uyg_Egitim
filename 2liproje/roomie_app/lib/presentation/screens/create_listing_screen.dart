import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/style/app_radius.dart';
import '../../core/style/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_constants.dart';
import '../../core/utils/image_storage_helper.dart';
import '../../data/models/listing_model.dart';
import '../../data/models/user_model.dart';
import '../bloc/listing_bloc.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class CreateListingScreen extends StatefulWidget {
  final UserModel currentUser;

  const CreateListingScreen({super.key, required this.currentUser});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();
  final ImagePicker _picker = ImagePicker();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _neighborhoodController = TextEditingController();

  String _city = 'İstanbul';
  String _district = 'Kadıköy';
  String _homeType = 'Ayrı Oda (3+1 Daire)';
  String _preferredGender = 'Fark etmez';

  bool _petFriendly = true;
  bool _smokingAllowed = false;
  final String _sleepHabit = 'Gece';
  final String _cleanliness = 'Orta';
  final List<String> _languages = ['Türkçe', 'İngilizce'];
  final List<String> _photos = [];
  bool _isLoading = false;

  final List<String> _presetSamplePhotos = [
    'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?auto=format&fit=crop&w=800&q=80',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final xFile = await _picker.pickImage(source: source, imageQuality: 80);
      if (xFile != null) {
        final perm = await ImageStorageHelper.saveImagePermanently(xFile.path);
        setState(() => _photos.add(perm));
      }
    } catch (_) {
      // In case device camera isn't accessible
      _addSamplePresetPhoto();
    }
  }

  void _addSamplePresetPhoto() {
    final nextPreset =
        _presetSamplePhotos[_photos.length % _presetSamplePhotos.length];
    setState(() => _photos.add(nextPreset));
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _neighborhoodController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm zorunlu alanları eksiksiz doldurun.'),
        ),
      );
      return;
    }

    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen en az bir adet oda/ev fotoğrafı ekleyiniz.'),
        ),
      );
      return;
    }

    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli bir aylık kira bedeli giriniz.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final newListing = ListingModel(
      id: 'listing_${_uuid.v4().substring(0, 8)}',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      monthlyPrice: price,
      city: _city,
      district: _district,
      neighborhood: _neighborhoodController.text.trim(),
      images: List.from(_photos),
      owner: ListingOwnerModel(
        id: widget.currentUser.id,
        fullName: widget.currentUser.fullName,
        email: widget.currentUser.email,
        avatar: widget.currentUser.avatar,
        age: widget.currentUser.age,
        gender: widget.currentUser.gender,
        occupation: widget.currentUser.occupation,
        phone: widget.currentUser.phone,
        rating: 5.0,
      ),
      preferences: ListingPreferencesModel(
        petFriendly: _petFriendly,
        smokingAllowed: _smokingAllowed,
        sleepHabit: _sleepHabit,
        cleanliness: _cleanliness,
        languages: _languages,
        preferredGender: _preferredGender,
        isStudentFriendly: true,
        homeType: _homeType,
      ),
      isWinterDiscountEligible: AppConstants.winterDiscountCities.contains(
        _city,
      ),
      createdAt: DateTime.now(),
      isMyListing: true,
      status: 'active',
    );

    context.read<ListingBloc>().add(CreateListingEvent(newListing));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('İlanınız başarıyla oluşturuldu ve yayına alındı!'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableDistricts =
        AppConstants.turkeyLocations[_city] ?? ['Merkez'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yeni İlan Oluştur',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.inputRadius,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Oluşturduğunuz ilan anında Keşfet akışında ve "Kiraya Verdiklerim" listenizde görünecektir.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.standard),

                // Photos Section
                const Text(
                  'İlan Fotoğrafları *',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Add Photo Button
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (ctx) => SafeArea(
                              child: Wrap(
                                children: [
                                  ListTile(
                                    leading: const Icon(
                                      Icons.camera_alt_rounded,
                                    ),
                                    title: const Text('Kameradan Çek'),
                                    onTap: () {
                                      Navigator.of(ctx).pop();
                                      _pickImage(ImageSource.camera);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.photo_library_rounded,
                                    ),
                                    title: const Text('Galeriden Seç'),
                                    onTap: () {
                                      Navigator.of(ctx).pop();
                                      _pickImage(ImageSource.gallery);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.auto_awesome_rounded,
                                      color: AppColors.primary,
                                    ),
                                    title: const Text(
                                      'Örnek Kaliteli Oda Fotoğrafı Ekle (Demo)',
                                    ),
                                    onTap: () {
                                      Navigator.of(ctx).pop();
                                      _addSamplePresetPhoto();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.primary,
                              width: 1.5,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: AppRadius.inputRadius,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.05,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_rounded,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Fotoğraf Ekle',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Picked Photos Preview
                      ..._photos.asMap().entries.map((entry) {
                        final index = entry.key;
                        final photo = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 100,
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: AppRadius.inputRadius,
                                child: SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: photo.startsWith('http')
                                      ? Image.network(photo, fit: BoxFit.cover)
                                      : Image.file(
                                          File(photo),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _photos.removeAt(index)),
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.standard),

                // Title
                CustomTextField(
                  label: 'İlan Başlığı *',
                  hint: 'Örn: Kadıköy Moda\'da Ferah ve Balkonlu Oda',
                  controller: _titleController,
                ),
                const SizedBox(height: AppSpacing.md),

                // Monthly Rent
                CustomTextField(
                  label: 'Aylık Kira Bedeli (TL) *',
                  hint: '15000',
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.currency_lira_rounded),
                ),
                const SizedBox(height: AppSpacing.md),

                // Location (City & District)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'İl *',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _city,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                            items: AppConstants.turkeyLocations.keys
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _city = val;
                                  _district =
                                      AppConstants.turkeyLocations[val]!.first;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'İlçe *',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: availableDistricts.contains(_district)
                                ? _district
                                : availableDistricts.first,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                            items: availableDistricts
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _district = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Neighborhood
                CustomTextField(
                  label: 'Mahalle / Cadde Bilgisi *',
                  hint: 'Örn: Caferağa Mah. Moda Cad.',
                  controller: _neighborhoodController,
                ),
                const SizedBox(height: AppSpacing.md),

                // Home Type
                const Text(
                  'Ev / Oda Tipi',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _homeType,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  items: AppConstants.homeTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _homeType = val);
                  },
                ),
                const SizedBox(height: AppSpacing.standard),

                // Roommate Preferences
                const Text(
                  'Aranan Ev Arkadaşı Özellikleri',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 8),

                // Pet friendly
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Evcil Hayvana Uygun',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  value: _petFriendly,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _petFriendly = val),
                ),

                // Smoking
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Sigara Kullanılabilir',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  value: _smokingAllowed,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _smokingAllowed = val),
                ),
                const SizedBox(height: 8),

                // Preferred Gender
                const Text(
                  'Tercih Edilen Cinsiyet',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: AppConstants.genderOptions.map((g) {
                    final isSelected = _preferredGender == g;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(g),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _preferredGender = g),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),

                // Description
                CustomTextField(
                  label: 'İlan Açıklaması *',
                  hint: 'Odanın konumu, ulaşım imkanları, ortak alanlar ve beklentilerinizi detaylıca anlatın...',
                  controller: _descController,
                  maxLines: 4,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Submit Button
                CustomButton(
                  text: 'İlanı Yayınla',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
