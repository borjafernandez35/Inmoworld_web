import 'package:flutter/material.dart';
import 'package:inmoworld_web/generated/l10n.dart';
import 'package:get/get.dart';
import 'package:inmoworld_web/controllers/register_controller.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterController registerController = Get.put(RegisterController());

    final GlobalKey<FlutterPwValidatorState> validatorKey =
        GlobalKey<FlutterPwValidatorState>();

    return Scaffold(
      appBar: AppBar(title: Text(S.current.Registrarse)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
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

                      // Campos de texto reutilizables
                      _buildTextField(
                        controller: registerController.nameController,
                        label: S.current.Usuario,
                      ),
                      _buildTextField(
                        controller: registerController.mailController,
                        label: S.current.CorreoElectronico,
                      ),
                      // Campo de cumpleaños
                      _buildBirthdayField(registerController, context),

                      _buildTextField(
                        controller: registerController.passwordController,
                        label: S.current.Contrasena,
                        obscureText: true,
                        onChanged: (value) {
                          // Actualiza el validador en tiempo real
                          validatorKey.currentState?.validate();
                        },
                      ),
                      _buildTextField(
                        controller: registerController.password2Controller,
                        label: S.current.ReescribeContrasena,
                        obscureText: true,
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
                        normalCharCount: 1,
                        width: 300,
                        height: 150,
                        successColor:
                            Colors.green, // Color cuando la regla es válida
                        failureColor:
                            Colors.red, // Color cuando la regla no es válida
                        onSuccess: () {
                          print(S.current.ContrasenaValida);
                          registerController.isPasswordValid.value =
                              true; // Habilita el botón
                          print('El valor es....${registerController.isPasswordValid.value}');
                        },
                        onFail: () {
                          print(S.current.ContrasenaNoValida);
                          registerController.isPasswordValid.value =
                              false; // Deshabilita el botón
                        },
                      ),
                      const SizedBox(height: 8),

                      // Botón de registro o indicador de carga
                      Obx(() {
                        return ElevatedButton(
                          onPressed: registerController.isPasswordValid.value
                              ? registerController.signUp
                              : null, // Solo habilitado si las reglas están cumplidas
                          child: Text(S.current.Registrarse),
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

                      const SizedBox(height: 8),

                      // Botón para volver al login
                      ElevatedButton(
                        onPressed: () => Get.toNamed('/logearse'),
                        child: Text(S.current.Volver),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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

  Widget _buildBirthdayField(
      RegisterController controller, BuildContext context) {
    return Obx(() {
      return InkWell(
        onTap: () => controller.selectDate(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.birthday.value.isNotEmpty
                    ? controller.birthday.value
                    : S.current.SeleccionaTuCumpleanos,
                style: TextStyle(
                  color: controller.birthday.value.isNotEmpty
                      ? Colors.black
                      : Colors.grey,
                ),
              ),
              const Icon(Icons.calendar_today, color: Colors.grey),
            ],
          ),
        ),
      );
    });
  }
}
