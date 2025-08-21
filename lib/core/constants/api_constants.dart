// lib/core/constants/api_constants.dart
class ApiConstants {
  // 🌐 BASE URL CORRECTO`
  static const String baseUrl = 'https://adamix.net/medioambiente';

  // Headers con CORS adicionales
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'User-Agent': 'Flutter-App/1.0',
  };

  // ═══════════════════════════════════════════════════════════════
  // 🔐 ENDPOINTS DE AUTENTICACIÓN
  // ═══════════════════════════════════════════════════════════════

  /// POST - Iniciar sesión
  /// Body: { "correo": "string", "password": "string" }
  static const String login = '$baseUrl/auth/login';

  /// POST - Registrar nuevo usuario
  /// Body: { "cedula": "string", "nombre": "string", "apellido": "string", "correo": "string", "password": "string", "telefono": "string", "matricula": "string" }
  static const String register = '$baseUrl/auth/register';

  /// POST - Recuperar contraseña
  /// Body: { "correo": "string" }
  static const String forgotPassword = '$baseUrl/auth/recover';

  /// POST - Resetear contraseña
  /// Body: { "correo": "string", "codigo": "string", "nueva_password": "string" }
  static const String changePassword = '$baseUrl/auth/reset';

  // ═══════════════════════════════════════════════════════════════
  // 📱 ENDPOINTS PÚBLICOS (No requieren autenticación)
  // ═══════════════════════════════════════════════════════════════

  /// GET - Lista de servicios del ministerio
  static const String services = '$baseUrl/servicios';

  /// GET - Servicio específico por ID
  /// URL: /servicios/{id}
  static String serviceDetail(String id) => '$services/$id';

  /// GET - Noticias ambientales
  static const String news = '$baseUrl/noticias';

  /// GET - Videos educativos
  /// Query params: ?categoria=reciclaje|conservacion|cambio_climatico|biodiversidad
  static const String videos = '$baseUrl/videos';

  /// GET - Áreas protegidas (parques, reservas)
  /// Query params: ?tipo=parque_nacional|reserva_cientifica|monumento_natural|refugio_vida_silvestre&busqueda=texto
  static const String protectedAreas = '$baseUrl/areas_protegidas';

  /// GET - Medidas ambientales (tips)
  /// Query params: ?categoria=string
  static const String environmentalMeasures = '$baseUrl/medidas';

  /// GET - Equipo del ministerio
  /// Query params: ?departamento=string
  static const String team = '$baseUrl/equipo';

  /// POST - Solicitar ser voluntario
  /// Body: { "cedula": "string", "nombre": "string", "apellido": "string", "correo": "string", "password": "string", "telefono": "string" }
  static const String volunteer = '$baseUrl/voluntarios';

  // ═══════════════════════════════════════════════════════════════
  // 🔐 ENDPOINTS PROTEGIDOS (Requieren autenticación)
  // ═══════════════════════════════════════════════════════════════

  /// GET - Normativas ambientales (requiere login)
  /// Headers: { "Authorization": "Bearer TOKEN" }
  /// Query params: ?tipo=string&busqueda=string
  static const String regulations = '$baseUrl/normativas';

  /// GET - Mis reportes (requiere login)
  /// Headers: { "Authorization": "Bearer TOKEN" }
  static const String myReports = '$baseUrl/reportes';

  /// POST - Crear reporte de daño ambiental (requiere login)
  /// Headers: { "Authorization": "Bearer TOKEN" }
  /// Body: { "titulo": "string", "descripcion": "string", "foto": "string", "latitud": number, "longitud": number }
  static const String reportDamage = '$baseUrl/reportes';

  /// GET - Detalle de reporte específico (requiere login)
  /// Headers: { "Authorization": "Bearer TOKEN" }
  /// URL: /reportes/{id}
  static String reportDetail(String id) => '$reportDamage/$id';

  /// PUT - Actualizar perfil de usuario (requiere login)
  /// Headers: { "Authorization": "Bearer TOKEN" }
  /// Body: { "nombre": "string", "apellido": "string", "telefono": "string" }
  static const String updateProfile = '$baseUrl/usuarios';

  // ═══════════════════════════════════════════════════════════════
  // 🔧 CONFIGURACIÓN DE MÉTODOS HTTP
  // ═══════════════════════════════════════════════════════════════

  static const String methodGet = 'GET';
  static const String methodPost = 'POST';
  static const String methodPut = 'PUT';
  static const String methodDelete = 'DELETE';

  // ═══════════════════════════════════════════════════════════════
  // 📋 HEADERS PREDETERMINADOS
  // ═══════════════════════════════════════════════════════════════

  /// Headers para requests con archivos (multipart)
  static const Map<String, String> multipartHeaders = {
    'Content-Type': 'multipart/form-data',
    'Accept': 'application/json',
  };

  /// Headers para requests autenticados
  static Map<String, String> authenticatedHeaders(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // ═══════════════════════════════════════════════════════════════
  // 🏷️ CATEGORÍAS Y OPCIONES PREDEFINIDAS (según Swagger)
  // ═══════════════════════════════════════════════════════════════

  /// Categorías de videos educativos
  static const List<String> videoCategories = [
    'reciclaje',
    'conservacion',
    'cambio_climatico',
    'biodiversidad',
  ];

  /// Tipos de áreas protegidas
  static const List<String> protectedAreaTypes = [
    'parque_nacional',
    'reserva_cientifica',
    'monumento_natural',
    'refugio_vida_silvestre',
  ];

  /// Estados de reportes (según schema)
  static const List<String> reportStatuses = [
    'pendiente',
    'en_proceso',
    'resuelto',
    'rechazado',
  ];

  // ═══════════════════════════════════════════════════════════════
  // 🛠️ MÉTODOS HELPER PARA CONSTRUCCIÓN DE URLs
  // ═══════════════════════════════════════════════════════════════

  /// Construir URL con parámetros de consulta
  static String buildUrlWithParams(
    String endpoint,
    Map<String, String>? params,
  ) {
    if (params == null || params.isEmpty) return endpoint;

    final uri = Uri.parse(endpoint);
    final newUri = uri.replace(
      queryParameters: {...uri.queryParameters, ...params},
    );
    return newUri.toString();
  }

  /// Construir URL para videos con filtro de categoría
  static String videosWithCategory(String categoria) =>
      '$videos?categoria=$categoria';

  /// Construir URL para áreas protegidas con filtros
  static String protectedAreasWithFilters({String? tipo, String? busqueda}) {
    final params = <String, String>{};
    if (tipo != null) params['tipo'] = tipo;
    if (busqueda != null) params['busqueda'] = busqueda;
    return buildUrlWithParams(protectedAreas, params);
  }

  /// Construir URL para normativas con filtros
  static String regulationsWithFilters({String? tipo, String? busqueda}) {
    final params = <String, String>{};
    if (tipo != null) params['tipo'] = tipo;
    if (busqueda != null) params['busqueda'] = busqueda;
    return buildUrlWithParams(regulations, params);
  }

  // ═══════════════════════════════════════════════════════════════
  // 🌍 CONFIGURACIÓN ESPECÍFICA PARA REPÚBLICA DOMINICANA
  // ═══════════════════════════════════════════════════════════════

  /// Coordenadas del centro de República Dominicana
  static const double dominicanRepublicLat = 18.7357;
  static const double dominicanRepublicLng = -70.1627;

  /// Zoom predeterminado para mapas
  static const double defaultMapZoom = 8.0;
  static const double detailMapZoom = 15.0;

  // ═══════════════════════════════════════════════════════════════
  // ⚙️ CONFIGURACIÓN DE TIMEOUTS Y LÍMITES
  // ═══════════════════════════════════════════════════════════════

  /// Timeout para requests HTTP (en segundos)
  static const int requestTimeout = 30;

  /// Tamaño máximo de archivo para upload (en bytes) - 5MB
  static const int maxFileSize = 5 * 1024 * 1024;

  // ═══════════════════════════════════════════════════════════════
  // 📝 CAMPOS DE FORMULARIOS SEGÚN SWAGGER
  // ═══════════════════════════════════════════════════════════════

  /// Campos requeridos para registro
  static const List<String> registerRequiredFields = [
    'cedula',
    'nombre',
    'apellido',
    'correo', // ⚠️ Nota: es "correo", no "email"
    'password',
    'telefono',
    'matricula',
  ];

  /// Campos requeridos para login
  static const List<String> loginRequiredFields = [
    'correo', // ⚠️ Nota: es "correo", no "email"
    'password',
  ];

  /// Campos requeridos para crear reporte
  static const List<String> reportRequiredFields = [
    'titulo',
    'descripcion',
    'foto',
    'latitud',
    'longitud',
  ];

  // ═══════════════════════════════════════════════════════════════
  // 🔗 ENLACES EXTERNOS Y RECURSOS
  // ═══════════════════════════════════════════════════════════════

  /// Sitio web oficial del Ministerio
  static const String ministryWebsite = 'https://ambiente.gob.do';

  /// Documentación Swagger de la API
  static const String apiDocumentation =
      'https://adamix.net/medioambiente/swagger.json';

  /// Contacto de emergencias ambientales
  static const String emergencyContact = '809-567-4300';

  /// Email de contacto
  static const String contactEmail = 'info@ambiente.gob.do';

  // ═══════════════════════════════════════════════════════════════
  // 🔧 ALIAS PARA COMPATIBILIDAD CON TU CÓDIGO EXISTENTE
  // ═══════════════════════════════════════════════════════════════

  /// Alias para compatibilidad con código existente
  static const String reportsMap =
      reportDamage; // Mismo endpoint para mis reportes y mapa
}
