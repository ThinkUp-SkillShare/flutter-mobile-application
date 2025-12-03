import 'package:flutter/material.dart';
import 'package:skillshare/core/themes/app_theme.dart';
import 'package:skillshare/features/register/presentation/views/personal_identity_screen.dart';

class AcademicWorldScreen extends StatefulWidget {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;

  const AcademicWorldScreen({
    super.key,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
  });

  @override
  State<AcademicWorldScreen> createState() => _AcademicWorldScreenState();
}

class _AcademicWorldScreenState extends State<AcademicWorldScreen> {
  final _educationalCenterController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedCountry;
  int? _selectedStudentType;

  final Map<String, String> _countries = {
    'Perú': '🇵🇪',
    'México': '🇲🇽',
    'Canada': '🇨🇦',
    'United States': '🇺🇸',
    'Spain': '🇪🇸',
    'Argentina': '🇦🇷',
    'Chile': '🇨🇱',
    'Colombia': '🇨🇴',
    'Brazil': '🇧🇷',
    'United Kingdom': '🇬🇧',
    'France': '🇫🇷',
    'Germany': '🇩🇪',
    'Italy': '🇮🇹',
    'Japan': '🇯🇵',
    'China': '🇨🇳',
    'India': '🇮🇳',
    'Australia': '🇦🇺',
  };

  final List<Map<String, dynamic>> _studentTypes = [
    {'id': 1, 'label': 'High School'},
    {'id': 2, 'label': 'University'},
    {'id': 3, 'label': 'Graduate'},
    {'id': 4, 'label': 'Self-taught'},
  ];

  String? _validateEducationalCenter(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your educational center';
    }
    return null;
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select your country'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_selectedStudentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select student type'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalIdentityScreen(
          email: widget.email,
          password: widget.password,
          firstName: widget.firstName,
          lastName: widget.lastName,
          dateOfBirth: widget.dateOfBirth,
          country: _selectedCountry!,
          educationalCenter: _educationalCenterController.text.trim(),
          studentType: _selectedStudentType!,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppTheme.textImportant),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 20),
                  _buildFoxImage(),
                  const SizedBox(height: 30),
                  _buildTitle(),
                  const SizedBox(height: 30),
                  _buildCountryField(),
                  const SizedBox(height: 20),
                  _buildEducationalCenterField(),
                  const SizedBox(height: 30),
                  _buildStudentTypeLabel(),
                  const SizedBox(height: 15),
                  _buildStudentTypeOptions(),
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
    return Center(
      child: Image.asset(
        'assets/images/auth/fox_globe.png',
        height: 140,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Your academic world',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppTheme.textImportant,
        fontFamily: 'Sarabun',
      ),
    );
  }

  Widget _buildCountryField() {
    return DropdownButtonFormField<String>(
      value: _selectedCountry,
      items: _countries.entries.map((entry) {
        return DropdownMenuItem(
          value: entry.key,
          child: Row(
            children: [
              Text(
                entry.value,
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 10),
              Text(
                entry.key,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textImportant,
                  fontFamily: 'Sarabun',
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCountry = value;
        });
      },
      style: TextStyle(
        fontSize: 16,
        color: AppTheme.textImportant,
        fontFamily: 'Sarabun',
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.public,
          color: AppTheme.iconLessImportant,
          size: 20,
        ),
        suffixIcon: _selectedCountry != null
            ? Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Text(
            _countries[_selectedCountry]!,
            style: TextStyle(fontSize: 24),
          ),
        )
            : null,
        labelText: 'Country',
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

  Widget _buildEducationalCenterField() {
    return TextFormField(
      controller: _educationalCenterController,
      validator: _validateEducationalCenter,
      style: TextStyle(
        fontSize: 16,
        color: AppTheme.textImportant,
        fontFamily: 'Sarabun',
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.school_outlined,
          color: AppTheme.iconLessImportant,
          size: 20,
        ),
        labelText: 'Educational Center',
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

  Widget _buildStudentTypeLabel() {
    return Text(
      'Select student type',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppTheme.textImportant,
        fontFamily: 'Sarabun',
      ),
    );
  }

  Widget _buildStudentTypeOptions() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: _studentTypes.map((type) {
          final isSelected = _selectedStudentType == type['id'];
          return InkWell(
            onTap: () {
              setState(() {
                _selectedStudentType = type['id'];
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                border: Border(
                  bottom: type != _studentTypes.last
                      ? BorderSide(
                    color: AppTheme.backgroundPrimary,
                    width: 1,
                  )
                      : BorderSide.none,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.school_outlined,
                    color: AppTheme.iconLessImportant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      type['label'],
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textImportant,
                        fontFamily: 'Sarabun',
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.highlightedElement,
                      size: 24,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
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
    _educationalCenterController.dispose();
    super.dispose();
  }
}