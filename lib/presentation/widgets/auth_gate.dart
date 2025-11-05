import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/domain/entities/profile_entity.dart';
import 'package:ghost_food/presentation/controllers/session_controller.dart';
import 'package:ghost_food/presentation/pages/create_profile_page.dart';
import 'package:ghost_food/presentation/pages/client_home_page.dart';
import 'package:ghost_food/presentation/pages/creator_home_page.dart';
import 'package:ghost_food/presentation/pages/cook_home_page.dart';
import 'package:ghost_food/presentation/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/**
 * AUTH GATE - This will continuosly listen for auth state changes
 * ---
 * unauthenticated --> Login page
 * authenticated --> Profile page 
 * authenticated && no profile --> Create Profile Page
 * authenticated && profile exists --> Role-specific Home Page
 */

class AuthGate extends StatelessWidget{
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      //Listen to Auth state changes
      stream: Supabase.instance.client.auth.onAuthStateChange,
      //Build appropiate page based on auth state
      builder: (context, snapshot){
        //Loading
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Scaffold(
            backgroundColor: Color(0xFF0D0D0D),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF00FFB8)),
            ),
          );
        }
        //check if there is a valid session currently
        final session = snapshot.hasData ? snapshot.data!.session : null;
        if(session != null){
          // --- LÓGICA REFACTORIZADA CON SESSION CONTROLLER ---
          final sessionController = Get.find<SessionController>();
          
          // Usamos un FutureBuilder para asegurarnos de que el perfil se cargue una vez.
          return FutureBuilder(
            future: sessionController.loadUserProfile(),
            builder: (context, loadSnapshot) {
              // Mientras carga el perfil por primera vez, mostramos un spinner.
              if (loadSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Color(0xFF0D0D0D),
                  body: Center(child: CircularProgressIndicator(color: Color(0xFF00FFB8))),
                );
              }

              // Una vez cargado, observamos el perfil en el controlador.
              return Obx(() {
                final profile = sessionController.userProfile.value;
                if (profile == null) {
                  return const CreateProfilePage();
                } else {
                  switch (profile.role) {
                    case UserRole.cliente: return const ClientHomePage();
                    case UserRole.cocinero: return const CookHomePage();
                    case UserRole.creador: return const CreatorHomePage();
                  }
                }
              });
            },
          );
        }else{
          return const LoginPage();
        }
      }
    );
  }
}
