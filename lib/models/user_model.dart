import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  String? _id;
  String _name;
  String _email;
  String _password;
  String _birthday;
  bool _isAdmin;

  // Nuevas propiedades
  String? _lastMessage;
  DateTime? _lastMessageTime;

  // Constructor actualizado
  UserModel({
    required String name,
    required String email,
    required String password,
    required String birthday,
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
        _lastMessageTime = lastMessageTime;

  // Getters
  String? get id => _id;
  String get name => _name;
  String get email => _email;
  String get password => _password;
  String get birthday => _birthday;
  bool get isAdmin => _isAdmin;
  String? get lastMessage => _lastMessage;
  DateTime? get lastMessageTime => _lastMessageTime;

  // Setters para actualizar las nuevas propiedades (opcional)
  set lastMessage(String? message) {
    _lastMessage = message;
    notifyListeners();
  }

  set lastMessageTime(DateTime? time) {
    _lastMessageTime = time;
    notifyListeners();
  }

  // Método para actualizar el usuario completo
  void setUser({
    String? id,
    required String name,
    required String email,
    required String password,
    required String birthday,
    required bool isAdmin,
    String? lastMessage,
    DateTime? lastMessageTime,
  }) {
    _id = id;
    _name = name;
    _email = email;
    _password = password;
    _birthday = birthday;
    _isAdmin = isAdmin;
    _lastMessage = lastMessage;
    _lastMessageTime = lastMessageTime;
    notifyListeners();
  }

  // Método copyWith para crear copias modificadas
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? birthday,
    bool? isAdmin,
    String? lastMessage,
    DateTime? lastMessageTime,
  }) {
    return UserModel(
      id: id ?? this._id,
      name: name ?? this._name,
      email: email ?? this._email,
      password: password ?? this._password,
      birthday: birthday ?? this._birthday,
      isAdmin: isAdmin ?? this._isAdmin,
      lastMessage: lastMessage ?? this._lastMessage,
      lastMessageTime: lastMessageTime ?? this._lastMessageTime,
    );
  }

  // Método fromJson para incluir los nuevos campos
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString(),
      name: json['name']?.toString() ?? 'Usuario desconocido',
      email: json['email']?.toString() ?? 'No especificado',
      password: json['password']?.toString() ?? 'Sin contraseña',
      birthday: json['birthday']?.toString() ?? 'Sin edad',
      isAdmin: json['isAdmin'] ?? false,
      lastMessage: json['lastMessage']?.toString(),
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : null,
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
      'lastMessage': _lastMessage,
      'lastMessageTime': _lastMessageTime?.toIso8601String(),
    };
  }
}