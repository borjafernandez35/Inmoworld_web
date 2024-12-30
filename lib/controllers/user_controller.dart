import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inmoworld_web/services/user.dart';
import 'package:inmoworld_web/controllers/user_model_controller.dart';


class UserController extends GetxController {
  final UserService userService = UserService();
  final UserModelController userModelController = Get.find();

  // Google Sign-In Service
 

  // Controladores de texto para la UI
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Variables reactivas para la UI
  var isLoading = false.obs;
  var errorMessage = ''.obs;


  // Lógica para Iniciar Sesión
  void logIn() async {
    // Validar entradas
    if (!_validateInputs()) return;

    // Estado inicial
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Datos para login
      final logInData = {
        'email': emailController.text,
        'password': passwordController.text,
      };

      // Llamada al servicio
      final statusCode = await userService.logIn(logInData);

      if (statusCode == 201) {
        // Manejo exitoso
        Get.snackbar('Éxito', 'Inicio de sesión exitoso',
            snackPosition: SnackPosition.BOTTOM);
        Get.toNamed('/home');
      } else if (statusCode == 400) {
        _showError('Credenciales incorrectas. Verifica e intenta nuevamente.');
      } else if (statusCode == 500) {
        _showError('Error interno del servidor. Intenta más tarde.');
      } else {
        _showError('Error desconocido. Contacta soporte.');
      }
    } catch (e) {
      _showError('No se pudo conectar con la API. Intenta nuevamente.');
      print('Error en logIn: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Validar Entradas
  bool _validateInputs() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showError('Por favor llena todos los campos.');
      return false;
    }
    if (!GetUtils.isEmail(emailController.text)) {
      _showError('Correo electrónico no válido.');
      return false;
    }
    return true;
  }

  // Mostrar Error
  void _showError(String message) {
    errorMessage.value = message;
    Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
  }

  // Limpiar Controladores en el Desmontaje
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
