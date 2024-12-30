import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inmoworld_web/services/user.dart';
import 'package:inmoworld_web/models/user_model.dart';

class RegisterController extends GetxController {
  final UserService userService = UserService();

  // Controladores de texto para la UI
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController mailController = TextEditingController();
  final TextEditingController password2Controller = TextEditingController();
  late String date;

  // Variables reactivas para la UI
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isPasswordValid = false.obs;
   var birthday = ''.obs;

   void selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      final utcDate = pickedDate.toUtc();
      String formattedDate =
          "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year.toString()}";
      birthday.value = formattedDate; // Actualiza la variable observable
      date = utcDate.toIso8601String(); // Almacena en formato ISO
    }
  }

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
        Get.toNamed('/logearse');
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

  // Validar y actualizar las sugerencias de la contraseña

  // Validar entradas
  bool _validateInputs() {
    if (nameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        mailController.text.isEmpty ||
        password2Controller.text.isEmpty) {
      _showError('Por favor llena todos los campos.');
      return false;
    }

    if (!GetUtils.isEmail(mailController.text)) {
      _showError('Correo electrónico no válido.');
      return false;
    }

    if (passwordController.text != password2Controller.text) {
      _showError('Las contraseñas no coinciden.');
      return false;
    }

    return true;
  }

  // Construir modelo de usuario desde los campos
  UserModel _buildUserModel() {
    return UserModel(
      name: nameController.text,
      password: passwordController.text,
      email: mailController.text,
      birthday: date,
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
    birthdayController.dispose();
    super.onClose();
  }
}
