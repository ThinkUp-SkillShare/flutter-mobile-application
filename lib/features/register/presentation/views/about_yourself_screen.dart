import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skillshare/core/themes/app_theme.dart';
import 'package:skillshare/features/register/presentation/views/academic_world_screen.dart';

class AboutYourselfScreen extends StatefulWidget {
  final String email;
  final String password;

  const AboutYourselfScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<AboutYourselfScreen> createState() => _AboutYourselfScreenState();
}

class _AboutYourselfScreenState extends State<AboutYourselfScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dayController = TextEditingController();
  final _yearController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedMonth;
  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
      return 'Only letters are allowed';
    }
    return null;
  }

  String? _validateDay(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    final day = int.tryParse(value);
    if (day == null || day < 1 || day > 31) {
      return 'Invalid day';
    }
    return null;
  }

  String? _validateYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    final year = int.tryParse(value);
    final currentYear = DateTime.now().year;
    if (year == null || year < 1900 || year > currentYear) {
      return 'Invalid year';
    }
    // Validar edad mínima de 13 años
    if (currentYear - year < 13) {
      return 'Must be 13+';
    }
    return null;
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMonth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a month'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final dateOfBirth = DateTime(
      int.parse(_yearController.text),
      _months.indexOf(_selectedMonth!) + 1,
      int.parse(_dayController.text),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AcademicWorldScreen(
          email: widget.email,
          password: widget.password,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          dateOfBirth: dateOfBirth,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: AppTheme.textImportant),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildFoxImage(),
                  const SizedBox(height: 30),
                  _buildTitle(),
                  const SizedBox(height: 30),
                  _buildFirstNameField(),
                  const SizedBox(height: 20),
                  _buildLastNameField(),
                  const SizedBox(height: 20),
                  _buildDateOfBirthLabel(),
                  const SizedBox(height: 10),
                  _buildDateOfBirthFields(),
                  const SizedBox(height: 40),
                  _buildContinueButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFoxImage() {
    return Image.asset(
      'assets/images/auth/fox_sitting.png',
      height: 140,
      fit: BoxFit.contain,
    );
  }

  Widget _buildTitle() {
    return Text(
      'Tell us a little about yourself',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppTheme.textImportant,
        fontFamily: 'Sarabun',
      ),
    );
  }

  Widget _buildFirstNameField() {
    return TextFormField(
      controller: _firstNameController,
      validator: _validateName,
      style: TextStyle(
        fontSize: 16,
        color: AppTheme.textImportant,
        fontFamily: 'Sarabun',
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.person_outline,
          color: AppTheme.iconLessImportant,
          size: 20,
        ),
        labelText: 'First name',
        labelStyle: TextStyle(
          fontSize: 16,
          color: AppTheme.iconLessImportant,
          fontFamily: 'Sarabun',
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: AppTheme.backgroundSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildLastNameField() {
    return TextFormField(
      controller: _lastNameController,
      validator: _validateName,
      style: TextStyle(
        fontSize: 16,
        color: AppTheme.textImportant,
        fontFamily: 'Sarabun',
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.person_outline,
          color: AppTheme.iconLessImportant,
          size: 20,
        ),
        labelText: 'Last name',
        labelStyle: TextStyle(
          fontSize: 16,
          color: AppTheme.iconLessImportant,
          fontFamily: 'Sarabun',
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: AppTheme.backgroundSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDateOfBirthLabel() {
    return Row(
      children: [
        Icon(Icons.calendar_today, color: AppTheme.iconLessImportant, size: 20),
        const SizedBox(width: 8),
        Text(
          'Date of birth',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textImportant,
            fontFamily: 'Sarabun',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDateOfBirthFields() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _dayController,
            keyboardType: TextInputType.number,
            validator: _validateDay,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textImportant,
              fontFamily: 'Sarabun',
            ),
            decoration: InputDecoration(
              labelText: 'Day',
              labelStyle: TextStyle(
                fontSize: 16,
                color: AppTheme.iconLessImportant,
                fontFamily: 'Sarabun',
              ),
              filled: true,
              fillColor: AppTheme.backgroundSecondary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<String>(
            value: _selectedMonth,
            items: _months.map((month) {
              return DropdownMenuItem(
                value: month,
                child: Text(month),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedMonth = value;
              });
            },
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textImportant,
              fontFamily: 'Sarabun',
            ),
            decoration: InputDecoration(
              labelText: 'Month',
              labelStyle: TextStyle(
                fontSize: 16,
                color: AppTheme.iconLessImportant,
                fontFamily: 'Sarabun',
              ),
              filled: true,
              fillColor: AppTheme.backgroundSecondary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _yearController,
            keyboardType: TextInputType.number,
            validator: _validateYear,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textImportant,
              fontFamily: 'Sarabun',
            ),
            decoration: InputDecoration(
              labelText: 'Year',
              labelStyle: TextStyle(
                fontSize: 16,
                color: AppTheme.iconLessImportant,
                fontFamily: 'Sarabun',
              ),
              filled: true,
              fillColor: AppTheme.backgroundSecondary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _continue,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.highlightedElement,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'Sarabun',
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    super.dispose();
  }
}