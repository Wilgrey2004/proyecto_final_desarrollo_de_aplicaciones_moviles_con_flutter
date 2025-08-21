// lib/app/routes/app_routes.dart
import 'package:flutter/material.dart';
import '../../test_api.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/change_password_page.dart';
import '../../features/services/presentation/pages/services_page.dart';
import '../../features/news/presentation/pages/news_page.dart';
import '../../features/news/presentation/pages/news_detail_page.dart';
import '../../features/protected_areas/presentation/pages/protected_areas_page.dart';
import '../../features/protected_areas/presentation/pages/protected_area_detail_page.dart';
import '../../features/protected_areas/presentation/pages/areas_map_page.dart';
import '../../features/environmental_measures/presentation/pages/environmental_measures_page.dart';
import '../../features/team/presentation/pages/team_page.dart';
import '../../features/volunteer/presentation/pages/volunteer_page.dart';
import '../../features/regulations/presentation/pages/regulations_page.dart';
import '../../features/reports/presentation/pages/report_damage_page.dart';
import '../../features/user_reports/presentation/pages/my_reports_page.dart';
import '../../features/user_reports/presentation/pages/report_detail_page.dart';
import '../../features/user_reports/presentation/pages/reports_map_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String changePassword = '/change-password';
  static const String aboutUs = '/about-us';
  static const String services = '/services';
  static const String news = '/news';
  static const String newsDetail = '/news-detail';
  static const String videos = '/videos';
  static const String videoDetail = '/video-detail';
  static const String protectedAreas = '/protected-areas';
  static const String protectedAreaDetail = '/protected-area-detail';
  static const String areasMap = '/areas-map';
  static const String environmentalMeasures = '/environmental-measures';
  static const String measureDetail = '/measure-detail';
  static const String team = '/team';
  static const String volunteer = '/volunteer';
  static const String about = '/about';
  static const String regulations = '/regulations';
  static const String reportDamage = '/report-damage';
  static const String myReports = '/my-reports';
  static const String reportDetail = '/report-detail';
  static const String reportsMap = '/reports-map';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => HomePage(),
      login: (context) => LoginPage(),
      forgotPassword: (context) => ForgotPasswordPage(),
      changePassword: (context) => ChangePasswordPage(),
      aboutUs: (context) => PlaceholderPage(title: 'Sobre Nosotros'),
      services: (context) => ServicesPage(),
      news: (context) => NewsPage(),
      newsDetail: (context) => NewsDetailPage(),
      videos: (context) => PlaceholderPage(title: 'Videos Educativos'),
      videoDetail: (context) => PlaceholderPage(title: 'Detalle de Video'),
      protectedAreas: (context) => ProtectedAreasPage(),
      protectedAreaDetail: (context) => ProtectedAreaDetailPage(),
      areasMap: (context) => AreasMapPage(),
      environmentalMeasures: (context) => EnvironmentalMeasuresPage(),
      measureDetail: (context) => PlaceholderPage(title: 'Detalle de Medida'),
      team: (context) => TeamPage(),
      volunteer: (context) => VolunteerPage(),
      about: (context) => PlaceholderPage(title: 'Acerca de'),
      regulations: (context) => RegulationsPage(),
      reportDamage: (context) => ReportDamagePage(),
      myReports: (context) => MyReportsPage(),
      reportDetail: (context) => ReportDetailPage(),
      reportsMap: (context) => ReportsMapPage(),
      '/test-api': (context) => TestApiPage(),
    };
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case newsDetail:
        final newsId = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (context) => NewsDetailPage(newsId: newsId),
        );

      case videoDetail:
        final videoId = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (context) => PlaceholderPage(
            title: 'Detalle de Video',
            subtitle: 'Video ID: $videoId',
          ),
        );

      case protectedAreaDetail:
        final areaId = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (context) => ProtectedAreaDetailPage(areaId: areaId),
        );

      case measureDetail:
        final measureId = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (context) => PlaceholderPage(
            title: 'Detalle de Medida',
            subtitle: 'Medida ID: $measureId',
          ),
        );

      case reportDetail:
        final reportId = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (context) => ReportDetailPage(reportId: reportId),
        );

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text('Página no encontrada'),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Página no encontrada',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'La página "${settings.name}" no existe.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      home,
                      (route) => false,
                    ),
                    child: Text('Ir al Inicio'),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}

// Widget placeholder para páginas que aún no están implementadas
class PlaceholderPage extends StatelessWidget {
  final String title;
  final String? subtitle;

  const PlaceholderPage({Key? key, required this.title, this.subtitle})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 80, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: 16),
            Text(
              'Esta página está en desarrollo',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back),
              label: Text('Volver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
