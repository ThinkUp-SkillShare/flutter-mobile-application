import 'package:flutter/material.dart';
import '../../../domain/entities/student_entity.dart';

/// Controller for managing form state in the edit profile screen.
class EditProfileFormController {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController nicknameController;
  final TextEditingController educationCenterController;
  final TextEditingController phoneController;
  final TextEditingController countryController;
  final TextEditingController profileImageController;
  final TextEditingController dateBirthController;
  String selectedGender;

  final List<String> genderOptions = ['male', 'female', 'other', 'prefer_not_to_say'];

  EditProfileFormController({required Student student})
      : firstNameController = TextEditingController(text: student.firstName),
        lastNameController = TextEditingController(text: student.lastName),
        nicknameController = TextEditingController(text: student.nickname ?? ''),
        educationCenterController = TextEditingController(text: student.educationalCenter ?? ''),
        countryController = TextEditingController(text: student.country ?? ''),
        profileImageController = TextEditingController(text: student.user?.profileImage ?? ''),
        selectedGender = student.gender,
        phoneController = TextEditingController(),
        dateBirthController = TextEditingController(
          text: student.dateBirth != null
              ? '${student.dateBirth!.year}-${student.dateBirth!.month.toString().padLeft(2, '0')}-${student.dateBirth!.day.toString().padLeft(2, '0')}'
              : '',
        );

  /// Builds the update data map from form fields.
  Map<String, dynamic> buildUpdateData() {
    DateTime? dateBirth;
    if (dateBirthController.text.isNotEmpty) {
      dateBirth = DateTime.tryParse(dateBirthController.text);
    }

    return {
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'nickname': nicknameController.text.isEmpty ? null : nicknameController.text,
      'country': countryController.text.isEmpty ? null : countryController.text,
      'educationalCenter': educationCenterController.text.isEmpty ? null : educationCenterController.text,
      'gender': selectedGender,
      'dateBirth': dateBirth?.toIso8601String(),
      'profileImage': profileImageController.text.isEmpty ? null : profileImageController.text,
    };
  }

  /// Cleans up all controllers.
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    nicknameController.dispose();
    educationCenterController.dispose();
    phoneController.dispose();
    countryController.dispose();
    profileImageController.dispose();
    dateBirthController.dispose();
  }

  /// Gets the appropriate icon for a gender option.
  IconData getGenderIcon(String gender) {
    switch (gender.toLowerCase()) {
      case 'male': return Icons.male;
      case 'female': return Icons.female;
      case 'other': return Icons.transgender;
      case 'prefer_not_to_say': return Icons.visibility_off_outlined;
      default: return Icons.help_outline;
    }
  }

  /// Gets the display label for a gender option.
  String getGenderLabel(String gender) {
    switch (gender) {
      case 'male': return 'Male';
      case 'female': return 'Female';
      case 'other': return 'Other';
      default: return 'Prefer not to say';
    }
  }

  /// Gets the color for a gender option.
  Color getGenderColor(String gender) {
    switch (gender.toLowerCase()) {
      case 'male': return Colors.blue;
      case 'female': return Colors.pink;
      case 'other': return Colors.purple;
      case 'prefer_not_to_say': return Colors.grey;
      default: return Colors.grey;
    }
  }
}

/// Form widget for editing profile information.
class EditProfileForm extends StatefulWidget {
  final EditProfileFormController formController;

  const EditProfileForm({super.key, required this.formController});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        widget.formController.dateBirthController.text =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
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
        value: widget.formController.selectedGender.isNotEmpty ?
        widget.formController.selectedGender : null,
        decoration: InputDecoration(
          labelText: 'Gender',
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
        items: widget.formController.genderOptions.map((String gender) {
          return DropdownMenuItem<String>(
            value: gender,
            child: Row(
              children: [
                Icon(
                  widget.formController.getGenderIcon(gender),
                  color: widget.formController.getGenderColor(gender),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(widget.formController.getGenderLabel(gender)),
              ],
            ),
          );
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            widget.formController.selectedGender = value ?? '';
          });
        },
      ),
    );
  }

  Widget _buildBirthdayField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: widget.formController.dateBirthController,
        readOnly: true,
        onTap: () => _selectDate(context),
        decoration: InputDecoration(
          labelText: 'Birth Date',
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField(
          controller: widget.formController.profileImageController,
          label: 'Profile Picture URL',
          icon: Icons.link,
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: widget.formController.firstNameController,
          label: 'First Name',
          icon: Icons.person,
        ),
        _buildTextField(
          controller: widget.formController.lastNameController,
          label: 'Last Name',
          icon: Icons.person_outline,
        ),
        _buildTextField(
          controller: widget.formController.nicknameController,
          label: 'Nickname',
          icon: Icons.alternate_email,
        ),
        _buildBirthdayField(),
        _buildTextField(
          controller: widget.formController.educationCenterController,
          label: 'Educational Center',
          icon: Icons.school,
        ),
        _buildTextField(
          controller: widget.formController.countryController,
          label: 'Country',
          icon: Icons.public,
        ),
        _buildGenderDropdown(),
      ],
    );
  }
}