// lib\features\environmental_measures\presentation\pages\environmental_measures_page.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/environmental_measure_model.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as custom_error;

class EnvironmentalMeasuresPage extends StatefulWidget {
  @override
  _EnvironmentalMeasuresPageState createState() =>
      _EnvironmentalMeasuresPageState();
}

class _EnvironmentalMeasuresPageState extends State<EnvironmentalMeasuresPage> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();

  List<EnvironmentalMeasureModel> _measures = [];
  List<EnvironmentalMeasureModel> _filteredMeasures = [];
  List<String> _categories = [];
  List<String> _difficulties = [];
  String _selectedCategory = 'Todas';
  String _selectedDifficulty = 'Todas';
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEnvironmentalMeasures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medidas Ambientales'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: EnvironmentalMeasureSearchDelegate(_measures),
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
      return LoadingWidget(message: 'Cargando medidas ambientales...');
    }

    if (_errorMessage != null) {
      return custom_error.ErrorWidget(
        message: _errorMessage!,
        onRetry: _loadEnvironmentalMeasures,
      );
    }

    if (_measures.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadEnvironmentalMeasures,
      color: AppColors.primaryGreen,
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildFilters(),
          Expanded(
            child: _filteredMeasures.isEmpty
                ? _buildNoResultsState()
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _filteredMeasures.length,
                    itemBuilder: (context, index) {
                      final measure = _filteredMeasures[index];
                      if (index == 0 &&
                          _searchQuery.isEmpty &&
                          _selectedCategory == 'Todas' &&
                          _selectedDifficulty == 'Todas') {
                        return _buildFeaturedMeasureCard(measure);
                      }
                      return _buildMeasureCard(measure);
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
              Icon(Icons.eco, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medidas Ambientales',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Acciones para cuidar nuestro planeta',
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
            '${_filteredMeasures.length} medida${_filteredMeasures.length != 1 ? 's' : ''} disponible${_filteredMeasures.length != 1 ? 's' : ''}${_searchQuery.isNotEmpty || _selectedCategory != 'Todas' || _selectedDifficulty != 'Todas' ? ' (filtrada${_filteredMeasures.length != 1 ? 's' : ''})' : ''}',
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
          hintText: 'Buscar medidas ambientales...',
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
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category, style: TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _onCategoryChanged(value);
                }
              },
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: InputDecoration(
                labelText: 'Dificultad',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: _difficulties.map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(
                    difficulty == 'Todas'
                        ? difficulty
                        : _getDifficultyDisplayText(difficulty),
                    style: TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _onDifficultyChanged(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getDifficultyDisplayText(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'facil':
        return 'Fácil';
      case 'intermedio':
        return 'Intermedio';
      case 'avanzado':
        return 'Avanzado';
      default:
        return difficulty;
    }
  }

  Widget _buildFeaturedMeasureCard(EnvironmentalMeasureModel measure) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => _navigateToMeasureDetail(measure),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  child: measure.imagen != null
                      ? CachedNetworkImage(
                          imageUrl: measure.imagen!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.background,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.lightGreen,
                                  AppColors.primaryGreen,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.eco,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.lightGreen,
                                AppColors.primaryGreen,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.eco,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (measure.destacada)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'DESTACADA',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Spacer(),
                        _buildDifficultyChip(measure.dificultad),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      measure.titulo,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      measure.descripcion,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        _buildInfoChip(
                          icon: Icons.category,
                          text: measure.categoria,
                          color: AppColors.primaryGreen,
                        ),
                        SizedBox(width: 8),
                        if (measure.impacto != null)
                          _buildImpactStars(measure.impacto!),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textLight,
                        ),
                        SizedBox(width: 4),
                        Text(
                          measure.timeDisplayText,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                        SizedBox(width: 16),
                        Icon(
                          Icons.attach_money,
                          size: 14,
                          color: AppColors.textLight,
                        ),
                        SizedBox(width: 4),
                        Text(
                          measure.costDisplayText,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasureCard(EnvironmentalMeasureModel measure) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToMeasureDetail(measure),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  child: measure.imagen != null
                      ? CachedNetworkImage(
                          imageUrl: measure.imagen!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.background,
                            child: Icon(Icons.eco, color: AppColors.textLight),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            child: Icon(
                              Icons.eco,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          child: Icon(Icons.eco, color: AppColors.primaryGreen),
                        ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            measure.titulo,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        _buildDifficultyChip(measure.dificultad, isSmall: true),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      measure.descripcion,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(
                          icon: Icons.category,
                          text: measure.categoria,
                          color: AppColors.primaryGreen,
                          isSmall: true,
                        ),
                        SizedBox(width: 8),
                        if (measure.impacto != null) ...[
                          _buildImpactStars(measure.impacto!, isSmall: true),
                          SizedBox(width: 8),
                        ],
                        Text(
                          measure.timeDisplayText,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String? difficulty, {bool isSmall = false}) {
    if (difficulty == null) return SizedBox.shrink();

    Color color;
    switch (difficulty.toLowerCase()) {
      case 'facil':
        color = AppColors.success;
        break;
      case 'intermedio':
        color = AppColors.warning;
        break;
      case 'avanzado':
        color = AppColors.error;
        break;
      default:
        color = AppColors.textLight;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        _getDifficultyDisplayText(difficulty),
        style: TextStyle(
          fontSize: isSmall ? 10 : 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
    bool isSmall = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmall ? 12 : 14, color: color),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: isSmall ? 10 : 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactStars(int impact, {bool isSmall = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < impact ? Icons.star : Icons.star_border,
          size: isSmall ? 12 : 16,
          color: AppColors.sunYellow,
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco_outlined, size: 80, color: AppColors.textLight),
          SizedBox(height: 16),
          Text(
            'No hay medidas disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Las medidas ambientales se mostrarán aquí cuando estén disponibles.',
            style: TextStyle(fontSize: 14, color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadEnvironmentalMeasures,
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
            'No se encontraron medidas',
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
              _onCategoryChanged('Todas');
              _onDifficultyChanged('Todas');
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

  void _navigateToMeasureDetail(EnvironmentalMeasureModel measure) {
    Navigator.pushNamed(context, '/measure-detail', arguments: measure.id);
  }

  Future<void> _loadEnvironmentalMeasures() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _apiClient.get(ApiConstants.environmentalMeasures);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> measuresJson = response['data'];
        final measures = measuresJson
            .map((json) => EnvironmentalMeasureModel.fromJson(json))
            .toList();

        measures.sort((a, b) {
          // Featured first, then by publication date
          if (a.destacada && !b.destacada) return -1;
          if (!a.destacada && b.destacada) return 1;
          return b.fechaPublicacion.compareTo(a.fechaPublicacion);
        });

        // Extract categories and difficulties
        final categories = measures
            .map((measure) => measure.categoria)
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList();
        categories.sort();

        final difficulties = measures
            .map((measure) => measure.dificultad)
            .where((difficulty) => difficulty != null && difficulty.isNotEmpty)
            .toSet()
            .toList();
        difficulties.sort();

        setState(() {
          _measures = measures;
          _filteredMeasures = measures;
          _categories = ['Todas', ...categories];
          _difficulties = [
            'Todas',
            ...difficulties.whereType<String>(),
          ]; // ! OJO
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              response['message'] ?? 'Error al cargar medidas ambientales';
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

  void _filterMeasures() {
    setState(() {
      List<EnvironmentalMeasureModel> filtered = _measures;

      // Filter by category
      if (_selectedCategory != 'Todas') {
        filtered = filtered
            .where((measure) => measure.categoria == _selectedCategory)
            .toList();
      }

      // Filter by difficulty
      if (_selectedDifficulty != 'Todas') {
        filtered = filtered
            .where((measure) => measure.dificultad == _selectedDifficulty)
            .toList();
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        filtered = filtered.where((measure) {
          return measure.titulo.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              measure.descripcion.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              measure.beneficios.any(
                (beneficio) => beneficio.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              ) ||
              measure.tags.any(
                (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()),
              );
        }).toList();
      }

      _filteredMeasures = filtered;
    });
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _filterMeasures();
  }

  void _onCategoryChanged(String category) {
    _selectedCategory = category;
    _filterMeasures();
  }

  void _onDifficultyChanged(String difficulty) {
    _selectedDifficulty = difficulty;
    _filterMeasures();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _apiClient.dispose();
    super.dispose();
  }
}

class EnvironmentalMeasureSearchDelegate extends SearchDelegate<String> {
  final List<EnvironmentalMeasureModel> measures;

  EnvironmentalMeasureSearchDelegate(this.measures);

  @override
  String get searchFieldLabel => 'Buscar medidas ambientales...';

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
              'Busca medidas por título, descripción o beneficios',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final filteredMeasures = measures.where((measure) {
      return measure.titulo.toLowerCase().contains(query.toLowerCase()) ||
          measure.descripcion.toLowerCase().contains(query.toLowerCase()) ||
          measure.categoria.toLowerCase().contains(query.toLowerCase()) ||
          measure.beneficios.any(
            (beneficio) =>
                beneficio.toLowerCase().contains(query.toLowerCase()),
          ) ||
          measure.tags.any(
            (tag) => tag.toLowerCase().contains(query.toLowerCase()),
          );
    }).toList();

    if (filteredMeasures.isEmpty) {
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
      itemCount: filteredMeasures.length,
      itemBuilder: (context, index) {
        final measure = filteredMeasures[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryGreen,
              child: Icon(Icons.eco, color: Colors.white),
            ),
            title: Text(
              measure.titulo,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  measure.categoria,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  measure.descripcion,
                  style: TextStyle(fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: measure.dificultad != null
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(
                        measure.dificultad!,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getDifficultyDisplayText(measure.dificultad!),
                      style: TextStyle(
                        fontSize: 10,
                        color: _getDifficultyColor(measure.dificultad!),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
            onTap: () {
              close(context, measure.id);
              Navigator.pushNamed(
                context,
                '/measure-detail',
                arguments: measure.id,
              );
            },
          ),
        );
      },
    );
  }

  String _getDifficultyDisplayText(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'facil':
        return 'Fácil';
      case 'intermedio':
        return 'Intermedio';
      case 'avanzado':
        return 'Avanzado';
      default:
        return difficulty;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'facil':
        return AppColors.success;
      case 'intermedio':
        return AppColors.warning;
      case 'avanzado':
        return AppColors.error;
      default:
        return AppColors.textLight;
    }
  }
}
