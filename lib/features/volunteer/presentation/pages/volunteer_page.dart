import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/models/volunteer_application_model.dart';
import '../../../../features/auth/presentation/widgets/auth_form_field.dart';
import '../../../../features/auth/presentation/widgets/auth_button.dart';

class VolunteerPage extends StatefulWidget {
  @override
  _VolunteerPageState createState() => _VolunteerPageState();
}

class _VolunteerPageState extends State<VolunteerPage> {
  final ApiClient _apiClient = ApiClient();
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  // Form controllers
  final _cedulaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _motivacionController = TextEditingController();
  final _experienciaController = TextEditingController();

  int _currentStep = 0;
  bool _isLoading = false;

  // Areas de interés disponibles
  final List<String> _availableAreas = [
    'Conservación de bosques',
    'Protección de fauna',
    'Reciclaje y gestión de residuos',
    'Educación ambiental',
    'Energías renovables',
    'Cambio climático',
    'Recursos hídricos',
    'Agricultura sostenible',
    'Biodiversidad',
    'Áreas protegidas',
  ];

  List<String> _selectedAreas = [];
  String _selectedDisponibilidad = 'Fines de semana';

  final List<String> _disponibilidadOptions = [
    'Fines de semana',
    'Días laborables',
    'Tiempo completo',
    'Medio tiempo',
    'Ocasional',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Programa de Voluntariado'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
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
                _buildWelcomeStep(),
                _buildPersonalInfoStep(),
                _buildInterestsStep(),
                _buildExperienceStep(),
                _buildConfirmationStep(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
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
            children: List.generate(5, (index) {
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
            'Paso ${_currentStep + 1} de 5',
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

  Widget _buildWelcomeStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(height: 40),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.volunteer_activism,
              size: 60,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(height: 24),
          Text(
            '¡Únete a nuestro equipo!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'Sé parte del cambio que quieres ver en el mundo. Como voluntario del Ministerio de Medio Ambiente, contribuirás activamente a la protección y conservación de nuestro patrimonio natural.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          _buildBenefitCard(
            icon: Icons.nature_people,
            title: 'Impacto Real',
            description:
                'Participa en proyectos que generan un impacto positivo en el medio ambiente.',
          ),
          SizedBox(height: 16),
          _buildBenefitCard(
            icon: Icons.school,
            title: 'Aprendizaje Continuo',
            description:
                'Desarrolla nuevas habilidades y conocimientos en temas ambientales.',
          ),
          SizedBox(height: 16),
          _buildBenefitCard(
            icon: Icons.group,
            title: 'Red de Contactos',
            description:
                'Conecta con profesionales y otros voluntarios comprometidos.',
          ),
          SizedBox(height: 32),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
                SizedBox(height: 8),
                Text(
                  'Requisitos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• Mayor de 18 años\n• Cédula de identidad dominicana\n• Disponibilidad mínima de 4 horas semanales\n• Compromiso y responsabilidad',
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

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Personal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Proporciona tus datos básicos para el registro',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            SizedBox(height: 32),
            AuthFormField(
              controller: _cedulaController,
              label: 'Cédula de Identidad',
              hintText: 'Ej: 00000000000',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.credit_card,
              validator: Validators.validateCedula,
            ),
            SizedBox(height: 16),
            AuthFormField(
              controller: _nombreController,
              label: 'Nombre',
              hintText: 'Tu nombre',
              prefixIcon: Icons.person_outline,
              validator: Validators.validateName,
            ),
            SizedBox(height: 16),
            AuthFormField(
              controller: _apellidoController,
              label: 'Apellido',
              hintText: 'Tu apellido',
              prefixIcon: Icons.person_outline,
              validator: Validators.validateName,
            ),
            SizedBox(height: 16),
            AuthFormField(
              controller: _emailController,
              label: 'Correo Electrónico',
              hintText: 'tu@email.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: Validators.validateEmail,
            ),
            SizedBox(height: 16),
            AuthFormField(
              controller: _telefonoController,
              label: 'Teléfono',
              hintText: 'Ej: 8091234567',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: Validators.validatePhone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Áreas de Interés',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Selecciona las áreas en las que te gustaría participar como voluntario',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableAreas.map((area) {
              final isSelected = _selectedAreas.contains(area);
              return FilterChip(
                label: Text(area),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedAreas.add(area);
                    } else {
                      _selectedAreas.remove(area);
                    }
                  });
                },
                selectedColor: AppColors.primaryGreen.withOpacity(0.2),
                checkmarkColor: AppColors.primaryGreen,
                backgroundColor: Colors.grey[100],
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 32),
          Text(
            'Disponibilidad',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDisponibilidad,
                items: _disponibilidadOptions.map((option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedDisponibilidad = value;
                    });
                  }
                },
                isExpanded: true,
              ),
            ),
          ),
          if (_selectedAreas.isEmpty) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Selecciona al menos un área de interés',
                      style: TextStyle(color: AppColors.warning, fontSize: 14),
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

  Widget _buildExperienceStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Experiencia y Motivación',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Cuéntanos sobre tu experiencia y motivación para ser voluntario',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          SizedBox(height: 32),
          AuthFormField(
            controller: _motivacionController,
            label: '¿Por qué quieres ser voluntario?',
            hintText:
                'Describe tu motivación para unirte a nuestro programa de voluntariado...',
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor describe tu motivación';
              }
              if (value.trim().length < 50) {
                return 'La descripción debe tener al menos 50 caracteres';
              }
              return null;
            },
          ),
          SizedBox(height: 24),
          AuthFormField(
            controller: _experienciaController,
            label: 'Experiencia previa (opcional)',
            hintText:
                'Describe cualquier experiencia previa en temas ambientales, voluntariado o trabajos relacionados...',
            maxLines: 4,
          ),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Consejos para tu respuesta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  '• Sé específico sobre tus intereses ambientales\n• Menciona habilidades relevantes que puedas aportar\n• Describe tu compromiso con la causa ambiental\n• Incluye cualquier experiencia en trabajo en equipo',
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

  Widget _buildConfirmationStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirmar Solicitud',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Revisa tu información antes de enviar la solicitud',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          SizedBox(height: 32),
          _buildSummaryCard(),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.schedule, color: AppColors.primaryGreen, size: 24),
                SizedBox(height: 8),
                Text(
                  '¿Qué sigue?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '1. Revisaremos tu solicitud en 3-5 días hábiles\n2. Te contactaremos por email o teléfono\n3. Programaremos una entrevista breve\n4. ¡Comenzarás tu experiencia como voluntario!',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow(
              'Nombre',
              '${_nombreController.text} ${_apellidoController.text}',
            ),
            _buildSummaryRow('Cédula', _cedulaController.text),
            _buildSummaryRow('Email', _emailController.text),
            _buildSummaryRow('Teléfono', _telefonoController.text),
            _buildSummaryRow('Disponibilidad', _selectedDisponibilidad),
            if (_selectedAreas.isNotEmpty)
              _buildSummaryRow('Áreas de interés', _selectedAreas.join(', ')),
            if (_motivacionController.text.isNotEmpty)
              _buildSummaryRow(
                'Motivación',
                _motivacionController.text,
                isLong: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isLong = false}) {
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
            maxLines: isLong ? null : 2,
            overflow: isLong ? null : TextOverflow.ellipsis,
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
              text: _currentStep == 4 ? 'Enviar Solicitud' : 'Siguiente',
              onPressed: _nextStep,
              isLoading: _isLoading,
              icon: _currentStep == 4 ? Icons.send : Icons.arrow_forward,
            ),
          ),
        ],
      ),
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
    if (_currentStep < 4) {
      if (_validateCurrentStep()) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _submitApplication();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return true; // Welcome step, no validation needed
      case 1:
        return _formKey.currentState?.validate() ?? false;
      case 2:
        if (_selectedAreas.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selecciona al menos un área de interés'),
              backgroundColor: AppColors.warning,
            ),
          );
          return false;
        }
        return true;
      case 3:
        if (_motivacionController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Por favor describe tu motivación'),
              backgroundColor: AppColors.error,
            ),
          );
          return false;
        }
        if (_motivacionController.text.trim().length < 50) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('La motivación debe tener al menos 50 caracteres'),
              backgroundColor: AppColors.warning,
            ),
          );
          return false;
        }
        return true;
      case 4:
        return true; // Confirmation step
      default:
        return true;
    }
  }

  Future<void> _submitApplication() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final application = VolunteerApplicationModel(
        cedula: _cedulaController.text.trim(),
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        email: _emailController.text.trim(),
        telefono: _telefonoController.text.trim(),
        motivacion: _motivacionController.text.trim(),
        areasInteres: _selectedAreas,
        experienciaPrevia: _experienciaController.text.trim().isNotEmpty
            ? _experienciaController.text.trim()
            : null,
        disponibilidad: _selectedDisponibilidad,
        fechaSolicitud: DateTime.now(),
      );

      final response = await _apiClient.post(
        ApiConstants.volunteer,
        application.toJson(),
      );

      if (response['success'] == true) {
        _showSuccessDialog();
      } else {
        _showErrorMessage(
          response['message'] ?? 'Error al enviar la solicitud',
        );
      }
    } catch (e) {
      _showErrorMessage('Error de conexión. Verifica tu internet.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
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
                '¡Solicitud Enviada!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Tu solicitud de voluntariado ha sido enviada exitosamente. Te contactaremos pronto.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Entendido'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _motivacionController.dispose();
    _experienciaController.dispose();
    _pageController.dispose();
    _apiClient.dispose();
    super.dispose();
  }
}
