import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inmoworld_web/controllers/registerController.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterController registerController = Get.put(RegisterController());

    final GlobalKey<FlutterPwValidatorState> validatorKey = GlobalKey<FlutterPwValidatorState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Registrarse')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Campos de texto reutilizables
            _buildTextField(
              controller: registerController.nameController,
              label: 'Usuario',
            ),
            _buildTextField(
              controller: registerController.mailController,
              label: 'Correo Electrónico',
            ),
             _buildTextField(
              controller: registerController.passwordController,
              label: 'Contraseña',
              obscureText: true,
              onChanged: (value) {
                // Actualiza el validador en tiempo real
                validatorKey.currentState?.validate();
              },
            ),

            const SizedBox(height: 8),

            // Validador de contraseña con colores personalizados
            FlutterPwValidator(
              key: validatorKey,
              controller: registerController.passwordController,
              minLength: 8,
              uppercaseCharCount: 1,
              lowercaseCharCount: 1,
              numericCharCount: 1,
              specialCharCount: 1,
              width: 300,
              height: 150,
              successColor: Colors.green, // Color cuando la regla es válida
              failureColor: Colors.red, // Color cuando la regla no es válida
              onSuccess: () {
                print("Contraseña válida");
                registerController.isPasswordValid.value = true; // Habilita el botón
              },
              onFail: () {
                print("Contraseña no válida");
                registerController.isPasswordValid.value = false; // Deshabilita el botón
              },
            ),
            const SizedBox(height: 16),
             _buildTextField(
              controller: registerController.password2Controller,
              label: 'Rewrite Password',
              obscureText: true,
            ), 
            const SizedBox(height: 16),

            // Botón de registro o indicador de carga
           Obx(() {
              return ElevatedButton(
                onPressed: registerController.isPasswordValid.value
                    ? registerController.signUp
                    : null, // Solo habilitado si las reglas están cumplidas
                child: const Text('Registrarse'),
              );
            }),

            const SizedBox(height: 8),

            // Mensaje de error si existe
            Obx(() {
              if (registerController.errorMessage.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    registerController.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              return const SizedBox();
            }),

            const SizedBox(height: 16),

            // Botón para volver al login
            ElevatedButton(
              onPressed: () => Get.toNamed('/login'),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para los campos de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      obscureText: obscureText,
      onChanged: onChanged,
    );
  }
}