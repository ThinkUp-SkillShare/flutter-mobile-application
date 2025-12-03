import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:skillshare/features/files/services/file_service.dart';
import 'package:skillshare/features/groups/services/group_service.dart';
import 'package:skillshare/features/files/presentation/widgets/upload_document_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../../../auth/application/auth_service.dart';
import '../../../../core/constants/api_constants.dart';

class MyFilesScreen extends StatefulWidget {
  final int? groupId;
  final String? groupName;

  const MyFilesScreen({super.key, this.groupId, this.groupName});

  @override
  State<MyFilesScreen> createState() => _MyFilesScreenState();
}

class _MyFilesScreenState extends State<MyFilesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isGridView = false;
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _files = [];
  List<Map<String, dynamic>> _filteredFiles = [];
  List<Map<String, dynamic>> _userGroups = [];
  Map<String, dynamic> _statistics = {
    'totalDocuments': 0,
    'myDocuments': 0,
    'totalSize': 0,
  };
  bool _isLoading = true;

  // Para manejar archivos favoritos (seguiríamos necesitando la implementación backend)
  final Set<int> _favoriteFiles = Set<int>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final token = await AuthService.getAuthToken();
      if (token == null) return;

      // Cargar documentos
      if (widget.groupId != null) {
        _files.clear();
        _files.addAll(
          await FileService.getGroupDocuments(widget.groupId!, token),
        );

        // Calcular estadísticas para el grupo
        final userId = await AuthService.getUserId();
        _statistics = {
          'totalDocuments': _files.length,
          'myDocuments': _files.where((f) => f['userId'] == userId).length,
          'totalSize': _files.fold<int>(
            0,
            (sum, file) => sum + ((file['fileSize'] as int?) ?? 0),
          ),
        };
      } else {
        _files.clear();
        _files.addAll(await FileService.getUserDocuments(token));

        // Usar el endpoint de estadísticas globales
        _statistics = await FileService.getGlobalStatistics(token);

        // Si el endpoint falla, calcular localmente
        if (_statistics.isEmpty) {
          final userId = await AuthService.getUserId();
          _statistics = {
            'totalDocuments': _files.length,
            'myDocuments': _files.where((f) => f['userId'] == userId).length,
            'totalSize': _files.fold<int>(
              0,
              (sum, file) => sum + ((file['fileSize'] as int?) ?? 0),
            ),
          };
        }
      }

      // Cargar grupos del usuario para el diálogo de subida
      final userId = await AuthService.getUserId();
      if (userId != null) {
        _userGroups = await GroupService.getUserGroups(userId, token);
      }

      _filterFiles();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _animationController.forward();
      });
    }
  }

  void _filterFiles() {
    List<Map<String, dynamic>> filtered = List.from(_files);

    // Filtro de búsqueda
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((file) {
        return file['title']?.toString().toLowerCase().contains(query) ==
                true ||
            file['description']?.toString().toLowerCase().contains(query) ==
                true ||
            file['fileName']?.toString().toLowerCase().contains(query) == true;
      }).toList();
    }

    // Filtro por pestaña
    final now = DateTime.now();
    switch (_tabController.index) {
      case 1: // Recientes (última semana)
        filtered = filtered.where((file) {
          final uploadDate = DateTime.parse(file['uploadDate']);
          return now.difference(uploadDate).inDays <= 7;
        }).toList();
        break;
      case 2: // Favoritos
        // Implementar cuando tengamos backend para favoritos
        filtered = filtered
            .where((file) => _favoriteFiles.contains(file['id']))
            .toList();
        break;
      case 3: // Subidos por mí
        filtered = filtered
            .where((file) => file['userId'] == _getCurrentUserId())
            .toList();
        break;
    }

    setState(() => _filteredFiles = filtered);
  }

  Future<void> _showUploadOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Subir archivo desde',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 24),

            // Opción: Foto
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.photo_camera, color: Color(0xFF3498DB)),
              ),
              title: const Text(
                'Foto',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Tomar una foto o seleccionar de galería'),
              onTap: () {
                Navigator.pop(context);
                _selectPhoto();
              },
            ),

            const Divider(),

            // Opción: Documento
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insert_drive_file,
                  color: Color(0xFF27AE60),
                ),
              ),
              title: const Text(
                'Documento',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('PDF, Word, Excel, PowerPoint'),
              onTap: () {
                Navigator.pop(context);
                _selectDocument();
              },
            ),

            const Divider(),

            // Opción: Google Drive (opcional)
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4285F4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.cloud, color: Color(0xFF4285F4)),
              ),
              title: const Text(
                'Google Drive',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Importar desde tu cuenta de Google'),
              onTap: () {
                Navigator.pop(context);
                _importFromGoogleDrive();
              },
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Color(0xFF2C3E50)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null && mounted) {
      await _showUploadDialog(File(image.path));
    }
  }

  Future<void> _selectDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'ppt',
        'pptx',
        'xls',
        'xlsx',
        'jpg',
        'jpeg',
        'png',
      ],
    );

    if (result != null && result.files.single.path != null && mounted) {
      await _showUploadDialog(File(result.files.single.path!));
    }
  }

  Future<void> _importFromGoogleDrive() async {
    // Implementación futura para Google Drive
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de Google Drive en desarrollo'),
      ),
    );
  }

  Future<void> _showUploadDialog(File? file) async {
    final result = await showDialog(
      context: context,
      builder: (context) =>
          UploadDocumentDialog(groups: _userGroups, initialFile: file),
    );

    if (result == true) {
      _loadData(); // Recargar datos después de subir
    }
  }

  void _showFileActions(Map<String, dynamic> file) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F4C75).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.open_in_new, color: Color(0xFF0F4C75)),
              ),
              title: const Text(
                'Abrir',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                _openFile(file);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.download, color: Color(0xFF27AE60)),
              ),
              title: const Text(
                'Descargar/Guardar',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                _downloadFile(file);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _favoriteFiles.contains(file['id'])
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: const Color(0xFFE74C3C),
                ),
              ),
              title: Text(
                _favoriteFiles.contains(file['id'])
                    ? 'Quitar de favoritos'
                    : 'Me encanta',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                _toggleFavorite(file);
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete, color: Colors.grey),
              ),
              title: const Text(
                'Eliminar',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteFile(file);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFile(Map<String, dynamic> file) async {
    try {
      final token = await AuthService.getAuthToken();
      if (token == null) return;

      // Verificar si el archivo tiene URL de Firebase Storage
      final fileUrl = file['fileUrl'] as String?;

      if (fileUrl != null && fileUrl.contains('firebasestorage.googleapis.com')) {
        // Es una URL de Firebase Storage - usar directamente
        final result = await OpenFile.open(fileUrl);

        if (result.type == ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Archivo abierto exitosamente'),
              backgroundColor: Color(0xFF27AE60),
            ),
          );
        } else {
          // Si no se puede abrir directamente, descargar primero
          await _downloadAndOpenFile(file, token);
        }
      } else {
        // Usar el endpoint de descarga tradicional
        await _downloadAndOpenFile(file, token);
      }
    } catch (e) {
      print('Error opening file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo abrir el archivo: $e'),
          backgroundColor: const Color(0xFFE74C3C),
        ),
      );
    }
  }

  Future<void> _downloadAndOpenFile(Map<String, dynamic> file, String token) async {
    try {
      final downloadResult = await FileService.downloadDocument(file['id'], token);

      if (downloadResult['filePath'] != null) {
        final filePath = downloadResult['filePath'] as String;
        await OpenFile.open(filePath);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Archivo descargado y abierto'),
            backgroundColor: Color(0xFF27AE60),
          ),
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _downloadFile(Map<String, dynamic> file) async {
    try {
      final token = await AuthService.getAuthToken();
      if (token == null) return;

      // Implementar descarga real aquí
      // Por ahora solo mostramos mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Descargando archivo...'),
          backgroundColor: Color(0xFF27AE60),
        ),
      );

      // Lógica de descarga real:
      // 1. Obtener la URL del archivo
      // 2. Descargar usando http package
      // 3. Guardar en el almacenamiento local
      // 4. Mostrar confirmación
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al descargar: $e'),
          backgroundColor: const Color(0xFFE74C3C),
        ),
      );
    }
  }

  Future<void> _toggleFavorite(Map<String, dynamic> file) async {
    try {
      final token = await AuthService.getAuthToken();
      if (token == null) return;

      // Aquí implementarías la llamada al backend para marcar como favorito
      setState(() {
        if (_favoriteFiles.contains(file['id'])) {
          _favoriteFiles.remove(file['id']);
        } else {
          _favoriteFiles.add(file['id']);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _favoriteFiles.contains(file['id'])
                ? 'Añadido a favoritos'
                : 'Removido de favoritos',
          ),
          backgroundColor: const Color(0xFF27AE60),
        ),
      );

      _filterFiles(); // Actualizar filtros
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFE74C3C),
        ),
      );
    }
  }

  Future<void> _deleteFile(Map<String, dynamic> file) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar archivo'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${file['title']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE74C3C),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final token = await AuthService.getAuthToken();
        if (token == null) return;

        await FileService.deleteDocument(file['id'], token);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Archivo eliminado'),
            backgroundColor: Color(0xFF27AE60),
          ),
        );

        _loadData(); // Recargar datos
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  Color _getFileTypeColor(String fileType) {
    return switch (fileType?.toLowerCase()) {
      'pdf' => const Color(0xFFE74C3C), // Rojo para PDF
      'doc' ||
      'docx' ||
      'document' => const Color(0xFF2B579A), // Azul para Word
      'xls' ||
      'xlsx' ||
      'spreadsheet' => const Color(0xFF217346), // Verde para Excel
      'ppt' ||
      'pptx' ||
      'presentation' => const Color(0xFFD24726), // Naranja para PowerPoint
      'jpg' ||
      'jpeg' ||
      'png' ||
      'gif' ||
      'bmp' ||
      'image' => const Color(0xFFE67E22), // Naranja para imágenes
      _ => const Color(0xFF95A5A6), // Gris para otros
    };
  }

  IconData _getFileTypeIcon(String fileType) {
    return switch (fileType?.toLowerCase()) {
      'pdf' => Icons.picture_as_pdf,
      'doc' || 'docx' || 'document' => Icons.description,
      'xls' || 'xlsx' || 'spreadsheet' => Icons.table_chart,
      'ppt' || 'pptx' || 'presentation' => Icons.slideshow,
      'jpg' || 'jpeg' || 'png' || 'gif' || 'bmp' || 'image' => Icons.image,
      _ => Icons.insert_drive_file,
    };
  }

  String _formatFileSize(dynamic bytes) {
    try {
      final intValue = bytes is int ? bytes : int.tryParse(bytes.toString()) ?? 0;
      if (intValue < 1024) return '$intValue B';
      if (intValue < 1048576) return '${(intValue / 1024).toStringAsFixed(1)} KB';
      return '${(intValue / 1048576).toStringAsFixed(1)} MB';
    } catch (e) {
      return '0 B';
    }
  }

  String _getTimeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365)
        return '${(difference.inDays / 365).floor()}y';
      if (difference.inDays > 30)
        return '${(difference.inDays / 30).floor()}mo';
      if (difference.inDays > 0) return '${difference.inDays}d';
      if (difference.inHours > 0) return '${difference.inHours}h';
      if (difference.inMinutes > 0) return '${difference.inMinutes}m';
      return 'Ahora';
    } catch (e) {
      return '--';
    }
  }

  int? _getCurrentUserId() {
    // Implementar obtención del ID del usuario actual
    // Por ahora retornamos null
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(),
          _buildSliverTabBar(),
        ],
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : FadeTransition(
                opacity: _fadeAnimation,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFilesView(),
                    _buildRecentView(),
                    _buildFavoritesView(),
                    _buildMyUploadsView(),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "upload",
        onPressed: _showUploadOptions,
        backgroundColor: const Color(0xFF0F4C75),
        icon: const Icon(Icons.cloud_upload, color: Colors.white),
        label: const Text(
          'Subir',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      title: _isSearchVisible
          ? Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (_) => _filterFiles(),
                decoration: InputDecoration(
                  hintText: 'Buscar archivos...',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF0F4C75),
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF0F4C75),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSearchVisible = false;
                        _searchController.clear();
                        _filterFiles();
                      });
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            )
          : Text(
              widget.groupName ?? 'Mis Archivos',
              style: const TextStyle(
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
      actions: [
        if (!_isSearchVisible) ...[
          IconButton(
            onPressed: () {
              setState(() => _isSearchVisible = true);
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F4C75).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.search,
                color: Color(0xFF0F4C75),
                size: 20,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F4C75).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _isGridView ? Icons.view_list : Icons.grid_view,
                color: const Color(0xFF0F4C75),
                size: 20,
              ),
            ),
          ),
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F4C75).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.tune, color: Color(0xFF0F4C75), size: 20),
            ),
          ),
        ],
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSliverTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0F4C75),
          unselectedLabelColor: Colors.grey[600],
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          indicator: BoxDecoration(
            color: const Color(0xFF0F4C75),
            borderRadius: BorderRadius.circular(20),
          ),
          indicatorPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Recientes'),
            Tab(text: 'Favoritos'),
            Tab(text: 'Subidos por mí'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilesView() {
    return Column(
      children: [
        _buildStatisticsCards(),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isGridView ? _buildGridView() : _buildListView(),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentView() {
    final recentFiles = _filteredFiles;
    return _buildFileList(recentFiles);
  }

  Widget _buildFavoritesView() {
    final favoriteFiles = _filteredFiles;
    return _buildFileList(favoriteFiles);
  }

  Widget _buildMyUploadsView() {
    final myFiles = _filteredFiles;
    return _buildFileList(myFiles);
  }

  Widget _buildFileList(List<Map<String, dynamic>> files) {
    return files.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No se encontraron archivos',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          )
        : _isGridView
        ? _buildGridList(files)
        : _buildListList(files);
  }

  Widget _buildListList(List<Map<String, dynamic>> files) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: files.length,
        itemBuilder: (context, index) => _buildFileCard(files[index], index),
      ),
    );
  }

  Widget _buildGridList(List<Map<String, dynamic>> files) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: files.length,
        itemBuilder: (context, index) =>
            _buildFileGridCard(files[index], index),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Archivos',
              '${_statistics['totalDocuments'] ?? 0}',
              Icons.folder,
              const Color(0xFF3498DB),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Mis Archivos',
              '${_statistics['myDocuments'] ?? 0}',
              Icons.person,
              const Color(0xFF27AE60),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Tamaño Total',
              _formatFileSize((_statistics['totalSize'] ?? 0).toInt()),
              Icons.storage,
              const Color(0xFFE74C3C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _filteredFiles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No se encontraron archivos',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: _filteredFiles.length,
              itemBuilder: (context, index) =>
                  _buildFileCard(_filteredFiles[index], index),
            ),
    );
  }

  Widget _buildGridView() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _filteredFiles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No se encontraron archivos',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _filteredFiles.length,
              itemBuilder: (context, index) =>
                  _buildFileGridCard(_filteredFiles[index], index),
            ),
    );
  }

  Widget _buildFileCard(Map<String, dynamic> file, int index) {
    final fileType = file['fileType'] ?? 'other';
    final color = _getFileTypeColor(fileType);
    final icon = _getFileTypeIcon(fileType);

    return GestureDetector(
      onTap: () => _showFileActions(file),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            file['title'] ?? 'Sin título',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_favoriteFiles.contains(file['id']))
                          const Icon(
                            Icons.favorite,
                            color: Color(0xFFE74C3C),
                            size: 16,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      file['userEmail'] ?? 'Usuario desconocido',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            file['fileType']?.toUpperCase() ?? 'OTRO',
                            style: TextStyle(
                              fontSize: 10,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getTimeAgo(file['uploadDate']),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatFileSize((file['fileSize'] ?? 0).toInt()),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _showFileActions(file),
                icon: const Icon(Icons.more_vert, color: Color(0xFF0F4C75)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileGridCard(Map<String, dynamic> file, int index) {
    final fileType = file['fileType'] ?? 'other';
    final color = _getFileTypeColor(fileType);
    final icon = _getFileTypeIcon(fileType);

    return GestureDetector(
      onTap: () => _showFileActions(file),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const Spacer(),
                  if (_favoriteFiles.contains(file['id']))
                    const Icon(
                      Icons.favorite,
                      color: Color(0xFFE74C3C),
                      size: 16,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                file['title'] ?? 'Sin título',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                file['userEmail'] ?? 'Usuario',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      file['fileType']?.toUpperCase() ?? 'OTRO',
                      style: TextStyle(
                        fontSize: 9,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatFileSize((file['fileSize'] ?? 0).toInt()),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 10, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    _getTimeAgo(file['uploadDate']),
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Fecha de subida',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip(
                    'Todos',
                    Icons.all_inclusive,
                    const Color(0xFF9B59B6),
                    false,
                    () {
                      // Implementar lógica de filtro
                    },
                  ),
                  _buildFilterChip(
                    'Hoy',
                    Icons.today,
                    const Color(0xFF9B59B6),
                    false,
                    () {
                      // Implementar lógica de filtro
                    },
                  ),
                  _buildFilterChip(
                    'Esta semana',
                    Icons.date_range,
                    const Color(0xFF9B59B6),
                    false,
                    () {
                      // Implementar lógica de filtro
                    },
                  ),
                  _buildFilterChip(
                    'Este mes',
                    Icons.calendar_month,
                    const Color(0xFF9B59B6),
                    false,
                    () {
                      // Implementar lógica de filtro
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: const Color(0xFF2C3E50),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Limpiar',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Aplicar filtros
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F4C75),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Aplicar',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    IconData icon,
    Color color,
    bool selected,
    VoidCallback onTap,
  ) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white,
      selectedColor: color.withOpacity(0.1),
      checkmarkColor: color,
      side: BorderSide(color: color.withOpacity(0.3)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
