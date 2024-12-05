import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inmoworld_web/services/user.dart';
import 'package:inmoworld_web/models/userModel.dart';

class RegisterController extends GetxController {
  final UserService userService = UserService();

  // Controladores de texto para la UI
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController mailController = TextEditingController();
  final TextEditingController password2Controller = TextEditingController();

  // Variables reactivas para la UI
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Lógica de registro de usuario
  void signUp() async {
    // Validar entradas
    if (!_validateInputs()) return;

    // Cambiar estado a cargando
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Crear el modelo del usuario desde los campos
      UserModel newUser = _buildUserModel();

      // Llamar al servicio para registrar el usuario
      final statusCode = await userService.createUser(newUser);

      if (statusCode == 201) {
        // Registro exitoso
        Get.snackbar('Éxito', 'Usuario creado exitosamente',
            snackPosition: SnackPosition.BOTTOM);
        Get.toNamed('/login');
      } else if (statusCode == 400) {
        _showError('Este E-Mail o Teléfono ya están en uso');
      } else {
        _showError('Error desconocido. Intenta nuevamente.');
      }
    } catch (e) {
      _showError('Error al registrar usuario. Intenta nuevamente.');
      print('Error en signUp: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Validar entradas
  bool _validateInputs() {
    if (nameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        mailController.text.isEmpty ) {
      _showError('Por favor llena todos los campos.');
      return false;
    }
    if (!GetUtils.isEmail(mailController.text)) {
      _showError('Correo electrónico no válido.');
      return false;
    }

 if (!_isPasswordStrong(passwordController.text)) {
      _showError('La contraseña debe tener al menos 8 caracteres, una mayúscula, una minúscula, un número y un carácter especial.');
      return false;
    }

    if (passwordController.text != password2Controller.text) {
      _showError('Las contraseñas no coinciden.');
      return false;
    }

    return true;
  }

   bool _isPasswordStrong(String password) {
    // Longitud mínima
    if (password.length < 8) return false;

    // Debe contener al menos una letra mayúscula, una minúscula, un número y un carácter especial
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'\d'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasUppercase && hasLowercase && hasNumber && hasSpecialChar;
  }

  // Construir modelo de usuario desde los campos
  UserModel _buildUserModel() {
    return UserModel(
      name: nameController.text,
      password: passwordController.text,
      email: mailController.text,
    );
  }

  // Mostrar mensaje de error
  void _showError(String message) {
    errorMessage.value = message;
    Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
  }

  // Limpiar controladores al destruir el controlador
  @override
  void onClose() {
    nameController.dispose();
    passwordController.dispose();
    mailController.dispose();
    password2Controller.dispose();
    super.onClose();
  }
}