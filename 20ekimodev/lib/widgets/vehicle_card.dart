import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../screens/reservation_screen.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final bool showDeleteButton;
  final VoidCallback? onDeletePressed;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.showDeleteButton = false,
    this.onDeletePressed,
  });

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'elektrikli':
        return Icons.electric_car_rounded;
      case 'suv':
        return Icons.airport_shuttle_rounded;
      case 'spor':
        return Icons.speed_rounded;
      case 'ticari':
        return Icons.local_shipping_rounded;
      case 'hatchback':
        return Icons.directions_car_outlined;
      case 'sedan':
      default:
        return Icons.directions_car_filled_rounded;
    }
  }

  Color _getTypeColor(String type, bool isDark) {
    switch (type.toLowerCase()) {
      case 'elektrikli':
        return isDark ? Colors.tealAccent : const Color(0xFF0D9488);
      case 'suv':
        return isDark ? Colors.amberAccent : const Color(0xFFD97706);
      case 'spor':
        return isDark ? Colors.redAccent : const Color(0xFFDC2626);
      case 'ticari':
        return isDark ? Colors.orangeAccent : const Color(0xFFEA580C);
      case 'hatchback':
        return isDark ? Colors.lightBlueAccent : const Color(0xFF0284C7);
      case 'sedan':
      default:
        return isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
    }
  }

  Color _getColorFromVehicleColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'siyah':
        return Colors.black;
      case 'beyaz':
        return Colors.white;
      case 'gri':
      case 'füme':
        return Colors.grey;
      case 'kırmızı':
        return Colors.red;
      case 'mavi':
        return Colors.blue;
      case 'yeşil':
        return Colors.green;
      case 'sarı':
        return Colors.amber;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appState = AppStateScope.of(context);
    final isFav = appState.isFavorite(vehicle.id);
    final isOwner = vehicle.ownerId == appState.currentUserId;
    final typeColor = _getTypeColor(vehicle.type, isDark);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Banner & Görsel Alanı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        typeColor.withValues(alpha: 0.2),
                        theme.colorScheme.surface,
                      ]
                    : [
                        typeColor.withValues(alpha: 0.12),
                        Colors.white,
                      ],
              ),
            ),
            child: Row(
              children: [
                // Araç Tipi İkon Kutusu
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: isDark ? 0.25 : 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: typeColor.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    _getTypeIcon(vehicle.type),
                    color: typeColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                // Marka, Model ve Tip Etiketi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: isDark ? 0.25 : 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              vehicle.type.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: typeColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (isOwner) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.withValues(alpha: isDark ? 0.3 : 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.purple.withValues(alpha: 0.4),
                                ),
                              ),
                              child: const Text(
                                'Aracınız',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.purple,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
                // Favorileme Butonu
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? Colors.redAccent : Colors.grey,
                  ),
                  tooltip: isFav ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                  onPressed: () {
                    appState.toggleFavorite(vehicle.id);
                  },
                ),
              ],
            ),
          ),

          // Bilgi Rozetleri (Konum, Km, Renk)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildInfoBadge(
                  context,
                  Icons.location_on_outlined,
                  vehicle.location,
                ),
                _buildInfoBadge(
                  context,
                  Icons.speed_outlined,
                  AppFormatters.formatKm(vehicle.kilometers),
                ),
                _buildColorBadge(context, vehicle.color),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.5),

          // Alt Bar: Saatlik Ücret ve Rezervasyon Yap Butonu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saatlik Ücret',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          AppFormatters.formatCurrency(vehicle.hourlyPrice),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          ' / saat',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (showDeleteButton && onDeletePressed != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                        tooltip: 'Aracı Sil',
                        onPressed: onDeletePressed,
                      ),
                    ElevatedButton(
                      onPressed: isOwner
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Kendi eklediğiniz aracı kiralayamazsınız.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ReservationScreen(vehicle: vehicle),
                                ),
                              );
                            },
                      style: isOwner
                          ? ElevatedButton.styleFrom(
                              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                              foregroundColor: isDark ? Colors.grey[400] : Colors.grey[700],
                            )
                          : null,
                      child: Text(isOwner ? 'Kendi Aracınız' : 'Rezervasyon Yap'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorBadge(BuildContext context, String colorName) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _getColorFromVehicleColor(colorName);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.white30 : Colors.black26,
                width: 1,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            colorName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
