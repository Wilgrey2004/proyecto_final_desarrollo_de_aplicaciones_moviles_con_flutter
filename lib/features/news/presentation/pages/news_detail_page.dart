import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/news_model.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as custom_error;

class NewsDetailPage extends StatefulWidget {
  final String? newsId;

  const NewsDetailPage({Key? key, this.newsId}) : super(key: key);

  @override
  _NewsDetailPageState createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  final ApiClient _apiClient = ApiClient();
  NewsModel? _news;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNewsDetail();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newsId =
        widget.newsId ?? ModalRoute.of(context)?.settings.arguments as String?;
    if (newsId != null && newsId != _news?.id) {
      _loadNewsDetail();
    }
  }

  Future<void> _loadNewsDetail() async {
    final newsId =
        widget.newsId ?? ModalRoute.of(context)?.settings.arguments as String?;

    if (newsId == null) {
      setState(() {
        _errorMessage = 'ID de noticia no válido';
        _isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _apiClient.get('${ApiConstants.news}/$newsId');

      if (response['success'] == true && response['data'] != null) {
        final newsData = response['data'];
        final news = NewsModel.fromJson(newsData);

        setState(() {
          _news = news;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Error al cargar la noticia';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: LoadingWidget(message: 'Cargando noticia...'),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: custom_error.ErrorWidget(
          message: _errorMessage!,
          onRetry: _loadNewsDetail,
        ),
      );
    }

    if (_news == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Noticia no encontrada'),
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: Center(child: Text('La noticia no fue encontrada')),
      );
    }

    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(child: _buildMainContent()),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: _news!.imagen != null
            ? CachedNetworkImage(
                imageUrl: _news!.imagen!,
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
                      colors: [AppColors.primaryGreen, AppColors.lightGreen],
                    ),
                  ),
                  child: Center(
                    child: Icon(Icons.newspaper, size: 80, color: Colors.white),
                  ),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryGreen, AppColors.lightGreen],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.newspaper, size: 80, color: Colors.white),
                ),
              ),
      ),
      actions: [IconButton(icon: Icon(Icons.share), onPressed: _shareNews)],
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 20),
          _buildTags(),
          SizedBox(height: 20),
          _buildArticleContent(),
          SizedBox(height: 30),
          _buildAuthorInfo(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_news!.destacada)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.warning,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'NOTICIA DESTACADA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        Text(
          _news!.titulo,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        SizedBox(height: 12),
        Text(
          _news!.resumen,
          style: TextStyle(
            fontSize: 18,
            color: AppColors.textSecondary,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.schedule, size: 16, color: AppColors.textLight),
            SizedBox(width: 4),
            Text(
              _news!.timeAgo,
              style: TextStyle(fontSize: 14, color: AppColors.textLight),
            ),
            SizedBox(width: 16),
            Icon(Icons.visibility, size: 16, color: AppColors.textLight),
            SizedBox(width: 4),
            Text(
              '${_news!.vistas} vistas',
              style: TextStyle(fontSize: 14, color: AppColors.textLight),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTags() {
    if (_news!.tags.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etiquetas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _news!.tags.map((tag) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                ),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildArticleContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contenido',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Text(
          _news!.contenido,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryGreen,
            child: Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Autor',
                  style: TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
                Text(
                  _news!.autor,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Publicado el ${_formatDate(_news!.fechaPublicacion)}',
                  style: TextStyle(
                    fontSize: 12,
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

  String _formatDate(DateTime date) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  void _shareNews() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función de compartir no implementada'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }
}
