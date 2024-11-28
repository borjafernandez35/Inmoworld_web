import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  String? _id;
  String _name;
  String _email;
  String _password;
  //String _comment;
  bool _isAdmin;

  // Constructor
   UserModel({
    required String name,
    required String email,
    required String password,
    //required String comment,
    bool isAdmin = false,
    String? id,
  })  : _id = id,
        _name = name,
        _email = email,
        _password = password,
       // _comment = comment,
        _isAdmin = isAdmin;

  // Getters
  String? get id => _id;
  String get name => _name;
  String get email => _email;
  String get password => _password;
 // String get comment => _comment;
  bool get isAdmin => _isAdmin;

  // Método para actualizar el usuario
  void setUser(String name, String email, String password,bool isAdmin,
      {String? id}) {
    _id = id;
    _name = name;
    _email = email;
    _password = password;
    //_comment = comment;
    _isAdmin=isAdmin;
    notifyListeners();
  }

  // Método fromJson para crear una instancia de UserModel desde un Map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString(), // Convertir a String si es int
      name: json['name']?.toString() ?? 'Usuario desconocido',
      email: json['email']?.toString() ?? 'No especificado',
      password: json['password']?.toString() ?? 'Sin contraseña',
      //comment: json['comment']?.toString() ?? 'Sin comentarios',
      isAdmin: json['isAdmin'] ?? false, // Manejar el campo isAdmin
    );
  }

  // Método toJson para convertir una instancia de UserModel en un Map
  Map<String, dynamic> toJson() {
    return {
      '_id': _id,
      'name': _name,
      'email': _email,
      'password': _password,
     // 'comment': _comment,
      'isAdmin': _isAdmin,
    };
  }
}
