import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

class AppLocalization {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'pokedex': 'Pokedex',
      'login': 'Login',
      'email': 'Email',
      'password': 'Password',
      'logout': 'Logout',
      'retry': 'Retry',
      'login_failed': 'Login Failed',
      'height': 'Height',
      'weight': 'Weight',
      'not_found': 'Pokemon not found',
    },
    'es': {
      'pokedex': 'Pokedex',
      'login': 'Iniciar Sesión',
      'email': 'Correo electrónico',
      'password': 'Contraseña',
      'logout': 'Cerrar sesión',
      'retry': 'Reintentar',
      'login_failed': 'Error de inicio de sesión',
      'height': 'Altura',
      'weight': 'Peso',
      'not_found': 'Pokemon no encontrado',
    },
  };

  static String getString(Locale locale, String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}
