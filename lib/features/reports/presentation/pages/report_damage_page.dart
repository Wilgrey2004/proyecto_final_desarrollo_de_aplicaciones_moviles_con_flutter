// lib/features/reports/presentation/pages/report_damage_page.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/models/damage_report_model.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/widgets/auth_form_field.dart';
import '../../../../features/auth/presentation/widgets/auth_button.dart';

class ReportDamagePage extends StatefulWidget {
  @override
  _ReportDamagePageState createState() => _ReportDamagePageState();
}

class _ReportDamagePageState extends State<ReportDamagePage> {
  final ApiClient _apiClient = ApiClient();
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();

  int _currentStep = 0;
  bool _isLoading = false;
  File? _selectedImage;
  String? _imageBase64;
  Position? _currentPosition;
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;

  // Form data
  String _selectedCategoria = 'Contaminación del agua';
  String _selectedGravedad = 'Media';
  bool _useCurrentLocation = true;

  final List<String> _categorias = [
    'Contaminación del agua',
    'Contaminación del aire',
    'Deforestación',
    'Vertido de residuos',
    'Daño a fauna silvestre',
    'Contaminación sonora',
    'Quema ilegal',
    'Construcción irregular',
    'Minería ilegal',
    'Otro',
  ];

  final List<String> _gravedades = ['Baja', 'Media', 'Alta', 'Crítica'];

  @override
  void initState() {
    super.initState();
    _checkAuthAndPermissions();
  }

