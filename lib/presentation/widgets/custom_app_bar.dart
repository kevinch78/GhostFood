import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/presentation/widgets/auth_gate.dart';
import 'package:ghost_food/presentation/widgets/edit_profile_form.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum _MenuOptions { editProfile, logout }

const double _appBarHeight = 70.0; // Nueva altura personalizada

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: _appBarHeight,
      automaticallyImplyLeading: false, // Para tener control total
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Get.back(),
            )
          : null,
      backgroundColor: Colors.transparent, // Hacemos el fondo transparente
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
          ),
        ),
      ),
      title: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFF00FFB8)],
        ).createShader(bounds),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900, // Un poco más grueso para que destaque
            color: Colors.white, // El color base sobre el que actúa el gradiente
          ),
        ),
      ),
      actions: [
        ...?actions, // Incluye acciones adicionales si se proporcionan
        PopupMenuButton<_MenuOptions>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: const Color(0xFF2D2D2D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            switch (value) {
              case _MenuOptions.editProfile:
                _showEditProfileSheet(context);
                break;
              case _MenuOptions.logout:
                _signOut();
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            _buildPopupMenuItem(
              text: 'Editar Perfil',
              icon: Icons.person_outline,
              value: _MenuOptions.editProfile,
            ),
            _buildPopupMenuItem(
              text: 'Cerrar Sesión',
              icon: Icons.logout,
              value: _MenuOptions.logout,
              isDestructive: true,
            ),
          ],
        ),
      ],
    );
  }

  void _showEditProfileSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        // Aquí usamos el formulario que ya creamos
        child: const EditProfileForm(),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    // Limpiamos la pila de navegación y vamos al AuthGate para re-evaluar.
    // Usamos noTransition para evitar el "flash" blanco al cambiar de pantalla.
    Get.offAll(() => const AuthGate(), transition: Transition.noTransition);
  }

  PopupMenuItem<_MenuOptions> _buildPopupMenuItem({
    required String text,
    required IconData icon,
    required _MenuOptions value,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.redAccent : Colors.white;
    return PopupMenuItem<_MenuOptions>(
      value: value,
      child: Row(children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(color: color)),
      ]),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(_appBarHeight);
}