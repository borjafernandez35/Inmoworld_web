import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudinaryUploaderWeb extends StatefulWidget {
    const CloudinaryUploaderWeb({Key? key}) : super(key: key);

  @override
  _CloudinaryUploaderWebState createState() => _CloudinaryUploaderWebState();
}

class _CloudinaryUploaderWebState extends State<CloudinaryUploaderWeb> {
  Uint8List? _selectedImage; 
  String? _uploadedImageUrl; 
  bool _isUploading = false;

  // Método para seleccionar y subir una imagen
  Future<void> selectAndUploadImage() async {
  final imageBytes = await pickImageForWeb();
  if (imageBytes != null) {
    setState(() {
      _selectedImage = imageBytes;
      _isUploading = true; // Indicamos que se está subiendo la imagen
    });

    final imageUrl = await uploadImageToCloudinary(imageBytes);
    setState(() {
      _uploadedImageUrl = imageUrl;
      _isUploading = false; // Subida completada
    });
  } else {
    setState(() {
      _isUploading = false; // Subida cancelada
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Subir Imagen en Web')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _selectedImage != null
                ? Image.memory(_selectedImage!)
                : Text('Selecciona una imagen para subir'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : selectAndUploadImage,
              child: Text(
                _isUploading
                    ? 'Subiendo...'
                    : (_uploadedImageUrl == null ? 'Seleccionar y Subir Imagen' : 'Imagen Subida'),
              ),
            ),
            SizedBox(height: 20),
            _uploadedImageUrl != null
                ? Text('Imagen subida: $_uploadedImageUrl')
                : Container(),
          ],
        ),
      ),
    );
  }

  // Método para seleccionar imagen
  Future<Uint8List?> pickImageForWeb() async {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();
    await uploadInput.onChange.first;
    final file = uploadInput.files?.first;
    if (file == null) return null;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    return reader.result as Uint8List;
  }

  // Método para subir imagen
  Future<String?> uploadImageToCloudinary(Uint8List imageBytes) async {
  final String cloudName = 'dlbj2oozx';
  final String uploadPreset = 'InmoWorld';
  final String url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  print('Subiendo imagen a $url con preset $uploadPreset');

  final request = http.MultipartRequest('POST', Uri.parse(url));
  request.fields['upload_preset'] = uploadPreset;
  request.files.add(http.MultipartFile.fromBytes(
    'file',
    imageBytes,
    filename: 'image.jpg',
  ));

  try {
    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);
      print('Imagen subida: ${jsonResponse['secure_url']}');
      return jsonResponse['secure_url'];
    } else {
      print('Error al subir imagen: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Excepción al subir imagen: $e');
    return null;
  }
}

}
