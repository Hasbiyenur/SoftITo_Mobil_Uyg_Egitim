import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../state/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/vehicle_card.dart';

class MyVehiclesScreen extends StatelessWidget {
  const MyVehiclesScreen({super.key});

  void _onDeleteVehicle(BuildContext context, AppState appState, Vehicle vehicle) {
    final canDelete = appState.canDeleteVehicle(vehicle.id);

    if (!canDelete) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
              SizedBox(width: 8),
              Text('Araç Silinemez'),
            ],
          ),
          content: Text(
            '${vehicle.title} aracına ait aktif veya geçmiş rezervasyon kayıtları bulunduğu için bu araç silinemez.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Anladım'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Aracı Sil'),
          ],
        ),
        content: Text(
          '${vehicle.title} aracını sistemden silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              final success = appState.deleteVehicle(vehicle.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.green[700],
                    content: Text('${vehicle.title} başarıyla silindi.'),
                  ),
                );
              }
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final myVehicles = appState.myVehicles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eklediğim Araçlar'),
      ),
      body: myVehicles.isEmpty
          ? const EmptyState(
              icon: Icons.garage_outlined,
              title: 'Henüz Araç Eklemediniz',
              message:
                  'Alt menüdeki "Araç Ekle" sekmesini kullanarak filoya kendi araçlarınızı ekleyebilir ve yönetebilirsiniz.',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: myVehicles.length,
              itemBuilder: (context, index) {
                final vehicle = myVehicles[index];
                return VehicleCard(
                  vehicle: vehicle,
                  showDeleteButton: true,
                  onDeletePressed: () => _onDeleteVehicle(context, appState, vehicle),
                );
              },
            ),
    );
  }
}
