import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';

class EnvironmentalTipCard extends StatefulWidget {
  @override
  _EnvironmentalTipCardState createState() => _EnvironmentalTipCardState();
}

class _EnvironmentalTipCardState extends State<EnvironmentalTipCard> {
  int _currentTipIndex = 0;

  final List<EnvironmentalTip> _tips = [
    EnvironmentalTip(
      icon: Icons.water_drop,
      title: 'Ahorra Agua',
      description:
          'Cierra el grifo mientras te cepillas los dientes. Puedes ahorrar hasta 8 litros de agua por minuto.',
      color: AppColors.skyBlue,
    ),
    EnvironmentalTip(
      icon: Icons.recycling,
      title: 'Recicla Correctamente',
      description:
          'Separa los residuos en orgánicos, plásticos, papel y vidrio para facilitar el proceso de reciclaje.',
      color: AppColors.lightGreen,
    ),
    EnvironmentalTip(
      icon: Icons.lightbulb_outline,
      title: 'Usa LED',
      description:
          'Cambia las bombillas tradicionales por LED. Consumen 80% menos energía y duran más tiempo.',
      color: AppColors.sunYellow,
    ),
    EnvironmentalTip(
      icon: Icons.directions_bike,
      title: 'Usa Transporte Sostenible',
      description:
          'Camina, usa bicicleta o transporte público para reducir las emisiones de CO2.',
      color: AppColors.forestGreen,
    ),
    EnvironmentalTip(
      icon: Icons.shopping_bag,
      title: 'Bolsas Reutilizables',
      description:
          'Lleva bolsas reutilizables al supermercado y evita el uso de bolsas plásticas.',
      color: AppColors.earthBrown,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startTipRotation();
  }

  void _startTipRotation() {
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _tips.length;
        });
        _startTipRotation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTip = _tips[_currentTipIndex];

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(_currentTipIndex),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              currentTip.color.withOpacity(0.1),
              currentTip.color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: currentTip.color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: currentTip.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    currentTip.icon,
                    color: currentTip.color,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tip Ambiental',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        currentTip.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: currentTip.color,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTipIndicators(),
              ],
            ),
            SizedBox(height: 12),
            Text(
              currentTip.description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipIndicators() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _tips.asMap().entries.map((entry) {
        return Container(
          width: 6,
          height: 6,
          margin: EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentTipIndex == entry.key
                ? _tips[_currentTipIndex].color
                : AppColors.textLight,
          ),
        );
      }).toList(),
    );
  }
}

class EnvironmentalTip {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  EnvironmentalTip({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
