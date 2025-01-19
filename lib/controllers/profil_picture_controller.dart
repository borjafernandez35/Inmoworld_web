import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';


class ProfilePictureController extends GetxController {
  final RxBool isUploading = false.obs;
  String? uploadedPicture;


  // Seleccionar la imagen del perfil
  Future<void> selectAndUploadProfileImage() async {
    print("Iniciando selección de imagen...");
    final imageBytes = await pickImageForWeb();
    if (imageBytes != null) {
      print("Imagen seleccionada...");
      isUploading.value = true;
      final pictureUrl = await uploadImageToCloudinary(imageBytes);
      if (pictureUrl != null) {
        uploadedPicture = pictureUrl;
        print("Imagen subida con éxito, URL: $uploadedPicture");
        // Aquí deberías guardar la URL de la imagen en tu base de datos, utilizando el método correspondiente
        // Ejemplo: await userController.updateProfilePicture(pictureUrl);
      } else {
        print("Error al subir la imagen.");
      }
      isUploading.value = false;
    } else {
      print("No se seleccionó ninguna imagen.");
    }
  }

  // Seleccionar imagen desde el explorador de archivos del navegador
  Future<Uint8List?> pickImageForWeb() async {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();
    await uploadInput.onChange.first;
    final file = uploadInput.files?.first;
    if (file == null) {
      print("No se seleccionó ningún archivo.");
      return null;
    }
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    print("Archivo leído correctamente.");
    return reader.result as Uint8List;
  }

  // Subir la imagen a Cloudinary
  Future<String?> uploadImageToCloudinary(Uint8List imageBytes) async {
    const String cloudName = 'dlbj2oozx';
    const String uploadPreset = 'InmoWorld';
    const String url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: 'profile_image.jpg',
    ));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        print("Respuesta de Cloudinary: $jsonResponse");
        return jsonResponse['secure_url'];
      } else {
        print("Error al subir la imagen, código de estado: ${response.statusCode}");
      }
    } catch (e) {
      print("Error al subir la imagen: $e");
    }
    return null;
  }
}

