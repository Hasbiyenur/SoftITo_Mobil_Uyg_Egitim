import 'package:flutter/material.dart';

import '../../core/style/app_radius.dart';
import '../../core/style/app_spacing.dart';
import '../../core/utils/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/repositories/listing_repository.dart';
import 'custom_button.dart';

class FilterBottomSheet extends StatefulWidget {
  final ListingFilterParams initialFilters;
  final void Function(ListingFilterParams) onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialFilters,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required ListingFilterParams currentFilters,
    required void Function(ListingFilterParams) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.modalRadius),
      builder: (context) =>
          FilterBottomSheet(initialFilters: currentFilters, onApply: onApply),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late RangeValues _priceRange;
  String? _selectedCity;
  String? _selectedDistrict;
  bool? _petFriendly;
  bool? _smokingAllowed;
  String? _sleepHabit;
  String? _cleanliness;
  String? _language;

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilters;
    _priceRange = RangeValues(f.minPrice ?? 5000.0, f.maxPrice ?? 30000.0);
    _selectedCity = f.city ?? 'Tümü';
    _selectedDistrict = f.district ?? 'Tümü';
    _petFriendly = f.petFriendly;
    _smokingAllowed = f.smokingAllowed;
    _sleepHabit = f.sleepHabit ?? 'Tümü';
    _cleanliness = f.cleanliness ?? 'Tümü';
    _language = f.language ?? 'Tümü';
  }

  void _reset() {
    setState(() {
      _priceRange = const RangeValues(5000.0, 30000.0);
      _selectedCity = 'Tümü';
      _selectedDistrict = 'Tümü';
      _petFriendly = null;
      _smokingAllowed = null;
      _sleepHabit = 'Tümü';
      _cleanliness = 'Tümü';
      _language = 'Tümü';
    });
  }

  void _submit() {
    final filters = ListingFilterParams(
      minPrice: _priceRange.start > 5000.0 ? _priceRange.start : null,
      maxPrice: _priceRange.end < 30000.0 ? _priceRange.end : null,
      city: _selectedCity,
      district: _selectedDistrict,
      petFriendly: _petFriendly,
      smokingAllowed: _smokingAllowed,
      sleepHabit: _sleepHabit,
      cleanliness: _cleanliness,
      language: _language,
    );
    widget.onApply(filters);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableDistricts =
        (_selectedCity != null &&
            AppConstants.turkeyLocations.containsKey(_selectedCity))
        ? ['Tümü', ...AppConstants.turkeyLocations[_selectedCity]!]
        : ['Tümü'];

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.standard,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'İlanları Filtrele',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  TextButton(onPressed: _reset, child: const Text('Temizle')),
                ],
              ),
            ),
            const Divider(),

            // Scrollable Filters
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppSpacing.standard),
                children: [
                  // Fiyat Aralığı
                  _buildSectionTitle('Aylık Kira Aralığı'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CurrencyFormatter.format(_priceRange.start),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(_priceRange.end),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 5000,
                    max: 30000,
                    divisions: 25,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Şehir Seçimi
                  _buildSectionTitle('Konum (İl)'),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCity,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: ['Tümü', ...AppConstants.turkeyLocations.keys]
                        .map(
                          (city) =>
                              DropdownMenuItem(value: city, child: Text(city)),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCity = val;
                        _selectedDistrict = 'Tümü';
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // İlçe Seçimi
                  if (_selectedCity != null && _selectedCity != 'Tümü') ...[
                    _buildSectionTitle('İlçe'),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDistrict,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: availableDistricts
                          .map(
                            (district) => DropdownMenuItem(
                              value: district,
                              child: Text(district),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedDistrict = val;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Evcil Hayvan
                  _buildSectionTitle('Evcil Hayvana Uygunluk'),
                  Row(
                    children: [
                      _buildChoiceChip(
                        'Fark etmez',
                        _petFriendly == null,
                        () => setState(() => _petFriendly = null),
                      ),
                      const SizedBox(width: 8),
                      _buildChoiceChip(
                        'Uygun (Evet)',
                        _petFriendly == true,
                        () => setState(() => _petFriendly = true),
                      ),
                      const SizedBox(width: 8),
                      _buildChoiceChip(
                        'Uygun Değil',
                        _petFriendly == false,
                        () => setState(() => _petFriendly = false),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Sigara Kullanımı
                  _buildSectionTitle('Sigara Kullanımı'),
                  Row(
                    children: [
                      _buildChoiceChip(
                        'Fark etmez',
                        _smokingAllowed == null,
                        () => setState(() => _smokingAllowed = null),
                      ),
                      const SizedBox(width: 8),
                      _buildChoiceChip(
                        'İçilebilir',
                        _smokingAllowed == true,
                        () => setState(() => _smokingAllowed = true),
                      ),
                      const SizedBox(width: 8),
                      _buildChoiceChip(
                        'İçilemez',
                        _smokingAllowed == false,
                        () => setState(() => _smokingAllowed = false),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Uyku Düzeni
                  _buildSectionTitle('Uyku Düzeni'),
                  Wrap(
                    spacing: 8,
                    children: ['Tümü', ...AppConstants.sleepHabits]
                        .map(
                          (habit) => _buildChoiceChip(
                            habit,
                            _sleepHabit == habit,
                            () => setState(() => _sleepHabit = habit),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Temizlik Hassasiyeti
                  _buildSectionTitle('Temizlik Hassasiyeti'),
                  Wrap(
                    spacing: 8,
                    children: ['Tümü', ...AppConstants.cleanlinessLevels]
                        .map(
                          (c) => _buildChoiceChip(
                            c,
                            _cleanliness == c,
                            () => setState(() => _cleanliness = c),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Konuştuğu Diller
                  _buildSectionTitle('Konuşulan Dil'),
                  Wrap(
                    spacing: 8,
                    children: ['Tümü', ...AppConstants.availableLanguages]
                        .map(
                          (lang) => _buildChoiceChip(
                            lang,
                            _language == lang,
                            () => setState(() => _language = lang),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),

            // Bottom Apply Action
            Container(
              padding: const EdgeInsets.all(AppSpacing.standard),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: CustomButton(
                text: 'Filtreleri Uygula',
                onPressed: _submit,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
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
