import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/video_model.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as custom_error;

class VideoDetailPage extends StatefulWidget {
  final String? videoId;

  const VideoDetailPage({Key? key, this.videoId}) : super(key: key);

  @override
  _VideoDetailPageState createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  final ApiClient _apiClient = ApiClient();
  VideoPlayerController? _videoController;
  VideoModel? _video;
  bool _isLoading = true;
  bool _isVideoLoading = false;
  String? _errorMessage;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadVideoDetail();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final videoId =
        widget.videoId ?? ModalRoute.of(context)?.settings.arguments as String?;
    if (videoId != null && videoId != _video?.id) {
      _loadVideoDetail();
    }
  }

  Future<void> _loadVideoDetail() async {
    final videoId =
        widget.videoId ?? ModalRoute.of(context)?.settings.arguments as String?;

    if (videoId == null) {
      setState(() {
        _errorMessage = 'ID de video no válido';
        _isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _apiClient.get('${ApiConstants.videos}/$videoId');

      if (response['success'] == true && response['data'] != null) {
        final videoData = response['data'];
        final video = VideoModel.fromJson(videoData);

        setState(() {
          _video = video;
          _isLoading = false;
        });

        _initializeVideo();
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Error al cargar el video';
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

  Future<void> _initializeVideo() async {
    if (_video?.urlVideo == null) return;

    setState(() {
      _isVideoLoading = true;
    });

    try {
      _videoController?.dispose();

      final Uri videoUri = Uri.parse(_video!.urlVideo);
      _videoController = VideoPlayerController.networkUrl(videoUri);

      await _videoController!.initialize();

      setState(() {
        _isVideoLoading = false;
      });

      _videoController!.addListener(() {
        if (mounted) {
          setState(() {
            _isPlaying = _videoController!.value.isPlaying;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isVideoLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar el video'),
          backgroundColor: AppColors.error,
        ),
      );
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
        body: LoadingWidget(message: 'Cargando video...'),
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
          onRetry: _loadVideoDetail,
        ),
      );
    }

    if (_video == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Video no encontrado'),
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: Center(child: Text('El video no fue encontrado')),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(background: _buildVideoPlayer()),
          actions: [
            IconButton(icon: Icon(Icons.share), onPressed: _shareVideo),
          ],
        ),
        SliverToBoxAdapter(child: _buildContent()),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    if (_isVideoLoading) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('Cargando video...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    if (_videoController?.value.isInitialized != true) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.video_library, size: 60, color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Video no disponible',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _launchVideoUrl(_video!.urlVideo),
                child: Text('Ver en navegador'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
          _buildVideoControls(),
        ],
      ),
    );
  }

  Widget _buildVideoControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (_isPlaying) {
                    _videoController!.pause();
                  } else {
                    _videoController!.play();
                  }
                },
                icon: Icon(
                  _isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  _formatDuration(_videoController!.value.position),
                  style: TextStyle(color: Colors.white),
                ),
                Expanded(
                  child: Slider(
                    value: _videoController!.value.position.inSeconds
                        .toDouble(),
                    max: _videoController!.value.duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      _videoController!.seekTo(
                        Duration(seconds: value.toInt()),
                      );
                    },
                    activeColor: AppColors.primaryGreen,
                    inactiveColor: Colors.white.withOpacity(0.3),
                  ),
                ),
                Text(
                  _formatDuration(_videoController!.value.duration),
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 20),
          _buildTags(),
          SizedBox(height: 20),
          _buildDescription(),
          SizedBox(height: 30),
          _buildVideoInfo(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_video!.destacado)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.warning,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'VIDEO DESTACADO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        Text(
          _video!.titulo,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                ),
              ),
              child: Text(
                _video!.categoria,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.schedule, size: 16, color: AppColors.textLight),
            SizedBox(width: 4),
            Text(
              _video!.timeAgo,
              style: TextStyle(fontSize: 14, color: AppColors.textLight),
            ),
            SizedBox(width: 16),
            Icon(Icons.visibility, size: 16, color: AppColors.textLight),
            SizedBox(width: 4),
            Text(
              _video!.formattedViews,
              style: TextStyle(fontSize: 14, color: AppColors.textLight),
            ),
            SizedBox(width: 16),
            Icon(Icons.timer, size: 16, color: AppColors.textLight),
            SizedBox(width: 4),
            Text(
              _video!.formattedDuration,
              style: TextStyle(fontSize: 14, color: AppColors.textLight),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTags() {
    if (_video!.tags.isEmpty) return SizedBox.shrink();

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
          children: _video!.tags.map((tag) {
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

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Text(
          _video!.descripcion,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_video!.autor != null) ...[
            Row(
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
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                      Text(
                        _video!.autor!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
          Text(
            'Publicado el ${_formatDate(_video!.fechaPublicacion)}',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${minutes}:${twoDigits(seconds)}';
    }
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

  Future<void> _launchVideoUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('No se puede abrir el video: $url');
      }
    } catch (e) {
      _showSnackBar('Error al abrir el video');
    }
  }

  void _shareVideo() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función de compartir no implementada'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _apiClient.dispose();
    super.dispose();
  }
}
