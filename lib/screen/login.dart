import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inmoworld_web/controllers/user_controller.dart';

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
            // Logo de la aplicación
            Image.asset(
              'assets/logo.png', // Ruta del logo
              height: 200, // Altura fija del logo
              width: 200, // Anchura fija del logo
            ),
            const SizedBox(height: 20),
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

            const SizedBox(height: 16),


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
                        onPressed: () => Get.toNamed('/login'),
                        child: const Text('Volver'),
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
