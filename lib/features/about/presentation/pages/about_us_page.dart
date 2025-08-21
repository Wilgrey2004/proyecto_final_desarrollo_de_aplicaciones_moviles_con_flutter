// lib/features/about_us/presentation/pages/about_us_page.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/colors.dart';

class AboutUsPage extends StatefulWidget {
  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  TabController? _tabController;
  bool _isVideoInitialized = false;
  bool _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      // URL del video institucional (puedes cambiar por el video real del ministerio)
      _videoController = VideoPlayerController.network(
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      );

      await _videoController!.initialize();
      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 250.0,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Ministerio de Medio Ambiente',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 8.0,
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(0.0, 2.0),
                      ),
                    ],
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.primaryGreen, AppColors.lightGreen],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.account_balance,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'República Dominicana',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primaryGreen,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primaryGreen,
                indicatorWeight: 3,
                tabs: [
                  Tab(text: 'Historia'),
                  Tab(text: 'Misión'),
                  Tab(text: 'Visión'),
                  Tab(text: 'Video'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHistoryTab(),
                  _buildMissionTab(),
                  _buildVisionTab(),
                  _buildVideoTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Nuestra Historia', Icons.history),
          SizedBox(height: 20),
          _buildTimelineItem(
            '1967',
            'Fundación',
            'Creación del primer organismo ambiental como parte de la Secretaría de Estado de Agricultura.',
            true,
          ),
          _buildTimelineItem(
            '1982',
            'Institucionalización',
            'Establecimiento de la Dirección Nacional de Parques como entidad especializada.',
            false,
          ),
          _buildTimelineItem(
            '2000',
            'Ley General de Medio Ambiente',
            'Promulgación de la Ley 64-00 que crea el marco legal ambiental dominicano.',
            false,
          ),
          _buildTimelineItem(
            '2010',
            'Modernización',
            'Restructuración del ministerio con enfoque en sostenibilidad y cambio climático.',
            false,
          ),
          _buildTimelineItem(
            '2020',
            'Era Digital',
            'Implementación de sistemas digitales y plataformas tecnológicas para mejor gestión.',
            false,
          ),
          SizedBox(height: 30),
          _buildHighlightCard(
            'Logros Destacados',
            '• Protección de más de 25% del territorio nacional\n• Creación de 123 áreas protegidas\n• Reforestación de 50,000 hectáreas\n• Reducción del 15% en emisiones de CO2',
            Icons.emoji_events,
            AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildMissionTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Nuestra Misión', Icons.flag),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryGreen.withOpacity(0.1),
                  AppColors.lightGreen.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.nature, size: 60, color: AppColors.primaryGreen),
                SizedBox(height: 16),
                Text(
                  'Proteger, conservar y restaurar el medio ambiente y los recursos naturales de la República Dominicana, promoviendo el desarrollo sostenible y la calidad de vida de la población presente y futura.',
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.6,
                    color: AppColors.textPrimary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          _buildValueCard(
            'Sostenibilidad',
            'Promovemos el equilibrio entre desarrollo económico y conservación ambiental.',
            Icons.balance,
          ),
          SizedBox(height: 16),
          _buildValueCard(
            'Participación',
            'Fomentamos la participación ciudadana en la gestión ambiental.',
            Icons.people,
          ),
          SizedBox(height: 16),
          _buildValueCard(
            'Innovación',
            'Utilizamos tecnología y ciencia para soluciones ambientales.',
            Icons.lightbulb,
          ),
          SizedBox(height: 16),
          _buildValueCard(
            'Transparencia',
            'Garantizamos acceso a la información y rendición de cuentas.',
            Icons.visibility,
          ),
        ],
      ),
    );
  }

  Widget _buildVisionTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Nuestra Visión', Icons.visibility),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.secondaryBlue.withOpacity(0.1),
                  AppColors.lightBlue.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.secondaryBlue.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.eco, size: 60, color: AppColors.secondaryBlue),
                SizedBox(height: 16),
                Text(
                  'Ser el referente regional en gestión ambiental, liderando la transición hacia un país carbono neutral, resiliente al cambio climático y modelo de desarrollo sostenible en el Caribe.',
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.6,
                    color: AppColors.textPrimary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          _buildGoalCard(
            '2025',
            'Reducción del 25% en emisiones',
            '25% menos CO2',
          ),
          SizedBox(height: 16),
          _buildGoalCard(
            '2030',
            'Energía renovable al 50%',
            'Matriz energética limpia',
          ),
          SizedBox(height: 16),
          _buildGoalCard(
            '2035',
            'Economía circular',
            'Gestión integral de residuos',
          ),
          SizedBox(height: 16),
          _buildGoalCard(
            '2050',
            'Carbono neutral',
            'República Dominicana libre de emisiones',
          ),
          SizedBox(height: 30),
          _buildHighlightCard(
            'Compromisos Internacionales',
            '• Acuerdo de París sobre Cambio Climático\n• Objetivos de Desarrollo Sostenible (ODS)\n• Convenio sobre Diversidad Biológica\n• Convención RAMSAR sobre Humedales',
            Icons.public,
            AppColors.secondaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Video Institucional', Icons.play_circle),
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _isVideoInitialized && _videoController != null
                  ? Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: _toggleVideo,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isVideoPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.primaryGreen,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Cargando video...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Conoce nuestro trabajo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'En este video institucional podrás conocer más sobre nuestras funciones, proyectos y el impacto de nuestro trabajo en la protección del medio ambiente dominicano.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 30),
          _buildSocialMediaSection(),
          SizedBox(height: 30),
          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryGreen, size: 24),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    String year,
    String title,
    String description,
    bool isFirst,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            if (!isFirst)
              Container(
                width: 2,
                height: 60,
                color: AppColors.primaryGreen.withOpacity(0.3),
              ),
          ],
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                year,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              if (!isFirst) SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValueCard(String title, String description, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(String year, String goal, String description) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.secondaryBlue.withOpacity(0.1),
            AppColors.lightBlue.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.secondaryBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                year,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Síguenos en redes sociales',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialButton(
              'Facebook',
              Icons.facebook,
              Colors.blue[700]!,
              'https://facebook.com/medioambienterd',
            ),
            _buildSocialButton(
              'Twitter',
              Icons.alternate_email,
              Colors.blue[400]!,
              'https://twitter.com/medioambienterd',
            ),
            _buildSocialButton(
              'Instagram',
              Icons.camera_alt,
              Colors.purple[400]!,
              'https://instagram.com/medioambienterd',
            ),
            _buildSocialButton(
              'YouTube',
              Icons.play_circle,
              Colors.red[600]!,
              'https://youtube.com/medioambienterd',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(
    String name,
    IconData icon,
    Color color,
    String url,
  ) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información de Contacto',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(height: 16),
          _buildContactItem(
            Icons.location_on,
            'Dirección',
            'Av. Cayetano Germosén, Esq. Av. Gregorio Luperón, Santo Domingo',
          ),
          SizedBox(height: 12),
          _buildContactItem(Icons.phone, 'Teléfono', '(809) 567-4300'),
          SizedBox(height: 12),
          _buildContactItem(Icons.email, 'Email', 'info@medioambiente.gob.do'),
          SizedBox(height: 12),
          _buildContactItem(Icons.web, 'Web', 'www.medioambiente.gob.do'),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchUrl('tel:+18095674300'),
              icon: Icon(Icons.phone),
              label: Text('Llamar Ahora'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _toggleVideo() {
    if (_videoController != null && _isVideoInitialized) {
      setState(() {
        if (_isVideoPlaying) {
          _videoController!.pause();
          _isVideoPlaying = false;
        } else {
          _videoController!.play();
          _isVideoPlaying = true;
        }
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _tabController?.dispose();
    super.dispose();
  }
}
