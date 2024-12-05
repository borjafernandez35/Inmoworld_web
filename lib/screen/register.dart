import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inmoworld_web/controllers/registerController.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterController registerController = Get.put(RegisterController());

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
            ),
             _buildTextField(
              controller: registerController.password2Controller,
              label: 'Contraseña',
              obscureText: true,
            ), 
            const SizedBox(height: 16),

            // Botón de registro o indicador de carga
            Obx(() {
              return registerController.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: registerController.signUp,
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
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      obscureText: obscureText,
    );
  }
}