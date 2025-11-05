import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/presentation/controllers/session_controller.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false, // Por defecto, no mostramos el botón.
  });

  @override
  Widget build(BuildContext context) {
    final sessionController = Get.find<SessionController>();

    return AppBar(
      backgroundColor: const Color(0xFF0A1612),
      elevation: 0,
      automaticallyImplyLeading: false, // Lo manejamos manualmente.
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Get.back(),
              tooltip: 'Volver',
            )
          : null,
      titleSpacing: showBackButton ? 0 : 20,
      title: Row(
        children: [
          // Logo pequeño
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFAA).withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Image.asset('assets/imgs/logo2.png', fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          // Título y Subtítulo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                // Usamos Obx para que el texto se actualice cuando el perfil esté disponible
                Obx(() {
                  final profile = sessionController.userProfile.value;
                  return Text(
                    // Mostramos el nombre del usuario, o su rol si no tiene nombre.
                    profile?.fullName ?? profile?.role.name.capitalizeFirst ?? 'Bienvenido',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}