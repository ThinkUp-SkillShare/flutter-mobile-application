import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skill_share/features/files/services/file_service.dart';
import 'package:skill_share/features/groups/services/group_service.dart';
import 'package:skill_share/features/files/presentation/widgets/upload_document_dialog.dart';

import '../../../auth/application/auth_service.dart';

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
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;

  final List<String> _categories = [
    'Todos',
    'Matemáticas',
    'Medicina',
    'Arte',
    'Tecnología',
    'Humanidades',
    'Ciencias',
    'General',
  ];

  String _selectedCategory = 'Todos';
  String _selectedFileType = 'Todos';
  String _selectedDateFilter = 'Todos';

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
        _files.addAll(await FileService.getGroupDocuments(widget.groupId!, token));

        // Cargar estadísticas del grupo
        _statistics = await FileService.getGroupStatistics(widget.groupId!, token);
      } else {
        _files.clear();
        _files.addAll(await FileService.getUserDocuments(token));
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
        return file['title']?.toString().toLowerCase().contains(query) == true ||
            file['description']?.toString().toLowerCase().contains(query) == true ||
            file['category']?.toString().toLowerCase().contains(query) == true;
      }).toList();
    }

    // Filtro de categoría
    if (_selectedCategory != 'Todos') {
      filtered = filtered.where((file) => file['category'] == _selectedCategory).toList();
    }

    // Filtro de tipo de archivo
    if (_selectedFileType != 'Todos') {
      filtered = filtered.where((file) => file['fileType'] == _selectedFileType.toLowerCase()).toList();
    }

    // Filtro de fecha
    final now = DateTime.now();
    if (_selectedDateFilter != 'Todos') {
      filtered = filtered.where((file) {
        final uploadDate = DateTime.parse(file['uploadDate']);
        final difference = now.difference(uploadDate);

        switch (_selectedDateFilter) {
          case 'Hoy':
            return difference.inDays == 0;
          case 'Esta semana':
            return difference.inDays <= 7;
          case 'Este mes':
            return difference.inDays <= 30;
          case 'Más antiguo':
            return difference.inDays > 30;
          default:
            return true;
        }
      }).toList();
    }

    setState(() => _filteredFiles = filtered);
  }

  Future<void> _uploadFromDevice() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (file != null && mounted) {
      await _showUploadDialog(File(file.path));
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (photo != null && mounted) {
      await _showUploadDialog(File(photo.path));
    }
  }

  Future<void> _showUploadDialog(File? file) async {
    final result = await showDialog(
      context: context,
      builder: (context) => UploadDocumentDialog(
        groups: _userGroups,
        initialFile: file,
      ),
    );

    if (result == true) {
      _loadData(); // Recargar datos después de subir
    }
  }

  void _showFileActions(Map<String, dynamic> file) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.open_in_new, color: Color(0xFF0F4C75)),
              title: const Text('Abrir'),
              onTap: () {
                Navigator.pop(context);
                _openFile(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download, color: Color(0xFF27AE60)),
              title: const Text('Descargar'),
              onTap: () {
                Navigator.pop(context);
                _downloadFile(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Color(0xFF3498DB)),
              title: const Text('Compartir'),
              onTap: () {
                Navigator.pop(context);
                _shareFile(file);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: Color(0xFFE74C3C)),
              title: const Text('Eliminar'),
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
    // Implementar apertura de archivo según el tipo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abriendo: ${file['title']}')),
    );
  }

  Future<void> _downloadFile(Map<String, dynamic> file) async {
    try {
      final token = await AuthService.getAuthToken();
      if (token == null) return;

      await FileService.downloadDocument(file['id'], token);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Descarga iniciada'),
          backgroundColor: Color(0xFF27AE60),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al descargar: $e'),
          backgroundColor: const Color(0xFFE74C3C),
        ),
      );
    }
  }

  Future<void> _shareFile(Map<String, dynamic> file) async {
    // Implementar compartir archivo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Compartiendo: ${file['title']}')),
    );
  }

  Future<void> _deleteFile(Map<String, dynamic> file) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar archivo'),
        content: Text('¿Estás seguro de que quieres eliminar "${file['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFE74C3C)),
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
    return switch (fileType) {
      'pdf' => const Color(0xFFE74C3C),
      'document' => const Color(0xFF3498DB),
      'presentation' => const Color(0xFF27AE60),
      'spreadsheet' => const Color(0xFF1ABC9C),
      'image' => const Color(0xFFE67E22),
      _ => const Color(0xFF95A5A6),
    };
  }

  IconData _getFileTypeIcon(String fileType) {
    return switch (fileType) {
      'pdf' => Icons.picture_as_pdf,
      'document' => Icons.description,
      'presentation' => Icons.slideshow,
      'spreadsheet' => Icons.table_chart,
      'image' => Icons.image,
      _ => Icons.insert_drive_file,
    };
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  String _getTimeAgo(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) return '${(difference.inDays / 365).floor()}y';
    if (difference.inDays > 30) return '${(difference.inDays / 30).floor()}mo';
    if (difference.inDays > 0) return '${difference.inDays}d';
    if (difference.inHours > 0) return '${difference.inHours}h';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m';
    return 'Ahora';
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
              _buildSharedView(),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.black12,
      flexibleSpace: FlexibleSpaceBar(
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
              prefixIcon: const Icon(Icons.search, color: Color(0xFF0F4C75), size: 20),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF0F4C75), size: 20),
                onPressed: () {
                  setState(() {
                    _isSearchVisible = false;
                    _searchController.clear();
                    _filterFiles();
                  });
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Total: ${_files.length} archivos',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Última actualización: ${_getTimeAgo(DateTime.now().toIso8601String())}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
              child: const Icon(Icons.search, color: Color(0xFF0F4C75), size: 20),
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
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          indicator: BoxDecoration(
            color: const Color(0xFF0F4C75),
            borderRadius: BorderRadius.circular(20),
          ),
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Recientes'),
            Tab(text: 'Favoritos'),
            Tab(text: 'Compartidos'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilesView() {
    return Column(
      children: [
        _buildStatisticsCards(),
        _buildCategoryFilter(),
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
    final recentFiles = _filteredFiles.where((file) {
      final uploadDate = DateTime.parse(file['uploadDate']);
      return DateTime.now().difference(uploadDate).inDays <= 7;
    }).toList();

    return _buildFileList(recentFiles);
  }

  Widget _buildFavoritesView() {
    // Implementar lógica de favoritos cuando se agregue a la base de datos
    return _buildFileList(_filteredFiles);
  }

  Widget _buildSharedView() {
    // Implementar lógica de compartidos cuando se agregue a la base de datos
    return _buildFileList(_filteredFiles);
  }

  Widget _buildFileList(List<Map<String, dynamic>> files) {
    return Column(
      children: [
        _buildCategoryFilter(),
        Expanded(
          child: files.isEmpty
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No se encontraron archivos', style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
              : _isGridView ? _buildGridList(files) : _buildListList(files),
        ),
      ],
    );
  }

  Widget _buildListList(List<Map<String, dynamic>> files) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: files.length,
      itemBuilder: (context, index) => _buildFileCard(files[index], index),
    );
  }

  Widget _buildGridList(List<Map<String, dynamic>> files) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: files.length,
      itemBuilder: (context, index) => _buildFileGridCard(files[index], index),
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
              'PDF',
              '${_statistics['pdfCount'] ?? 0}',
              Icons.picture_as_pdf,
              const Color(0xFFE74C3C),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Tamaño Total',
              _formatFileSize((_statistics['totalSize'] ?? 0).toInt()),
              Icons.storage,
              const Color(0xFF27AE60),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2C3E50))),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                  _filterFiles();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0F4C75) : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: isSelected ? const Color(0xFF0F4C75) : Colors.grey[300]!),
                  boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF0F4C75).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
                ),
                child: Text(
                  category,
                  style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF2C3E50), fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListView() {
    return _filteredFiles.isEmpty
        ? const Center(child: Text('No se encontraron archivos'))
        : ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filteredFiles.length,
      itemBuilder: (context, index) => _buildFileCard(_filteredFiles[index], index),
    );
  }

  Widget _buildGridView() {
    return _filteredFiles.isEmpty
        ? const Center(child: Text('No se encontraron archivos'))
        : GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredFiles.length,
      itemBuilder: (context, index) => _buildFileGridCard(_filteredFiles[index], index),
    );
  }

  Widget _buildFileCard(Map<String, dynamic> file, int index) {
    final fileType = file['fileType'] ?? 'other';
    final color = _getFileTypeColor(fileType);
    final icon = _getFileTypeIcon(fileType);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
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
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (file['downloadCount'] > 0) ...[
                        const Icon(Icons.download, color: Color(0xFF27AE60), size: 16),
                        const SizedBox(width: 4),
                        Text('${file['downloadCount']}', style: const TextStyle(fontSize: 12, color: Color(0xFF27AE60))),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    file['userEmail'] ?? 'Usuario desconocido',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          file['category'] ?? 'General',
                          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(_getTimeAgo(file['uploadDate']), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      const Spacer(),
                      Text(
                        _formatFileSize((file['fileSize'] ?? 0).toInt()),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
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
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const Spacer(),
                  if (file['downloadCount'] > 0)
                    Row(
                      children: [
                        const Icon(Icons.download, color: Color(0xFF27AE60), size: 14),
                        const SizedBox(width: 2),
                        Text('${file['downloadCount']}', style: const TextStyle(fontSize: 10, color: Color(0xFF27AE60))),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                file['title'] ?? 'Sin título',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50), height: 1.2),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                file['userEmail'] ?? 'Usuario',
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      file['category'] ?? 'General',
                      style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatFileSize((file['fileSize'] ?? 0).toInt()),
                    style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _getTimeAgo(file['uploadDate']),
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "camera",
          onPressed: _takePhoto,
          backgroundColor: const Color(0xFFE74C3C),
          child: const Icon(Icons.camera_alt, color: Colors.white),
        ),
        const SizedBox(height: 16),
        FloatingActionButton.extended(
          heroTag: "upload",
          onPressed: _uploadFromDevice,
          backgroundColor: const Color(0xFF0F4C75),
          icon: const Icon(Icons.cloud_upload, color: Colors.white),
          label: const Text('Subir archivo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 24),
              const Text('Filtros', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2C3E50))),
              const SizedBox(height: 24),

              const Text('Tipo de archivo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip('Todos', Icons.all_inclusive, const Color(0xFF0F4C75), _selectedFileType == 'Todos', () {
                    setState(() => _selectedFileType = 'Todos');
                  }),
                  _buildFilterChip('PDF', Icons.picture_as_pdf, const Color(0xFFE74C3C), _selectedFileType == 'pdf', () {
                    setState(() => _selectedFileType = 'pdf');
                  }),
                  _buildFilterChip('DOC', Icons.description, const Color(0xFF3498DB), _selectedFileType == 'document', () {
                    setState(() => _selectedFileType = 'document');
                  }),
                  _buildFilterChip('PPT', Icons.slideshow, const Color(0xFF27AE60), _selectedFileType == 'presentation', () {
                    setState(() => _selectedFileType = 'presentation');
                  }),
                  _buildFilterChip('XLS', Icons.table_chart, const Color(0xFF1ABC9C), _selectedFileType == 'spreadsheet', () {
                    setState(() => _selectedFileType = 'spreadsheet');
                  }),
                  _buildFilterChip('IMG', Icons.image, const Color(0xFFE67E22), _selectedFileType == 'image', () {
                    setState(() => _selectedFileType = 'image');
                  }),
                ],
              ),

              const SizedBox(height: 24),
              const Text('Fecha de subida', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip('Todos', Icons.all_inclusive, const Color(0xFF9B59B6), _selectedDateFilter == 'Todos', () {
                    setState(() => _selectedDateFilter = 'Todos');
                  }),
                  _buildFilterChip('Hoy', Icons.today, const Color(0xFF9B59B6), _selectedDateFilter == 'Hoy', () {
                    setState(() => _selectedDateFilter = 'Hoy');
                  }),
                  _buildFilterChip('Esta semana', Icons.date_range, const Color(0xFF9B59B6), _selectedDateFilter == 'Esta semana', () {
                    setState(() => _selectedDateFilter = 'Esta semana');
                  }),
                  _buildFilterChip('Este mes', Icons.calendar_month, const Color(0xFF9B59B6), _selectedDateFilter == 'Este mes', () {
                    setState(() => _selectedDateFilter = 'Este mes');
                  }),
                  _buildFilterChip('Más antiguo', Icons.history, const Color(0xFF9B59B6), _selectedDateFilter == 'Más antiguo', () {
                    setState(() => _selectedDateFilter = 'Más antiguo');
                  }),
                ],
              ),

              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedFileType = 'Todos';
                          _selectedDateFilter = 'Todos';
                        });
                        Navigator.pop(context);
                        _filterFiles();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: const Color(0xFF2C3E50),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Limpiar', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _filterFiles();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F4C75),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Aplicar', style: TextStyle(fontWeight: FontWeight.w600)),
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

  Widget _buildFilterChip(String label, IconData icon, Color color, bool selected, VoidCallback onTap) {
    return FilterChip(
      label: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: color), const SizedBox(width: 6), Text(label)]),
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}