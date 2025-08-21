// lib/features/team/presentation/pages/team_page.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/team_member_model.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as custom_error;

class TeamPage extends StatefulWidget {
  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();

  List<TeamMemberModel> _teamMembers = [];
  List<TeamMemberModel> _filteredTeamMembers = [];
  List<String> _departments = [];
  String _selectedDepartment = 'Todos';
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTeamMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Equipo del Ministerio'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TeamMemberSearchDelegate(_teamMembers),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return LoadingWidget(message: 'Cargando equipo del ministerio...');
    }

    if (_errorMessage != null) {
      return custom_error.ErrorWidget(
        message: _errorMessage!,
        onRetry: _loadTeamMembers,
      );
    }

    if (_teamMembers.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadTeamMembers,
      color: AppColors.primaryGreen,
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildFilters(),
          Expanded(
            child: _filteredTeamMembers.isEmpty
                ? _buildNoResultsState()
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _filteredTeamMembers.length,
                    itemBuilder: (context, index) {
                      final member = _filteredTeamMembers[index];
                      return _buildMemberCard(member);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.lightGreen, AppColors.primaryGreen],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.group, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nuestro Equipo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Profesionales comprometidos con el medio ambiente',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '${_filteredTeamMembers.length} miembro${_filteredTeamMembers.length != 1 ? 's' : ''} del equipo${_searchQuery.isNotEmpty || _selectedDepartment != 'Todos' ? ' (filtrado${_filteredTeamMembers.length != 1 ? 's' : ''})' : ''}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o cargo...',
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryGreen),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedDepartment,
        decoration: InputDecoration(
          labelText: 'Departamento',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: _departments.map((department) {
          return DropdownMenuItem(
            value: department,
            child: Text(department, style: TextStyle(fontSize: 14)),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            _onDepartmentChanged(value);
          }
        },
      ),
    );
  }

  Widget _buildMemberCard(TeamMemberModel member) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showMemberDetail(member),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              _buildMemberAvatar(member),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.fullName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      member.cargo,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (member.departamento != null) ...[
                      SizedBox(height: 2),
                      Text(
                        member.departamento!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    SizedBox(height: 8),
                    Row(
                      children: [
                        if (member.anosExperiencia != null) ...[
                          Icon(
                            Icons.work_outline,
                            size: 14,
                            color: AppColors.textLight,
                          ),
                          SizedBox(width: 4),
                          Text(
                            member.experienceText,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                        if (member.especialidades.isNotEmpty) ...[
                          SizedBox(width: 16),
                          Icon(
                            Icons.star_outline,
                            size: 14,
                            color: AppColors.sunYellow,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${member.especialidades.length} especialidad${member.especialidades.length > 1 ? 'es' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberAvatar(TeamMemberModel member) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryGreen, width: 2),
      ),
      child: ClipOval(
        child: member.foto != null
            ? CachedNetworkImage(
                imageUrl: member.foto!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.background,
                  child: Icon(
                    Icons.person,
                    color: AppColors.textLight,
                    size: 30,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: AppColors.primaryGreen,
                    size: 30,
                  ),
                ),
              )
            : Container(
                color: AppColors.primaryGreen.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: AppColors.primaryGreen,
                  size: 30,
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_outlined, size: 80, color: AppColors.textLight),
          SizedBox(height: 16),
          Text(
            'No hay miembros del equipo disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'La información del equipo se mostrará aquí cuando esté disponible.',
            style: TextStyle(fontSize: 14, color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadTeamMembers,
            icon: Icon(Icons.refresh),
            label: Text('Actualizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: AppColors.textLight),
          SizedBox(height: 16),
          Text(
            'No se encontraron miembros',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Intenta con otros términos de búsqueda o cambia los filtros',
            style: TextStyle(fontSize: 14, color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              _onSearchChanged('');
              _onDepartmentChanged('Todos');
            },
            icon: Icon(Icons.clear),
            label: Text('Limpiar filtros'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showMemberDetail(TeamMemberModel member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMemberDetailSheet(member),
    );
  }

  Widget _buildMemberDetailSheet(TeamMemberModel member) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryGreen, width: 3),
                  ),
                  child: ClipOval(
                    child: member.foto != null
                        ? CachedNetworkImage(
                            imageUrl: member.foto!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.background,
                              child: Icon(
                                Icons.person,
                                color: AppColors.textLight,
                                size: 50,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.primaryGreen.withOpacity(0.1),
                              child: Icon(
                                Icons.person,
                                color: AppColors.primaryGreen,
                                size: 50,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            child: Icon(
                              Icons.person,
                              color: AppColors.primaryGreen,
                              size: 50,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                member.fullName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                member.cargo,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (member.departamento != null) ...[
                SizedBox(height: 4),
                Text(
                  member.departamento!,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              SizedBox(height: 24),
              if (member.biografia != null) ...[
                _buildDetailSection('Biografía', member.biografia!),
                SizedBox(height: 16),
              ],

              if (member.educacion != null) ...[
                _buildDetailSection('Educación', member.educacion!),
                SizedBox(height: 16),
              ],

              if (member.especialidades.isNotEmpty) ...[
                _buildDetailSection(
                  'Especialidades',
                  member.especialidades.join(', '),
                ),
                SizedBox(height: 16),
              ],

              if (member.logros.isNotEmpty) ...[
                _buildDetailSection(
                  'Logros destacados',
                  member.logros.map((logro) => '• $logro').join('\n'),
                ),
                SizedBox(height: 16),
              ],

              if (member.fechaIngreso != null) ...[
                _buildDetailSection('Experiencia', member.joinDateText),
                SizedBox(height: 16),
              ],

              if (member.email != null || member.telefono != null)
                _buildContactButtons(member),

              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildContactButtons(TeamMemberModel member) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contacto',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            if (member.email != null)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchEmail(member.email!),
                  icon: Icon(Icons.email, size: 18),
                  label: Text('Email'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            if (member.email != null && member.telefono != null)
              SizedBox(width: 12),
            if (member.telefono != null)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchPhone(member.telefono!),
                  icon: Icon(Icons.phone, size: 18),
                  label: Text('Llamar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryBlue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Consulta del Ministerio de Medio Ambiente',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _loadTeamMembers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _apiClient.get(ApiConstants.team);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> membersJson = response['data'];
        final members = membersJson
            .map((json) => TeamMemberModel.fromJson(json))
            .where((member) => member.activo)
            .toList();

        // Sort by hierarchy (simplified)
        members.sort((a, b) {
          final orderA = _getCargoOrder(a.cargo);
          final orderB = _getCargoOrder(b.cargo);
          if (orderA != orderB) return orderA.compareTo(orderB);
          return a.fullName.compareTo(b.fullName);
        });

        // Extract departments
        final departments = members
            .map((member) => member.departamento)
            .where((dept) => dept != null && dept.isNotEmpty)
            .toSet()
            .toList();
        departments.sort();

        setState(() {
          _teamMembers = members;
          _filteredTeamMembers = members;
          _departments = ['Todos', ...departments.whereType<String>()];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Error al cargar el equipo';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión. Verifica tu internet.';
        _isLoading = false;
      });
    }
  }

  int _getCargoOrder(String cargo) {
    // Define hierarchy order for team positions
    final cargoLower = cargo.toLowerCase();
    if (cargoLower.contains('ministro') || cargoLower.contains('ministra'))
      return 0;
    if (cargoLower.contains('viceministro') ||
        cargoLower.contains('viceministra'))
      return 1;
    if (cargoLower.contains('director') || cargoLower.contains('directora'))
      return 2;
    if (cargoLower.contains('subdirector') ||
        cargoLower.contains('subdirectora'))
      return 3;
    if (cargoLower.contains('coordinador') ||
        cargoLower.contains('coordinadora'))
      return 4;
    if (cargoLower.contains('jefe') || cargoLower.contains('jefa')) return 5;
    if (cargoLower.contains('asesor') || cargoLower.contains('asesora'))
      return 6;
    return 7; // Other positions
  }

  void _filterTeamMembers() {
    setState(() {
      List<TeamMemberModel> filtered = _teamMembers;

      // Filter by department
      if (_selectedDepartment != 'Todos') {
        filtered = filtered
            .where((member) => member.departamento == _selectedDepartment)
            .toList();
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        filtered = filtered.where((member) {
          return member.fullName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              member.cargo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (member.departamento?.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ??
                  false) ||
              member.especialidades.any(
                (esp) => esp.toLowerCase().contains(_searchQuery.toLowerCase()),
              );
        }).toList();
      }

      _filteredTeamMembers = filtered;
    });
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _filterTeamMembers();
  }

  void _onDepartmentChanged(String department) {
    _selectedDepartment = department;
    _filterTeamMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _apiClient.dispose();
    super.dispose();
  }
}

class TeamMemberSearchDelegate extends SearchDelegate<String> {
  final List<TeamMemberModel> teamMembers;

  TeamMemberSearchDelegate(this.teamMembers);

  @override
  String get searchFieldLabel => 'Buscar miembros del equipo...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: AppColors.textLight),
            SizedBox(height: 16),
            Text(
              'Busca miembros por nombre, cargo o departamento',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final filteredMembers = teamMembers.where((member) {
      return member.fullName.toLowerCase().contains(query.toLowerCase()) ||
          member.cargo.toLowerCase().contains(query.toLowerCase()) ||
          (member.departamento?.toLowerCase().contains(query.toLowerCase()) ??
              false) ||
          member.especialidades.any(
            (esp) => esp.toLowerCase().contains(query.toLowerCase()),
          );
    }).toList();

    if (filteredMembers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textLight),
            SizedBox(height: 16),
            Text(
              'No se encontraron resultados para "$query"',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredMembers.length,
      itemBuilder: (context, index) {
        final member = filteredMembers[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryGreen,
              backgroundImage: member.foto != null
                  ? CachedNetworkImageProvider(member.foto!)
                  : null,
              child: member.foto == null
                  ? Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            title: Text(
              member.fullName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  member.cargo,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (member.departamento != null) ...[
                  SizedBox(height: 2),
                  Text(
                    member.departamento!,
                    style: TextStyle(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            trailing: member.anosExperiencia != null
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${member.anosExperiencia} años',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
            onTap: () {
              close(context, member.id);
            },
          ),
        );
      },
    );
  }
}
