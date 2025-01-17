// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(distance) => "Up to ${distance}";

  static String m1(property) => "Price ${property}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "AnadirPropiedad": MessageLookupByLibrary.simpleMessage("Add Property"),
        "Birthday": MessageLookupByLibrary.simpleMessage("Birthday"),
        "Cancelar": MessageLookupByLibrary.simpleMessage("Cancel"),
        "Catalan": MessageLookupByLibrary.simpleMessage("Catalan"),
        "Close": MessageLookupByLibrary.simpleMessage("Close"),
        "Contrasena": MessageLookupByLibrary.simpleMessage("Password"),
        "ContrasenaNoValida":
            MessageLookupByLibrary.simpleMessage("Invalid Password"),
        "ContrasenaValida":
            MessageLookupByLibrary.simpleMessage("Valid Password"),
        "CorreoElectronico": MessageLookupByLibrary.simpleMessage("Email"),
        "Descripcion": MessageLookupByLibrary.simpleMessage("Description"),
        "DistanciaNoValida": MessageLookupByLibrary.simpleMessage(
            "Selected distance is not valid"),
        "EN": MessageLookupByLibrary.simpleMessage("EN"),
        "English": MessageLookupByLibrary.simpleMessage("English"),
        "ErrorLoadingData":
            MessageLookupByLibrary.simpleMessage("Error loading data"),
        "Espanol": MessageLookupByLibrary.simpleMessage("Spanish"),
        "FailedToLoadMoreData":
            MessageLookupByLibrary.simpleMessage("Failed to load more data"),
        "GoogleSignIn": MessageLookupByLibrary.simpleMessage("Google sign in"),
        "Guardar": MessageLookupByLibrary.simpleMessage("Save"),
        "Hasta": m0,
        "Home": MessageLookupByLibrary.simpleMessage("Home"),
        "IncorrectCredentials": MessageLookupByLibrary.simpleMessage(
            "\'Incorrect credentials. Please try again."),
        "LogIn": MessageLookupByLibrary.simpleMessage("Sign In"),
        "LoginSuccessful":
            MessageLookupByLibrary.simpleMessage("Login Successful"),
        "Mapa": MessageLookupByLibrary.simpleMessage("Map"),
        "MapaPropiedades": MessageLookupByLibrary.simpleMessage("Property Map"),
        "Name": MessageLookupByLibrary.simpleMessage("Name"),
        "NoTienesCuenta":
            MessageLookupByLibrary.simpleMessage("Don\'t have account?"),
        "NuevaPropiedad":
            MessageLookupByLibrary.simpleMessage("Make new property"),
        "Perfil": MessageLookupByLibrary.simpleMessage("Profile"),
        "PerfilUsuario": MessageLookupByLibrary.simpleMessage("User Profile"),
        "PrecioPropiedad": m1,
        "Price": MessageLookupByLibrary.simpleMessage("Price"),
        "ReescribeContrasena":
            MessageLookupByLibrary.simpleMessage("Rewrite Password"),
        "Registrarse": MessageLookupByLibrary.simpleMessage("Sign up"),
        "Rumanno": MessageLookupByLibrary.simpleMessage("Romanian"),
        "SeleccionaTuCumpleanos":
            MessageLookupByLibrary.simpleMessage("Select your birthday"),
        "ServerError": MessageLookupByLibrary.simpleMessage(
            "Server error. Please try later"),
        "SinMensajes": MessageLookupByLibrary.simpleMessage("No Messages"),
        "Success": MessageLookupByLibrary.simpleMessage("Success"),
        "Usuario": MessageLookupByLibrary.simpleMessage("User"),
        "Usuarios": MessageLookupByLibrary.simpleMessage("Users"),
        "Volver": MessageLookupByLibrary.simpleMessage("Return"),
        "flag": MessageLookupByLibrary.simpleMessage("assets/us.png")
      };
}
