import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/sample_data.dart';
import '../models/vehicle.dart';
import '../state/app_state.dart';
import '../widgets/common_text_field.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();

  String _selectedType = 'Sedan';
  final List<String> _types = [
    'Sedan',
    'SUV',
    'Hatchback',
    'Spor',
    'Elektrikli',
    'Ticari',
  ];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: demoUserFirstName);
    _lastNameController = TextEditingController(text: demoUserLastName);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _kmController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _brandController.clear();
    _modelController.clear();
    _colorController.clear();
    _locationController.clear();
    _priceController.clear();
    _kmController.clear();
    setState(() {
      _selectedType = 'Sedan';
      _firstNameController.text = demoUserFirstName;
      _lastNameController.text = demoUserLastName;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final appState = AppStateScope.of(context);

    final hourlyPrice = double.parse(_priceController.text.trim());
    final kilometers = int.parse(_kmController.text.trim());

    final newVehicle = Vehicle(
      id: 'v_${DateTime.now().millisecondsSinceEpoch}',
      ownerId: appState.currentUserId,
      ownerFirstName: _firstNameController.text.trim(),
      ownerLastName: _lastNameController.text.trim(),
      type: _selectedType,
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      color: _colorController.text.trim(),
      location: _locationController.text.trim(),
      hourlyPrice: hourlyPrice,
      kilometers: kilometers,
    );

    appState.addVehicle(newVehicle);

    // Başarı Diyaloğu
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green),
            SizedBox(width: 8),
            Text('Araç Eklendi'),
          ],
        ),
        content: Text(
          '${newVehicle.title} başarıyla sisteme eklendi. Ana Sayfa ve Profil > Eklenen Araçlar bölümlerinde görüntülenebilir.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetForm();
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Araç Ekle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bilgi Kartı
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.add_business_rounded,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Aracınızı kiralama filosuna ekleyin ve saatlik gelir elde etmeye başlayın.',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 1. Araç Sahibi Bilgileri
              Text(
                'Araç Sahibi Bilgileri',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CommonTextField(
                      controller: _firstNameController,
                      labelText: 'Sahip Adı *',
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ad boş bırakılamaz';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CommonTextField(
                      controller: _lastNameController,
                      labelText: 'Sahip Soyadı *',
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Soyad boş bırakılamaz';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 2. Araç Detayları
              Text(
                'Araç Detayları',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Araç Türü Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Araç Türü *',
                  prefixIcon: Icon(Icons.category_outlined, size: 20),
                ),
                items: _types.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedType = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              // Marka ve Model
              Row(
                children: [
                  Expanded(
                    child: CommonTextField(
                      controller: _brandController,
                      labelText: 'Marka *',
                      hintText: 'Örn: Volkswagen',
                      prefixIcon: Icons.directions_car_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Marka boş bırakılamaz';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CommonTextField(
                      controller: _modelController,
                      labelText: 'Model *',
                      hintText: 'Örn: Golf',
                      prefixIcon: Icons.drive_file_rename_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Model boş bırakılamaz';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Renk ve Konum
              Row(
                children: [
                  Expanded(
                    child: CommonTextField(
                      controller: _colorController,
                      labelText: 'Renk *',
                      hintText: 'Örn: Gri',
                      prefixIcon: Icons.palette_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Renk boş bırakılamaz';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CommonTextField(
                      controller: _locationController,
                      labelText: 'Konum / İlçe *',
                      hintText: 'Örn: Kadıköy',
                      prefixIcon: Icons.location_on_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Konum boş bırakılamaz';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Saatlik Fiyat ve Kilometre
              Row(
                children: [
                  Expanded(
                    child: CommonTextField(
                      controller: _priceController,
                      labelText: 'Saatlik Fiyat (TL) *',
                      hintText: 'Örn: 350',
                      prefixIcon: Icons.payments_outlined,
                      suffixText: 'TL',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Fiyat boş bırakılamaz';
                        }
                        final price = double.tryParse(value.trim());
                        if (price == null || price <= 0) {
                          return 'Fiyat 0\'dan büyük olmalıdır';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CommonTextField(
                      controller: _kmController,
                      labelText: 'Kilometre (km) *',
                      hintText: 'Örn: 45000',
                      prefixIcon: Icons.speed_outlined,
                      suffixText: 'km',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Kilometre boş bırakılamaz';
                        }
                        final km = int.tryParse(value.trim());
                        if (km == null || km < 0) {
                          return 'Kilometre negatif olamaz';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text(
                    'Aracı Kaydet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
