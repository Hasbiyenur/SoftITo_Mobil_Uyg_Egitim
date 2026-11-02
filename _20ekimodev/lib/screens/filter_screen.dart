import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/vehicle.dart';
import '../state/app_state.dart';
import '../widgets/common_text_field.dart';
import '../widgets/empty_state.dart';
import '../widgets/vehicle_card.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String? _selectedType = 'Tümü';
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  final List<String> _typeOptions = [
    'Tümü',
    'Sedan',
    'SUV',
    'Elektrikli',
    'Hatchback',
    'Spor',
    'Ticari',
  ];

  bool _hasFiltered = false;
  List<Vehicle>? _filteredVehicles;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _locationController.dispose();
    _colorController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _applyFilter(AppState appState) {
    final maxPriceText = _maxPriceController.text.trim();
    final maxPrice = double.tryParse(maxPriceText);

    final results = appState.filterVehicles(
      type: _selectedType == 'Tümü' ? null : _selectedType,
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      location: _locationController.text.trim(),
      color: _colorController.text.trim(),
      maxHourlyPrice: maxPrice,
    );

    setState(() {
      _hasFiltered = true;
      _filteredVehicles = results;
    });
  }

  void _clearFilter(AppState appState) {
    setState(() {
      _selectedType = 'Tümü';
      _brandController.clear();
      _modelController.clear();
      _locationController.clear();
      _colorController.clear();
      _maxPriceController.clear();
      _hasFiltered = false;
      _filteredVehicles = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = AppStateScope.of(context);

    // Filtre uygulanmadıysa varsayılan olarak tüm araçlar gösterilir, uygulandıysa filtrelenenler
    final displayList = _hasFiltered ? (_filteredVehicles ?? []) : appState.vehicles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Araç Filtreleme'),
        actions: [
          if (_hasFiltered)
            IconButton(
              icon: const Icon(Icons.clear_all_rounded),
              tooltip: 'Filtreleri Temizle',
              onPressed: () => _clearFilter(appState),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtreleme Formu Kartı
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.tune_rounded, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Arama Kriterleri',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Araç Türü Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Araç Türü',
                          prefixIcon: Icon(Icons.category_outlined, size: 20),
                        ),
                        items: _typeOptions.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedType = val;
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      // Marka & Model
                      Row(
                        children: [
                          Expanded(
                            child: CommonTextField(
                              controller: _brandController,
                              labelText: 'Marka',
                              hintText: 'Örn: BMW, Renault',
                              prefixIcon: Icons.directions_car_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CommonTextField(
                              controller: _modelController,
                              labelText: 'Model',
                              hintText: 'Örn: 320i, Megane',
                              prefixIcon: Icons.drive_file_rename_outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Konum & Renk
                      Row(
                        children: [
                          Expanded(
                            child: CommonTextField(
                              controller: _locationController,
                              labelText: 'Konum / İlçe',
                              hintText: 'Örn: Kadıköy',
                              prefixIcon: Icons.location_on_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CommonTextField(
                              controller: _colorController,
                              labelText: 'Renk',
                              hintText: 'Örn: Beyaz, Siyah',
                              prefixIcon: Icons.palette_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // En Yüksek Saatlik Fiyat
                      CommonTextField(
                        controller: _maxPriceController,
                        labelText: 'En Yüksek Saatlik Fiyat (TL)',
                        hintText: 'Örn: 600',
                        prefixIcon: Icons.payments_outlined,
                        suffixText: 'TL / saat',
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      const SizedBox(height: 20),

                      // Filtrele ve Temizle Butonları
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: OutlinedButton.icon(
                              onPressed: () => _clearFilter(appState),
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Temizle'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () => _applyFilter(appState),
                              icon: const Icon(Icons.filter_list_rounded, size: 18),
                              label: const Text('Filtrele'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Filtrelenen Araçlar Başlığı
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtrelenen Araçlar',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${displayList.length} araç',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sonuç Listesi
            if (displayList.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 40),
                child: EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Eşleşen Araç Bulunamadı',
                  message:
                      'Belirlediğiniz arama ve filtre kriterlerine uygun araç bulunamadı. Lütfen kriterlerinizi gevşetip tekrar deneyiniz.',
                  actionLabel: 'Filtreleri Temizle',
                  onActionPressed: () => _clearFilter(appState),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  final vehicle = displayList[index];
                  return VehicleCard(vehicle: vehicle);
                },
              ),
          ],
        ),
      ),
    );
  }
}
