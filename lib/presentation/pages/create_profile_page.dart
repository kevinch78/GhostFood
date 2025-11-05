import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/presentation/controllers/session_controller.dart';
import 'package:ghost_food/domain/repositories/profile_repository.dart';
import 'package:ghost_food/domain/entities/profile_entity.dart';
import 'package:ghost_food/presentation/widgets/animated_flame_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ghost_food/presentation/widgets/auth_gate.dart';

class CreateProfilePage extends StatefulWidget {
  const CreateProfilePage({super.key});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final _profileRepository = Get.find<ProfileRepository>();
  final _sessionController = Get.find<SessionController>();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  UserRole? _selectedRole;
  bool _isLoading = false;

  Future<void> _createProfile() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un rol.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final userId = Supabase.instance.client.auth.currentUser!.id;

      final newProfile = ProfileEntity(
        id: userId,
        role: _selectedRole!,
        fullName: _nameController.text.trim(),
        // Aquí puedes añadir más campos según el rol
      );

      try {
        await _profileRepository.createProfile(newProfile);

        if (mounted) {
          // ¡SOLUCIÓN DEFINITIVA! Informamos al SessionController sobre el nuevo perfil.
          _sessionController.setUserProfile(newProfile);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Perfil creado con éxito!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navegamos a una nueva instancia del AuthGate.
          // Esto fuerza a la app a re-evaluar el estado del usuario. Como el
          // perfil ya existe, AuthGate lo redirigirá a la pantalla correcta. 
          // Usamos Get.offAll para asegurarnos de que toda la pila de navegación se limpie
          // y se reconstruya desde el AuthGate, forzando una re-evaluación completa.
          Get.offAll(() => const AuthGate());
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al crear el perfil: ${e.toString()}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            // Envolvemos la columna en un SingleChildScrollView para evitar el
            // overflow del teclado.
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '¡Un último paso!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Completa tu perfil para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    '¿Cómo usarás GhostFood?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RoleButton(
                        label: 'Cliente',
                        icon: Icons.shopping_cart_outlined,
                        isSelected: _selectedRole == UserRole.cliente,
                        onTap: () =>
                            setState(() => _selectedRole = UserRole.cliente),
                      ),
                      const SizedBox(width: 16),
                      _RoleButton(
                        label: 'Cocinero',
                        icon: Icons.soup_kitchen_outlined,
                        isSelected: _selectedRole == UserRole.cocinero,
                        onTap: () =>
                            setState(() => _selectedRole = UserRole.cocinero),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: _RoleButton(
                      label: 'Creador de Recetas',
                      icon: Icons.lightbulb_outline,
                      isSelected: _selectedRole == UserRole.creador,
                      onTap: () =>
                          setState(() => _selectedRole = UserRole.creador),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: 'Nombre Completo',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.5)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF00FFB8)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 3) {
                        return 'Por favor, ingresa tu nombre.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedFlameButton(
                      text: 'Guardar y Continuar',
                      onTap: _createProfile,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ) 
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleButton({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 48 - 32) / 2; // Padding y Sizedbox

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: label == 'Creador de Recetas' ? screenWidth - 48 : buttonWidth,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00FFB8) : Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? null : Border.all(color: Colors.white30),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: isSelected ? Colors.black : Colors.white),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}