// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/custom_drawer.dart';
import '../widgets/home_card.dart';
import '../widgets/environmental_tip_card.dart';
import '../widgets/quick_access_grid.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentSlideIndex = 0;
  Timer? _timer;

  final List<SlideData> _slides = [
    SlideData(
      title: '🌱 Protegemos nuestro medio ambiente',
      subtitle: 'Trabajamos juntos por un futuro sostenible',
      description:
          'El Ministerio de Medio Ambiente está comprometido con la conservación y protección de los recursos naturales de República Dominicana.',
      imageUrl:
          'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&h=400&fit=crop',
      color: AppColors.forestGreen,
    ),
    SlideData(
      title: '🏞️ Áreas Protegidas',
      subtitle: 'Conservando la biodiversidad nacional',
      description:
          'Descubre nuestros parques nacionales, reservas y áreas protegidas que preservan la rica biodiversidad dominicana.',
      imageUrl:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=400&fit=crop',
      color: AppColors.primaryGreen,
    ),
    SlideData(
      title: '♻️ Educación Ambiental',
      subtitle: 'Aprendamos a cuidar nuestro planeta',
      description:
          'Recursos educativos y consejos prácticos para adoptar un estilo de vida más sostenible y respetuoso con el medio ambiente.',
      imageUrl:
          'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800&h=400&fit=crop',
      color: AppColors.lightGreen,
    ),
    SlideData(
      title: '🌊 Cambio Climático',
      subtitle: 'Acciones para un futuro resiliente',
      description:
          'Conoce las medidas que implementamos para mitigar y adaptarnos al cambio climático en República Dominicana.',
      imageUrl:
          'https://images.unsplash.com/photo-1569163139394-de44cb3c4f95?w=800&h=400&fit=crop',
      color: AppColors.secondaryBlue,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_currentSlideIndex < _slides.length - 1) {
        _currentSlideIndex++;
      } else {
        _currentSlideIndex = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentSlideIndex,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ministerio de Medio Ambiente',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Notificaciones en desarrollo'),
                  backgroundColor: AppColors.primaryGreen,
                ),
              );
            },
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildManualCarousel(),
            _buildWelcomeSection(),
            _buildQuickAccessSection(),
            _buildEnvironmentalTipsSection(),
            _buildLatestNewsSection(),
            SizedBox(height: 20),
          ],
        ),
      ),
      // 🚀 AGREGAR ESTE FLOATING ACTION BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/test-api'),
        child: Icon(Icons.api),
        backgroundColor: Colors.blue,
        tooltip: 'Test API',
      ),
    );
  }

  Widget _buildManualCarousel() {
    return Container(
      height: 280,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentSlideIndex = index;
                });
              },
              itemCount: _slides.length,
              itemBuilder: (context, index) {
                return _buildSlideItem(_slides[index]);
              },
            ),
          ),
          _buildSlideIndicators(),
        ],
      ),
    );
  }

  Widget _buildSlideItem(SlideData slide) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [slide.color, slide.color.withOpacity(0.8)],
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(slide.imageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  slide.color.withOpacity(0.7),
                  BlendMode.overlay,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  slide.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  slide.subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  slide.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.4,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideIndicators() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _slides.asMap().entries.map((entry) {
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                entry.key,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              width: _currentSlideIndex == entry.key ? 24 : 8,
              height: 8,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentSlideIndex == entry.key
                    ? AppColors.primaryGreen
                    : AppColors.textLight,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Bienvenido!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Explora nuestros servicios y contribuye a la protección del medio ambiente en República Dominicana.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acceso Rápido',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          QuickAccessGrid(),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalTipsSection() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tips Ambientales',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/environmental-measures');
                },
                child: Text(
                  'Ver más',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          EnvironmentalTipCard(),
        ],
      ),
    );
  }

  Widget _buildLatestNewsSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Noticias Recientes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/news');
                },
                child: Text(
                  'Ver todas',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          HomeCard(
            title: 'Nueva campaña de reforestación',
            subtitle: 'Plantamos 10,000 árboles en Santiago',
            imageUrl:
                'https://images.unsplash.com/photo-1574263867128-a3d5c1b1debc?w=400&h=200&fit=crop',
            onTap: () {
              Navigator.pushNamed(context, '/news');
            },
          ),
        ],
      ),
    );
  }
}

class SlideData {
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final Color color;

  SlideData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.color,
  });
}
