import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:skill_share/features/files/services/file_service.dart';
import 'package:skill_share/features/groups/services/group_service.dart';

import '../../../auth/application/auth_service.dart';

class UploadDocumentDialog extends StatefulWidget {
  final List<Map<String, dynamic>> groups;
  final File? initialFile;

  const UploadDocumentDialog({super.key, required this.groups, this.initialFile});

  @override
  State<UploadDocumentDialog> createState() => _UploadDocumentDialogState();
}

class _UploadDocumentDialogState extends State<UploadDocumentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _selectedGroupId;
  File? _selectedFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _selectedFile = widget.initialFile;
    if (widget.groups.isNotEmpty) {
      _selectedGroupId = widget.groups.first['id'];
    }
  }

  Future<void> _selectFile() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (file != null) {
      setState(() => _selectedFile = File(file.path));
    }
  }

  Future<void> _uploadDocument() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un grupo')),
      );
      return;
    }
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un archivo')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final token = await AuthService.getAuthToken();
      if (token == null) return;

      await FileService.uploadDocument(
        groupId: _selectedGroupId!,
        title: _titleController.text,
        file: _selectedFile!,
        token: token,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        // Eliminado subjectId ya que no se necesita más
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Documento subido exitosamente'),
            backgroundColor: Color(0xFF27AE60),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir documento: $e'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Subir Documento',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2C3E50)),
              ),
              const SizedBox(height: 24),

              // Selección de grupo
              const Text('Grupo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButton<int>(
                  value: _selectedGroupId,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: widget.groups.map((group) {
                    return DropdownMenuItem<int>(
                      value: group['id'],
                      child: Text(group['name'] ?? 'Sin nombre'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedGroupId = value),
                ),
              ),
              const SizedBox(height: 16),

              // Título
              const Text('Título del documento', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Ingresa el título del documento',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descripción
              const Text('Descripción (opcional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe el contenido del documento...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),

              // Selección de archivo
              const Text('Archivo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.cloud_upload, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        _selectedFile != null
                            ? _selectedFile!.path.split('/').last
                            : 'Toca para seleccionar un archivo',
                        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      if (_selectedFile != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${(_selectedFile!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isUploading ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancelar', style: TextStyle(color: Color(0xFF2C3E50))),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _uploadDocument,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F4C75),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isUploading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                          : const Text('Subir', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}