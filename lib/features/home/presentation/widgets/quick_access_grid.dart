import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';

class QuickAccessGrid extends StatelessWidget {
  final List<QuickAccessItem> _items = [
    QuickAccessItem(
      icon: Icons.newspaper,
      title: 'Noticias',
      route: '/news',
      color: AppColors.secondaryBlue,
    ),
    QuickAccessItem(
      icon: Icons.nature,
      title: 'Áreas Protegidas',
      route: '/protected-areas',
      color: AppColors.forestGreen,
    ),
    QuickAccessItem(
      icon: Icons.video_library,
      title: 'Videos',
      route: '/videos',
      color: AppColors.warning,
    ),
    QuickAccessItem(
      icon: Icons.volunteer_activism,
      title: 'Voluntariado',
      route: '/volunteer',
      color: AppColors.accentGreen,
    ),
    QuickAccessItem(
      icon: Icons.eco,
      title: 'Medidas Ambientales',
      route: '/environmental-measures',
      color: AppColors.lightGreen,
    ),
    QuickAccessItem(
      icon: Icons.map,
      title: 'Mapa de Áreas',
      route: '/areas-map',
      color: AppColors.skyBlue,
    ),
    QuickAccessItem(
      icon: Icons.group,
      title: 'Nuestro Equipo',
      route: '/team',
      color: AppColors.earthBrown,
    ),
    QuickAccessItem(
      icon: Icons.room_service,
      title: 'Servicios',
      route: '/services',
      color: AppColors.primaryGreen,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return _buildQuickAccessItem(context, item);
      },
    );
  }

  Widget _buildQuickAccessItem(BuildContext context, QuickAccessItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, item.route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, color: item.color, size: 24),
            ),
            SizedBox(height: 8),
            Text(
              item.title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class QuickAccessItem {
  final IconData icon;
  final String title;
  final String route;
  final Color color;

  QuickAccessItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.color,
  });
}
