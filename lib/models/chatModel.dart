import 'package:flutter/material.dart';

class Chat {
  final String receiver;
  final String? sender;
  final String message;
  final DateTime date;

  Chat({
    required this.receiver,
    required this.sender,
    required this.message,
    required this.date,
  });

  // Método para convertir de JSON a objeto Chat
  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      receiver: json['receiver'],
      sender: json['sender'],
      message: json['message'],
      date: DateTime.parse(json['date']), // Asegúrate de que el formato de fecha sea compatible
    );
  }

  // Método para convertir de objeto Chat a JSON
  Map<String, dynamic> toJson() {
    return {
      'receiver': receiver,
      'sender': sender,
      'message': message,
      'date': date.toIso8601String(), // Asegúrate de usar este formato en el backend también
    };
  }
}
