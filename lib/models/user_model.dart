import 'package:flutter/material.dart'; // Importar ChangeNotifier
import 'package:inmoworld_web/services/user.dart';

class UserModel with ChangeNotifier { // Extender de ChangeNotifier
  String? _id;
  String _name;
  String _email;
  String _password;
  String _birthday;
  String? _imageUser; // Propiedad privada para la imagen
  bool _isAdmin;

  // Nuevas propiedades
  String? _lastMessage; // Último mensaje enviado o recibido
  DateTime? _lastMessageTime; // Hora del último mensaje

  // Constructor actualizado
  UserModel({
    required String name,
    required String email,
    required String password,
    required String birthday,
    String? imageUser, // Parámetro para la imagen
    bool isAdmin = false,
    String? id, 
    String? lastMessage,
    DateTime? lastMessageTime,
  })  : _id = id,
        _name = name,
        _email = email,
        _password = password,
        _birthday = birthday,
        _isAdmin = isAdmin,
        _lastMessage = lastMessage,
        _lastMessageTime = lastMessageTime,
        _imageUser = imageUser; // Inicializa la propiedad privada _imageUser

  // Getters
  String? get lastMessage => _lastMessage;
  DateTime? get lastMessageTime => _lastMessageTime;
  String? get id => _id;
  String get name => _name;
  String get email => _email;
  String get password => _password;
  String get birthday => _birthday;
  String? get imageUser => _imageUser; // Accede a la propiedad privada _imageUser
  bool get isAdmin => _isAdmin;

  // Setter para imageUser
  set imageUser(String? value) {
    _imageUser = value; // Asigna el valor a la propiedad privada
    notifyListeners(); // Notifica a los oyentes sobre el cambio
  }

  // Método para actualizar el usuario
  void setUser(String name, String email, String password, bool isAdmin,
      {String? id, String? lastMessage, DateTime? lastMessageTime, String? imageUser}) {
    _id = id;
    _name = name;
    _email = email;
    _password = password;
    _birthday = birthday;
    _isAdmin = isAdmin;
    if (imageUser != null) _imageUser = imageUser; // Actualiza la imagen de perfil solo si se pasa un valor
    _lastMessage = lastMessage;
    _lastMessageTime = lastMessageTime;
    notifyListeners();
  }

  // Método fromJson para incluir los nuevos campos
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString(), // Convertir a String si es int
      name: json['name']?.toString() ?? 'Usuario desconocido',
      email: json['email']?.toString() ?? 'No especificado',
      password: json['password']?.toString() ?? 'Sin contraseña',
      birthday: json['birthday']?.toString() ?? 'Sin edad',
      isAdmin: json['isAdmin'] ?? false, // Manejar el campo isAdmin
      lastMessage: json['lastMessage']?.toString(),
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : null,
      imageUser: json['imageUser']?.toString(), // Asegurarse de obtener la URL de la imagen si existe
    );
  }

  // Método toJson para convertir la instancia en un Map
  Map<String, dynamic> toJson() {
    return {
      '_id': _id,
      'name': _name,
      'email': _email,
      'password': _password,
      'birthday': _birthday,
      'isAdmin': _isAdmin,
      'imageUser': _imageUser, // Usar la propiedad privada _imageUser
      'lastMessage': _lastMessage,
      'lastMessageTime': _lastMessageTime?.toIso8601String(),
    };
  }
}
