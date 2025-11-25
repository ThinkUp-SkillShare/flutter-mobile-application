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
  late TextEditingController _profileImageController;
  late TextEditingController _dateBirthController;

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
    _profileImageController = TextEditingController(text: widget.student.user?.profileImage ?? '');
    _selectedGender = widget.student.gender;
    _phoneController = TextEditingController();

    if (widget.student.dateBirth != null) {
      _dateBirthController = TextEditingController(
          text: '${widget.student.dateBirth!.year}-${widget.student.dateBirth!.month.toString().padLeft(2, '0')}-${widget.student.dateBirth!.day.toString().padLeft(2, '0')}'
      );
    } else {
      _dateBirthController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nicknameController.dispose();
    _educationCenterController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _profileImageController.dispose();
    _dateBirthController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
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
          fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
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
                Text(_getGenderLabel(gender)),
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
      case 'male':
        return Icons.male;
      case 'female':
        return Icons.female;
      case 'other':
        return Icons.transgender;
      case 'prefer_not_to_say':
        return Icons.visibility_off_outlined;
      default:
        return Icons.help_outline;
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
      case 'male':
        return Colors.blue;
      case 'female':
        return Colors.pink;
      case 'other':
        return Colors.purple;
      case 'prefer_not_to_say':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.student.dateBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dateBirthController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Widget _buildBirthdayField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _dateBirthController,
        readOnly: true,
        onTap: _selectDate,
        decoration: InputDecoration(
          labelText: 'Fecha de Cumpleaños',
          prefixIcon: Icon(Icons.cake, color: Colors.grey.shade600),
          suffixIcon: Icon(Icons.calendar_today, color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
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
      DateTime? dateBirth;
      if (_dateBirthController.text.isNotEmpty) {
        dateBirth = DateTime.tryParse(_dateBirthController.text);
      }

      final updateData = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'nickname': _nicknameController.text.isEmpty ? null : _nicknameController.text,
        'country': _countryController.text.isEmpty ? null : _countryController.text,
        'educationalCenter': _educationCenterController.text.isEmpty ? null : _educationCenterController.text,
        'gender': _selectedGender,
        'dateBirth': dateBirth?.toIso8601String(),
        'profileImage': _profileImageController.text.isEmpty ? null : _profileImageController.text, // Este campo ahora se enviará al backend
      };

      print('🔄 DEBUG - Sending update data: $updateData');

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

  Widget _buildProfileImage() {
    return Center(
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
              child: _profileImageController.text.isNotEmpty
                  ? Image.network(
                _profileImageController.text,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultEditAvatar();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildDefaultEditAvatar();
                },
              )
                  : _buildDefaultEditAvatar(),
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
    );
  }

  Widget _buildDefaultEditAvatar() {
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
            _buildProfileImage(),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _profileImageController,
              label: 'URL de Foto de Perfil',
              icon: Icons.link,
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 16),

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
            _buildBirthdayField(), // Ahora es editable
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