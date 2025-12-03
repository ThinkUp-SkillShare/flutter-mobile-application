import 'package:flutter/material.dart';
import '../../domain/entities/student_entity.dart';
import '../../services/student_service.dart';
import '../widgets/edit_profile/edit_profile_form.dart';
import '../widgets/edit_profile/profile_image_section.dart';

/// Screen for editing student profile information.
/// Uses composition to separate concerns between form, image, and logic.
class EditProfileScreen extends StatefulWidget {
  final Student student;
  final Function(Student) onSave;

  const EditProfileScreen({
    super.key,
    required this.student,
    required this.onSave,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final StudentService _studentService = StudentService();
  late EditProfileFormController _formController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _formController = EditProfileFormController(student: widget.student);
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  /// Saves the updated profile information to the API.
  Future<void> _saveProfile() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final updateData = _formController.buildUpdateData();
      final updatedStudent = await _studentService.updateStudent(widget.student.id, updateData);

      widget.onSave(updatedStudent);
      Navigator.pop(context);

      _showSuccessSnackBar();
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error updating profile: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ProfileImageSection(
              profileImageUrl: _formController.profileImageController.text,
              selectedGender: _formController.selectedGender,
            ),
            const SizedBox(height: 16),
            EditProfileForm(formController: _formController),
            const SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFFFAFAFA),
      title: const Text(
        'Edit Profile',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Colors.black87,
        ),
      ),
      leading: IconButton(
        onPressed: _isSaving ? null : () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
      ),
      actions: [_buildSaveAction()],
    );
  }

  Widget _buildSaveAction() {
    if (_isSaving) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return TextButton(
      onPressed: _saveProfile,
      child: const Text(
        'Save',
        style: TextStyle(
          color: Color(0xFF0F4C75),
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F4C75),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Text(
          'Save Changes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}