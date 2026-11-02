import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/vehicle_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final favoriteVehicles = appState.favoriteVehicles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favori Araçlarım'),
      ),
      body: favoriteVehicles.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'Henüz Favori Araç Yok',
              message:
                  'Beğendiğiniz araçların kalp ikonuna dokunarak favorilerinize ekleyebilir, daha sonra hızlıca kiralayabilirsiniz.',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: favoriteVehicles.length,
              itemBuilder: (context, index) {
                final vehicle = favoriteVehicles[index];
                return VehicleCard(vehicle: vehicle);
              },
            ),
    );
  }
}
