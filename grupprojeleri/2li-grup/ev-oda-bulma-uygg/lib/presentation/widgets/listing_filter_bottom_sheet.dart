import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/listing/listing_bloc.dart';
import '../bloc/listing/listing_event.dart';

/// İlan arama ekranında kullanıcının fiyat aralığı, şehir, ev kuralları (sigara, evcil hayvan),
/// uyku düzeni, temizlik seviyesi ve dil tercihine göre filtreleme yapmasını sağlayan modal alt panel (BottomSheet).
class ListingFilterBottomSheet extends StatefulWidget {
  final ListingFilterCriteria initialFilters;

  const ListingFilterBottomSheet({super.key, required this.initialFilters});

  /// Alt filtre panelini açan yardımcı statik metot.
  static Future<void> show(BuildContext context, ListingFilterCriteria current) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ListingFilterBottomSheet(initialFilters: current),
    );
  }

  @override
  State<ListingFilterBottomSheet> createState() =>
      _ListingFilterBottomSheetState();
}

class _ListingFilterBottomSheetState extends State<ListingFilterBottomSheet> {
  late RangeValues _priceRange;
  String? _selectedCity;
  bool? _petAllowed;
  bool? _smokingAllowed;
  String _sleepSchedule = 'farketmez';
  String _cleaningSensitivity = 'hepsi';
  String? _selectedLanguage;

  final List<String> _cities = ['Tümü', 'İstanbul', 'Ankara', 'İzmir', 'Antalya', 'Bursa'];
  final List<String> _languages = ['Tümü', 'Türkçe', 'İngilizce', 'Almanca', 'Fransızca'];

  @override
  void initState() {
    super.initState();
    // Mevcut filtre kriterlerini panele yükle
    _priceRange = RangeValues(
      widget.initialFilters.minPrice ?? 5000,
      widget.initialFilters.maxPrice ?? 25000,
    );
    _selectedCity = widget.initialFilters.city;
    _petAllowed = widget.initialFilters.petAllowed;
    _smokingAllowed = widget.initialFilters.smokingAllowed;
    _sleepSchedule = widget.initialFilters.sleepSchedule ?? 'farketmez';
    _cleaningSensitivity = widget.initialFilters.cleaningSensitivity ?? 'hepsi';
    _selectedLanguage = widget.initialFilters.language;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Sürükleme tutamacı
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(80),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          // Başlık ve 'Temizle' butonu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtreler',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    context.read<ListingBloc>().add(ClearFilterEvent());
                    Navigator.of(context).pop();
                  },
                  child: const Text('Temizle'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Filtre Seçenekleri Kaydırma Alanı
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Fiyat Aralığı Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Aylık Fiyat Aralığı',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_priceRange.start.round()} ₺ - ${_priceRange.end.round()} ₺',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 3000,
                    max: 30000,
                    divisions: 27,
                    activeColor: primaryColor,
                    onChanged: (values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // 2. Şehir Seçimi
                  const Text(
                    'Şehir',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _cities.map((city) {
                      final isSelected = (_selectedCity == null && city == 'Tümü') ||
                          _selectedCity == city;
                      return ChoiceChip(
                        label: Text(city),
                        selected: isSelected,
                        selectedColor: primaryColor.withAlpha(50),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCity = city == 'Tümü' ? null : city;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  // 3. Evcil Hayvan & Sigara Uygunluğu
                  const Text(
                    'Ev Kuralları & Uygunluk',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FilterChip(
                          label: const Text('Evcil Hayvan Dostu'),
                          selected: _petAllowed == true,
                          selectedColor: primaryColor.withAlpha(50),
                          onSelected: (selected) {
                            setState(() {
                              _petAllowed = selected ? true : null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilterChip(
                          label: const Text('Sigara Serbest'),
                          selected: _smokingAllowed == true,
                          selectedColor: primaryColor.withAlpha(50),
                          onSelected: (selected) {
                            setState(() {
                              _smokingAllowed = selected ? true : null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 4. Uyku Düzeni Seçimi
                  const Text(
                    'Uyku Düzeni',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      {'label': 'Farketmez', 'val': 'farketmez'},
                      {'label': 'Gece Kuşu (Gece)', 'val': 'gece'},
                      {'label': 'Erkenci (Sabah)', 'val': 'sabah'},
                    ].map((item) {
                      final isSelected = _sleepSchedule == item['val'];
                      return ChoiceChip(
                        label: Text(item['label']!),
                        selected: isSelected,
                        selectedColor: primaryColor.withAlpha(50),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _sleepSchedule = item['val']!);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  // 5. Temizlik Hassasiyeti Seçimi
                  const Text(
                    'Temizlik Hassasiyeti',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['hepsi', 'az', 'orta', 'çok'].map((clean) {
                      final isSelected = _cleaningSensitivity == clean;
                      return ChoiceChip(
                        label: Text(clean == 'hepsi'
                            ? 'Farketmez'
                            : clean.toUpperCase()),
                        selected: isSelected,
                        selectedColor: primaryColor.withAlpha(50),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _cleaningSensitivity = clean);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  // 6. Ortak Dil Tercihi
                  const Text(
                    'Ortak Dil',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _languages.map((lang) {
                      final isSelected =
                          (_selectedLanguage == null && lang == 'Tümü') ||
                              _selectedLanguage == lang;
                      return ChoiceChip(
                        label: Text(lang),
                        selected: isSelected,
                        selectedColor: primaryColor.withAlpha(50),
                        onSelected: (selected) {
                          setState(() {
                            _selectedLanguage = lang == 'Tümü' ? null : lang;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          // Filtreleri Uygula Butonu
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.withAlpha(40))),
            ),
            child: ElevatedButton(
              onPressed: () {
                final filters = ListingFilterCriteria(
                  minPrice: _priceRange.start,
                  maxPrice: _priceRange.end,
                  city: _selectedCity,
                  petAllowed: _petAllowed,
                  smokingAllowed: _smokingAllowed,
                  sleepSchedule: _sleepSchedule,
                  cleaningSensitivity: _cleaningSensitivity,
                  language: _selectedLanguage,
                );
                context.read<ListingBloc>().add(ApplyFilterEvent(filters));
                Navigator.of(context).pop();
              },
              child: const Text('Filtreleri Uygula'),
            ),
          ),
        ],
      ),
    );
  }
}
