import 'package:flutter/material.dart';
import 'package:skillshare/core/themes/app_theme.dart';
import 'package:skillshare/features/register/presentation/views/completion_screen.dart';
import 'package:get_it/get_it.dart';
import 'package:skillshare/features/auth/domain/entities/user_entity.dart';
import 'package:dio/dio.dart';
import 'package:skillshare/core/constants/api_constants.dart';

import '../../../auth/application/auth_service.dart';
import '../../../auth/domain/use_cases/login_use_case.dart';
import '../../../auth/domain/use_cases/register_use_case.dart';

class PersonalIdentityScreen extends StatefulWidget {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String country;
  final String educationalCenter;
  final int studentType;

  const PersonalIdentityScreen({
    super.key,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.country,
    required this.educationalCenter,
    required this.studentType,
  });

  @override
  State<PersonalIdentityScreen> createState() => _PersonalIdentityScreenState();
}

class _PersonalIdentityScreenState extends State<PersonalIdentityScreen> {
  final _nicknameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedGender;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _genders = [
    {'value': 'male', 'icon': Icons.male, 'label': 'Male'},
    {'value': 'other', 'icon': Icons.transgender, 'label': 'Other'},
    {'value': 'female', 'icon': Icons.female, 'label': 'Female'},
  ];

  String? _validateNickname(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Nickname es opcional
    }
    if (value.length < 3) {
      return 'Nickname must be at least 3 characters';
    }
    return null;
  }

  void _continue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select your gender'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1️⃣ Registrar el usuario en Auth system
      final registerUseCase = GetIt.instance<RegisterUseCase>();
      final userEntity = UserEntity(
        email: widget.email,
        password: widget.password,
      );
      final registeredUser = await registerUseCase.execute(userEntity);

      // 2️⃣ 🔥 NUEVO: Iniciar sesión automáticamente después del registro
      final loginUseCase = GetIt.instance<LoginUseCase>();
      final (loggedInUser, token) = await loginUseCase.execute(widget.email, widget.password);

      // 3️⃣ 🔥 NUEVO: Guardar datos de sesión
      if (loggedInUser.userId != null) {
        await AuthService.saveUserData(loggedInUser.userId!, loggedInUser.email, token);
        print('✅ Usuario autenticado automáticamente: userId=${loggedInUser.userId}');
      }

      // 4️⃣ Crear perfil de estudiante
      final studentData = {
        'firstName': widget.firstName,
        'lastName': widget.lastName,
        'nickname': _nicknameController.text.trim().isEmpty
            ? null
            : _nicknameController.text.trim(),
        'dateBirth': widget.dateOfBirth.toIso8601String(),
        'country': widget.country,
        'educationalCenter': widget.educationalCenter,
        'gender': _selectedGender,
        'userType': widget.studentType,
        'userId': registeredUser.userId ?? loggedInUser.userId, // Usar ID del usuario logueado
      };

      await _createStudent(studentData);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CompletionScreen(
              nickname: _nicknameController.text.trim().isEmpty
                  ? widget.firstName
                  : _nicknameController.text.trim(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createStudent(Map<String, dynamic> studentData) async {
    try {
      final dio = GetIt.instance<Dio>();

      print('🎓 Creating student with data: $studentData');

      final response = await dio.post(
        ApiConstants.studentBase,
        data: studentData,
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status! < 500,
        ),
      );

      print('✅ Student created: ${response.statusCode}');
      print('📦 Response: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(response.data['message'] ?? 'Failed to create student');
      }
    } catch (e) {
      print('💥 Error creating student: $e');
      rethrow;
    }
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
                  _buildNicknameField(),
                  const SizedBox(height: 30),
                  _buildGenderLabel(),
                  const SizedBox(height: 15),
                  _buildGenderOptions(),
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
        'assets/images/auth/fox_tablet.png',
        height: 140,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Your personal identity',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppTheme.textImportant,
        fontFamily: 'Sarabun',
      ),
    );
  }

  Widget _buildNicknameField() {
    return TextFormField(
      controller: _nicknameController,
      validator: _validateNickname,
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
        suffixIcon: Icon(
          Icons.check_circle,
          color: AppTheme.successColor,
          size: 20,
        ),
        labelText: 'Nickname',
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

  Widget _buildGenderLabel() {
    return Row(
      children: [
        Icon(Icons.favorite, color: AppTheme.iconLessImportant, size: 20),
        const SizedBox(width: 8),
        Text(
          'Gender',
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

  Widget _buildGenderOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _genders.map((gender) {
        final isSelected = _selectedGender == gender['value'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedGender = gender['value'];
            });
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                color: AppTheme.highlightedElement,
                width: 3,
              )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  gender['icon'],
                  size: 40,
                  color: isSelected
                      ? AppTheme.highlightedElement
                      : AppTheme.iconLessImportant,
                ),
                const SizedBox(height: 8),
                Text(
                  gender['label'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected
                        ? AppTheme.textImportant
                        : AppTheme.iconLessImportant,
                    fontFamily: 'Sarabun',
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _continue,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.highlightedElement,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Row(
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
    _nicknameController.dispose();
    super.dispose();
  }
}