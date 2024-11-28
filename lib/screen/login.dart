import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inmoworld_web/controllers/userController.dart';

class LogInScreen extends StatelessWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.put(UserController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Campo de Correo Electrónico
            _buildTextField(
              controller: userController.emailController,
              label: 'Correo Electrónico',
              obscureText: false,
            ),

            // Campo de Contraseña
            _buildTextField(
              controller: userController.passwordController,
              label: 'Contraseña',
              obscureText: true,
            ),

            const SizedBox(height: 16),

            // Botón de Iniciar Sesión o Indicador de Carga
            Obx(() => userController.isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: userController.logIn,
                    child: const Text('Iniciar Sesión'),
                  )),

            const SizedBox(height: 8),

            // Mostrar mensaje de error si existe
            Obx(() => userController.errorMessage.isNotEmpty
                ? Text(
                    userController.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  )
                : const SizedBox()),

            const SizedBox(height: 16),

            // Botón para Navegar a Registrarse
            ElevatedButton(
              onPressed: () => Get.toNamed('/register'),
              child: const Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Reutilizable para Campos de Texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      obscureText: obscureText,
    );
  }
}