import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/auth/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Obtenemos la instancia de AuthService a través de GetX
  final authService = Get.find<AuthService>();
  void logout() async{
    await authService.signOutAndClean();
  }

    
  @override
  Widget build(BuildContext context) {

    //get user email
    final email = authService.getCurrentUserEmail();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          //logout
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout)
          )
        ],
      ),
      body: Center(
        child: Text("Welcome $email"),
      ),

    );
  }
}