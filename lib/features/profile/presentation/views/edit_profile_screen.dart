import 'package:flutter/material.dart';
import '../../domain/entities/student_entity.dart';
import '../../services/student_service.dart';

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
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _nicknameController;
  late TextEditingController _educationCenterController;
  late TextEditingController _phoneController;
  late TextEditingController _countryController;

  String _selectedGender = '';
  final List<String> _genderOptions = ['male', 'female', 'other', 'prefer_not_to_say'];

  final StudentService _studentService = StudentService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.student.firstName);
    _lastNameController = TextEditingController(text: widget.student.lastName);
    _nicknameController = TextEditingController(text: widget.student.nickname ?? '');
    _educationCenterController = TextEditingController(text: widget.student.educationalCenter ?? '');
    _countryController = TextEditingController(text: widget.student.country ?? '');
    _selectedGender = widget.student.gender;
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nicknameController.dispose();
    _educationCenterController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0F4C75), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedGender.isNotEmpty ? _selectedGender : null,
        decoration: InputDecoration(
          labelText: 'Género',
          prefixIcon: Icon(Icons.person_outline, color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0F4C75), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        items: _genderOptions.map((String gender) {
          return DropdownMenuItem<String>(
            value: gender,
            child: Row(
              children: [
                Icon(
                  _getGenderIcon(gender),
                  color: _getGenderColor(gender),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(gender),
              ],
            ),
          );
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            _selectedGender = value ?? '';
          });
        },
      ),
    );
  }

  IconData _getGenderIcon(String gender) {
    switch (gender.toLowerCase()) {
      case 'masculino':
        return Icons.male;
      case 'femenino':
        return Icons.female;
      default:
        return Icons.transgender;
    }
  }
  String _getGenderLabel(String gender) {
    switch (gender) {
      case 'male': return 'Masculino';
      case 'female': return 'Femenino';
      case 'other': return 'Otro';
      default: return 'Prefiero no decir';
    }
  }

  Color _getGenderColor(String gender) {
    switch (gender.toLowerCase()) {
      case 'masculino':
        return Colors.blue;
      case 'femenino':
        return Colors.pink;
      default:
        return Colors.purple;
    }
  }

  Widget _buildBirthdayField() {
    final birthdayText = widget.student.dateBirth != null
        ? '${widget.student.dateBirth!.day}/${widget.student.dateBirth!.month}/${widget.student.dateBirth!.year}'
        : 'No especificada';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: birthdayText,
        enabled: false,
        decoration: InputDecoration(
          labelText: 'Fecha de Cumpleaños',
          prefixIcon: Icon(Icons.cake, color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final updateData = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'nickname': _nicknameController.text.isEmpty ? null : _nicknameController.text,
        'country': _countryController.text.isEmpty ? null : _countryController.text,
        'educationalCenter': _educationCenterController.text.isEmpty ? null : _educationCenterController.text,
        'gender': _selectedGender,
      };

      final updatedStudent = await _studentService.updateStudent(widget.student.id, updateData);

      widget.onSave(updatedStudent);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado exitosamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar perfil: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFAFAFA),
        title: const Text(
          'Editar Perfil',
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
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Guardar',
                style: TextStyle(
                  color: Color(0xFF0F4C75),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.network(
                        'https://i.pinimg.com/1200x/8f/12/19/8f1219d794c7636e2fff83e7e1f554ec.jpg',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey.shade300,
                            child: Icon(
                              Icons.person,
                              color: Colors.grey.shade500,
                              size: 50,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getGenderColor(_selectedGender),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        _getGenderIcon(_selectedGender),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildTextField(
              controller: _firstNameController,
              label: 'Nombre',
              icon: Icons.person,
            ),
            _buildTextField(
              controller: _lastNameController,
              label: 'Apellido',
              icon: Icons.person_outline,
            ),
            _buildTextField(
              controller: _nicknameController,
              label: 'Nickname',
              icon: Icons.alternate_email,
            ),
            _buildBirthdayField(),
            _buildTextField(
              controller: _educationCenterController,
              label: 'Centro Educativo',
              icon: Icons.school,
            ),
            _buildTextField(
              controller: _countryController,
              label: 'País',
              icon: Icons.public,
            ),
            _buildGenderDropdown(),

            const SizedBox(height: 24),

            SizedBox(
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
                  'Guardar Cambios',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}