  void _checkAuthAndPermissions() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      _showAuthRequiredDialog();
    } else {
      _requestPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Reportar Daño Ambiental'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            _showAuthRequiredDialog();
          }
        },
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildInfoStep(),
                  _buildLocationStep(),
                  _buildPhotoStep(),
                  _buildReviewStep(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: index <= _currentStep
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 12),
          Text(
            'Paso ${_currentStep + 1} de 4',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              'Información del Daño',
              'Describe detalladamente el problema ambiental que deseas reportar',
              Icons.description,
            ),
            SizedBox(height: 32),
            AuthFormField(
              controller: _tituloController,
              label: 'Título del reporte',
              hintText: 'Ej: Vertido de químicos en río',
              prefixIcon: Icons.title,
              validator: (value) =>
                  Validators.validateMinLength(value, 5, 'El título'),
            ),
            SizedBox(height: 16),
            AuthFormField(
              controller: _descripcionController,
              label: 'Descripción detallada',
              hintText:
                  'Describe qué está pasando, cuándo comenzó, qué daños observas...',
              maxLines: 5,
              validator: (value) =>
                  Validators.validateMinLength(value, 20, 'La descripción'),
            ),
            SizedBox(height: 16),
            _buildDropdownField(
              'Categoría del daño',
              _selectedCategoria,
              _categorias,
              (value) => setState(() => _selectedCategoria = value!),
              Icons.category,
            ),
            SizedBox(height: 16),
            _buildDropdownField(
              'Nivel de gravedad',
              _selectedGravedad,
              _gravedades,
              (value) => setState(() => _selectedGravedad = value!),
              Icons.warning,
            ),
            SizedBox(height: 24),
            _buildInfoCard(
              'Información importante',
              '• Proporciona la mayor cantidad de detalles posible\n• Incluye fechas y horarios si los conoces\n• Menciona si hay personas afectadas\n• Describe el alcance del daño observado',
              Icons.info_outline,
              AppColors.secondaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Ubicación del Daño',
            'Indica dónde se encuentra el problema ambiental',
            Icons.location_on,
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: Text('Usar mi ubicación actual'),
                  subtitle: Text('GPS automático'),
                  value: _useCurrentLocation,
                  onChanged: (value) {
                    setState(() {
                      _useCurrentLocation = value ?? true;
                    });
                    if (_useCurrentLocation) {
                      _getCurrentLocation();
                    }
                  },
                  activeColor: AppColors.primaryGreen,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (!_useCurrentLocation) ...[
            AuthFormField(
              controller: _latitudController,
              label: 'Latitud',
              hintText: 'Ej: 18.4861',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.explore,
              validator: (value) =>
                  Validators.validateCoordinates(value, 'Latitud'),
            ),
            SizedBox(height: 16),
            AuthFormField(
              controller: _longitudController,
              label: 'Longitud',
              hintText: 'Ej: -69.9312',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.explore,
              validator: (value) =>
                  Validators.validateCoordinates(value, 'Longitud'),
            ),
            SizedBox(height: 16),
          ],
          AuthFormField(
            controller: _ubicacionController,
            label: 'Descripción de la ubicación (opcional)',
            hintText: 'Ej: Cerca del puente, junto a la escuela...',
            maxLines: 2,
            prefixIcon: Icons.place,
          ),
          SizedBox(height: 24),
          if (_currentPosition != null || _selectedLocation != null)
            _buildLocationPreview(),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _useCurrentLocation
                  ? _getCurrentLocation
                  : _openMapPicker,
              icon: Icon(_useCurrentLocation ? Icons.my_location : Icons.map),
              label: Text(
                _useCurrentLocation
                    ? 'Obtener ubicación actual'
                    : 'Seleccionar en mapa',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Evidencia Fotográfica',
            'Una imagen ayuda a documentar mejor el daño ambiental',
            Icons.camera_alt,
          ),
          SizedBox(height: 32),
          if (_selectedImage != null) ...[
            _buildImagePreview(),
            SizedBox(height: 24),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _selectImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt),
                  label: Text('Tomar Foto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _selectImage(ImageSource.gallery),
                  icon: Icon(Icons.photo_library),
                  label: Text('Desde Galería'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryBlue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildInfoCard(
            'Consejos para la foto',
            '• Toma la foto con buena iluminación\n• Muestra claramente el daño ambiental\n• Incluye referencias de tamaño si es posible\n• Asegúrate de que la imagen sea nítida',
            Icons.tips_and_updates,
            AppColors.warning,
          ),
          if (_selectedImage == null) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: AppColors.primaryGreen),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'La foto es opcional, pero muy recomendada para una evaluación más efectiva del reporte.',
                      style: TextStyle(color: AppColors.primaryGreen),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Revisar y Enviar',
            'Verifica que toda la información sea correcta antes de enviar',
            Icons.checklist,
          ),
          SizedBox(height: 24),
          _buildReviewCard(),
          SizedBox(height: 24),
          _buildInfoCard(
            '¿Qué sucede después?',
            '• Tu reporte será revisado en 24-48 horas\n• Recibirás un código de seguimiento\n• Te notificaremos sobre el estado del reporte\n• Podrás ver el progreso en "Mis Reportes"',
            Icons.schedule,
            AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
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
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, size: 20, color: AppColors.textSecondary),
                      SizedBox(width: 12),
                      Text(item),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPreview() {
    final lat =
        _currentPosition?.latitude ?? _selectedLocation?.latitude ?? 0.0;
    final lng =
        _currentPosition?.longitude ?? _selectedLocation?.longitude ?? 0.0;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primaryGreen),
              SizedBox(width: 8),
              Text(
                'Ubicación seleccionada',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Latitud: ${lat.toStringAsFixed(6)}',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          Text(
            'Longitud: ${lng.toStringAsFixed(6)}',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.file(
              _selectedImage!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedImage = null;
                    _imageBase64 = null;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard() {
    final lat =
        _currentPosition?.latitude ??
        (_latitudController.text.isNotEmpty
            ? double.tryParse(_latitudController.text)
            : 0.0) ??
        0.0;
    final lng =
        _currentPosition?.longitude ??
        (_longitudController.text.isNotEmpty
            ? double.tryParse(_longitudController.text)
            : 0.0) ??
        0.0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReviewItem('Título', _tituloController.text),
            _buildReviewItem('Descripción', _descripcionController.text),
            _buildReviewItem('Categoría', _selectedCategoria),
            _buildReviewItem('Gravedad', _selectedGravedad),
            _buildReviewItem(
              'Coordenadas',
              '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
            ),
            if (_ubicacionController.text.isNotEmpty)
              _buildReviewItem('Ubicación', _ubicacionController.text),
            if (_selectedImage != null)
              _buildReviewItem('Foto', 'Imagen adjunta ✓'),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: AuthButton(
                text: 'Anterior',
                onPressed: _previousStep,
                isOutlined: true,
                backgroundColor: AppColors.primaryGreen,
                icon: Icons.arrow_back,
              ),
            ),
          if (_currentStep > 0) SizedBox(width: 16),
          Expanded(
            child: AuthButton(
              text: _currentStep == 3 ? 'Enviar Reporte' : 'Siguiente',
              onPressed: _nextStep,
              isLoading: _isLoading,
              icon: _currentStep == 3 ? Icons.send : Icons.arrow_forward,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestPermissions() async {
    final locationStatus = await Permission.location.request();
    final cameraStatus = await Permission.camera.request();
    final storageStatus = await Permission.storage.request();

    if (locationStatus.isDenied ||
        cameraStatus.isDenied ||
        storageStatus.isDenied) {
      _showPermissionsDialog();
    }
  }

  void _showPermissionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permisos Necesarios'),
          content: Text(
            'Esta aplicación necesita acceso a la ubicación, cámara y almacenamiento para funcionar correctamente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Entendido'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text('Abrir Configuración'),
            ),
          ],
        );
      },
    );
  }

  void _showAuthRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 60, color: AppColors.warning),
              SizedBox(height: 16),
              Text(
                'Acceso Restringido',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Necesitas iniciar sesión para reportar daños ambientales.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancelar'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                      ),
                      child: Text('Iniciar Sesión'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      if (_validateCurrentStep()) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _submitReport();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _formKey.currentState?.validate() ?? false;
      case 1:
        if (_useCurrentLocation) {
          if (_currentPosition == null) {
            _showMessage(
              'Por favor, obtén tu ubicación actual primero',
              isError: true,
            );
            return false;
          }
        } else {
          if (_latitudController.text.isEmpty ||
              _longitudController.text.isEmpty) {
            _showMessage('Por favor, ingresa las coordenadas', isError: true);
            return false;
          }
          final lat = double.tryParse(_latitudController.text);
          final lng = double.tryParse(_longitudController.text);
          if (lat == null ||
              lng == null ||
              lat < -90 ||
              lat > 90 ||
              lng < -180 ||
              lng > 180) {
            _showMessage(
              'Las coordenadas ingresadas no son válidas',
              isError: true,
            );
            return false;
          }
        }
        return true;
      case 2:
        return true; // Photo is optional
      case 3:
        return true; // Review step
      default:
        return true;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isLoading = true);

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMessage(
          'Los servicios de ubicación están deshabilitados',
          isError: true,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showMessage('Permisos de ubicación denegados', isError: true);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showMessage(
          'Los permisos de ubicación están permanentemente denegados',
          isError: true,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      _showMessage('Ubicación obtenida correctamente', isError: false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('Error al obtener la ubicación: $e', isError: true);
    }
  }

  void _openMapPicker() {
    // TODO: Implement map picker
    _showMessage('Función de mapa en desarrollo', isError: false);
  }

  Future<void> _selectImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        final bytes = await imageFile.readAsBytes();
        final base64String = base64Encode(bytes);

        setState(() {
          _selectedImage = imageFile;
          _imageBase64 = base64String;
        });

        _showMessage('Imagen seleccionada correctamente', isError: false);
      }
    } catch (e) {
      _showMessage('Error al seleccionar imagen: $e', isError: true);
    }
  }

  Future<void> _submitReport() async {
    try {
      setState(() => _isLoading = true);

      final lat = _useCurrentLocation
          ? _currentPosition!.latitude
          : double.parse(_latitudController.text);
      final lng = _useCurrentLocation
          ? _currentPosition!.longitude
          : double.parse(_longitudController.text);

      final report = DamageReportModel(
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        fotoBase64: _imageBase64,
        latitud: lat,
        longitud: lng,
        ubicacionDescripcion: _ubicacionController.text.trim().isNotEmpty
            ? _ubicacionController.text.trim()
            : null,
        categoria: _selectedCategoria,
        gravedad: _selectedGravedad,
        fechaReporte: DateTime.now(),
      );

      final response = await _apiClient.post(
        ApiConstants.reportDamage,
        report.toJson(),
        requiresAuth: true,
      );

      if (response['success'] == true) {
        _showSuccessDialog(response['codigo_reporte'] ?? 'N/A');
      } else {
        _showMessage(
          response['message'] ?? 'Error al enviar el reporte',
          isError: true,
        );
      }
    } catch (e) {
      _showMessage('Error de conexión. Verifica tu internet.', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String codigoReporte) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 40,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '¡Reporte Enviado!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Tu reporte ha sido enviado exitosamente.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Código de seguimiento:',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      codigoReporte,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text('Cerrar'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/my-reports');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                      ),
                      child: Text('Ver Reportes'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _ubicacionController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _pageController.dispose();
    _apiClient.dispose();
    super.dispose();
  }
}
