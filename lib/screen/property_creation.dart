import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inmoworld_web/services/user.dart';
import 'package:inmoworld_web/services/property.dart';

class CloudinaryUploaderWeb extends StatefulWidget {
  const CloudinaryUploaderWeb({Key? key}) : super(key: key);

  @override
  _CloudinaryUploaderWebState createState() => _CloudinaryUploaderWebState();
}

class _CloudinaryUploaderWebState extends State<CloudinaryUploaderWeb> {
  Uint8List? _selectedImage;
  String? _uploadedPicture;
  bool _isUploading = false;

  // Controladores para los campos del formulario
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  Future<void> selectAndUploadImage() async {
    final imageBytes = await pickImageForWeb();
    if (imageBytes != null) {
      setState(() {
        _selectedImage = imageBytes;
        _isUploading = true;
      });

      final picture = await uploadImageToCloudinary(imageBytes);
      setState(() {
        _uploadedPicture = picture;
        _isUploading = false;
      });
    } else {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<Uint8List?> pickImageForWeb() async {
    final html.FileUploadInputElement uploadInput =
        html.FileUploadInputElement();
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

  Future<String?> uploadImageToCloudinary(Uint8List imageBytes) async {
    final String cloudName = 'dlbj2oozx';
    final String uploadPreset = 'InmoWorld';
    final String url =
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

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
        return jsonResponse['secure_url'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> publishProperty() async {
    final description = _descriptionController.text;
    final address = _addressController.text;

   /* if (_uploadedPicture == null || description.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Por favor, llena todos los campos y sube una imagen'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      // Obtener el userId desde el UserService (suponiendo que ya tienes este método)
      final userService = UserService();
      final userId = await userService
          .getUserIdFromToken(); // Método para obtener el ID del usuario desde el token

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No se pudo obtener el ID del usuario'),
          backgroundColor: Colors.red,
        ));
        return;
      }

      // Añadir el owner (userId) a los datos de la propiedad
      final propertyData = {
        "description": description,
        "address": address,
        "picture": _uploadedPicture,
        "owner": userId, // Aquí se agrega el owner
      };

      // Llamamos a createProperty desde UserService para crear la propiedad
      //final responseCode = await PropertyService.createProperty(propertyData);

      if (responseCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Propiedad publicada exitosamente'),
          backgroundColor: Colors.green,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Propiedad publicada exitosamente'),
          backgroundColor: Color.fromARGB(255, 50, 45, 19),
        ));
        Navigator.pushNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error de red al publicar la propiedad'),
        backgroundColor: Colors.red,
      ));
    }*/
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publicar Propiedad')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recuadro de subir imagen
            Container(
              padding: const EdgeInsets.all(16),
              width: 400,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _selectedImage != null
                      ? Image.memory(_selectedImage!, height: 100)
                      : const Text(
                          'Selecciona una imagen para subir',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isUploading ? null : selectAndUploadImage,
                    child: Text(
                      _isUploading
                          ? 'Subiendo...'
                          : 'Seleccionar y Subir Imagen',
                    ),
                  ),
                  if (_uploadedPicture != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Imagen subida: $_uploadedPicture',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            // Recuadro de formulario
            Container(
              padding: const EdgeInsets.all(16),
              width: 400,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Detalles de la Propiedad',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Dirección',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: publishProperty,
                    child: const Text('Publicar Propiedad'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
