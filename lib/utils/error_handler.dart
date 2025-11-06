import 'package:flutter/material.dart';

/// Muestra un SnackBar con un mensaje de error de autenticación amigable.
///
/// Traduce los errores comunes de Supabase a mensajes que el usuario puede entender.
void showAuthErrorSnackBar(BuildContext context, dynamic exception) {
  String errorMessage = "Ocurrió un error inesperado. Inténtalo de nuevo.";

  final errorString = exception.toString();

  // Errores comunes de Supabase Auth
  if (errorString.contains('Invalid login credentials')) {
    errorMessage = "Correo o contraseña incorrectos.";
  } else if (errorString.contains('User already registered')) {
    errorMessage = "Este correo electrónico ya está en uso.";
  } else if (errorString.contains('Password should be at least 6 characters')) {
    errorMessage = "La contraseña es demasiado débil.";
  } else if (errorString.contains('Unable to validate email address')) {
    errorMessage = "El formato del correo electrónico no es válido.";
  } else if (errorString.contains('Email not confirmed')) {
    errorMessage = "Por favor, confirma tu correo para poder iniciar sesión.";
  } else if (errorString.contains('For security purposes, you can only request this once every 60 seconds')) {
    errorMessage = "Demasiados intentos. Por favor, espera un minuto.";
  }
  // Aquí puedes añadir más casos para otros errores de Supabase.

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(errorMessage),
      backgroundColor: Colors.redAccent,
    ),
  );
}



