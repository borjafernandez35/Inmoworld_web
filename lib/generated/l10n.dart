// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Google sign in`
  String get GoogleSignIn {
    return Intl.message(
      'Google sign in',
      name: 'GoogleSignIn',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get LogIn {
    return Intl.message(
      'Sign In',
      name: 'LogIn',
      desc: '',
      args: [],
    );
  }

  /// `Don't have account?`
  String get NoTienesCuenta {
    return Intl.message(
      'Don\'t have account?',
      name: 'NoTienesCuenta',
      desc: '',
      args: [],
    );
  }

  /// `Sign up`
  String get Registrarse {
    return Intl.message(
      'Sign up',
      name: 'Registrarse',
      desc: '',
      args: [],
    );
  }

  /// `Users`
  String get Usuarios {
    return Intl.message(
      'Users',
      name: 'Usuarios',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get Usuario {
    return Intl.message(
      'User',
      name: 'Usuario',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get Contrasena {
    return Intl.message(
      'Password',
      name: 'Contrasena',
      desc: '',
      args: [],
    );
  }

  /// `Rewrite Password`
  String get ReescribeContrasena {
    return Intl.message(
      'Rewrite Password',
      name: 'ReescribeContrasena',
      desc: '',
      args: [],
    );
  }

  /// `Valid Password`
  String get ContrasenaValida {
    return Intl.message(
      'Valid Password',
      name: 'ContrasenaValida',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Password`
  String get ContrasenaNoValida {
    return Intl.message(
      'Invalid Password',
      name: 'ContrasenaNoValida',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get CorreoElectronico {
    return Intl.message(
      'Email',
      name: 'CorreoElectronico',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get Perfil {
    return Intl.message(
      'Profile',
      name: 'Perfil',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get Home {
    return Intl.message(
      'Home',
      name: 'Home',
      desc: '',
      args: [],
    );
  }

  /// `Map`
  String get Mapa {
    return Intl.message(
      'Map',
      name: 'Mapa',
      desc: '',
      args: [],
    );
  }

  /// `No Messages`
  String get SinMensajes {
    return Intl.message(
      'No Messages',
      name: 'SinMensajes',
      desc: '',
      args: [],
    );
  }

  /// `Error loading data`
  String get ErrorLoadingData {
    return Intl.message(
      'Error loading data',
      name: 'ErrorLoadingData',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load more data`
  String get FailedToLoadMoreData {
    return Intl.message(
      'Failed to load more data',
      name: 'FailedToLoadMoreData',
      desc: '',
      args: [],
    );
  }

  /// `Return`
  String get Volver {
    return Intl.message(
      'Return',
      name: 'Volver',
      desc: '',
      args: [],
    );
  }

  /// `Select your birthday`
  String get SeleccionaTuCumpleanos {
    return Intl.message(
      'Select your birthday',
      name: 'SeleccionaTuCumpleanos',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get Success {
    return Intl.message(
      'Success',
      name: 'Success',
      desc: '',
      args: [],
    );
  }

  /// `Login Successful`
  String get LoginSuccessful {
    return Intl.message(
      'Login Successful',
      name: 'LoginSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `'Incorrect credentials. Please try again.`
  String get IncorrectCredentials {
    return Intl.message(
      '\'Incorrect credentials. Please try again.',
      name: 'IncorrectCredentials',
      desc: '',
      args: [],
    );
  }

  /// `Server error. Please try later`
  String get ServerError {
    return Intl.message(
      'Server error. Please try later',
      name: 'ServerError',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get Close {
    return Intl.message(
      'Close',
      name: 'Close',
      desc: '',
      args: [],
    );
  }

  /// `Birthday`
  String get Birthday {
    return Intl.message(
      'Birthday',
      name: 'Birthday',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get Name {
    return Intl.message(
      'Name',
      name: 'Name',
      desc: '',
      args: [],
    );
  }

  /// `User Profile`
  String get PerfilUsuario {
    return Intl.message(
      'User Profile',
      name: 'PerfilUsuario',
      desc: '',
      args: [],
    );
  }

  /// `Property Map`
  String get MapaPropiedades {
    return Intl.message(
      'Property Map',
      name: 'MapaPropiedades',
      desc: '',
      args: [],
    );
  }

  /// `Price {property}`
  String PrecioPropiedad(Object property) {
    return Intl.message(
      'Price $property',
      name: 'PrecioPropiedad',
      desc: '',
      args: [property],
    );
  }

  /// `Add Property`
  String get AnadirPropiedad {
    return Intl.message(
      'Add Property',
      name: 'AnadirPropiedad',
      desc: '',
      args: [],
    );
  }

  /// `Up to {distance}`
  String Hasta(Object distance) {
    return Intl.message(
      'Up to $distance',
      name: 'Hasta',
      desc: '',
      args: [distance],
    );
  }

  /// `Selected distance is not valid`
  String get DistanciaNoValida {
    return Intl.message(
      'Selected distance is not valid',
      name: 'DistanciaNoValida',
      desc: '',
      args: [],
    );
  }

  /// `Make new property`
  String get NuevaPropiedad {
    return Intl.message(
      'Make new property',
      name: 'NuevaPropiedad',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get Descripcion {
    return Intl.message(
      'Description',
      name: 'Descripcion',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get Price {
    return Intl.message(
      'Price',
      name: 'Price',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get Guardar {
    return Intl.message(
      'Save',
      name: 'Guardar',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get Cancelar {
    return Intl.message(
      'Cancel',
      name: 'Cancelar',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get English {
    return Intl.message(
      'English',
      name: 'English',
      desc: '',
      args: [],
    );
  }

  /// `Catalan`
  String get Catalan {
    return Intl.message(
      'Catalan',
      name: 'Catalan',
      desc: '',
      args: [],
    );
  }

  /// `Romanian`
  String get Rumanno {
    return Intl.message(
      'Romanian',
      name: 'Rumanno',
      desc: '',
      args: [],
    );
  }

  /// `Spanish`
  String get Espanol {
    return Intl.message(
      'Spanish',
      name: 'Espanol',
      desc: '',
      args: [],
    );
  }

  /// `assets/us.png`
  String get flag {
    return Intl.message(
      'assets/us.png',
      name: 'flag',
      desc: '',
      args: [],
    );
  }

  /// `EN`
  String get EN {
    return Intl.message(
      'EN',
      name: 'EN',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ca', countryCode: 'CA'),
      Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
      Locale.fromSubtags(languageCode: 'ro', countryCode: 'RO'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
