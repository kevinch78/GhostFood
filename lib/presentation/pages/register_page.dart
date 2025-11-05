import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/auth/auth_service.dart';
import 'package:ghost_food/presentation/widgets/animated_flame_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ghost_food/presentation/widgets/shared_widgets.dart'; // Importamos los widgets compartidos
import 'package:ghost_food/utils/error_handler.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final _authService = Get.find<AuthService>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // 1. Añadimos una clave para el Form
  bool _isLoading = false;
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  late AnimationController _fadeController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _glowController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void signUp() async {
    if (_isLoading) return;

    // 2. Usamos la clave para validar todos los campos a la vez
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      try {
        await _authService.signUpWithEmailAndPassword(email, password);
        
        if (mounted) {
          // Al registrarse exitosamente, Supabase ya crea una sesión.
          // Simplemente cerramos la pantalla de registro. El AuthGate, que está
          // escuchando los cambios de autenticación, detectará la nueva sesión
          // y redirigirá automáticamente a la CreateProfilePage.
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          showAuthErrorSnackBar(context, e);
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1612),
              Color(0xFF0D0D0D),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  final fadeValue = Curves.easeOut.transform(_fadeController.value);
                  return Opacity(
                    opacity: fadeValue,
                    child: Form( // 4. Envolvemos la columna en un widget Form
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 40),

                          // Botón de retroceso
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white70,
                                size: 24,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Logo con efecto de brillo
                          AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) {
                              return Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00FFAA).withOpacity(
                                        0.3 + (_glowController.value * 0.3),
                                      ),
                                      blurRadius: 60 + (_glowController.value * 30),
                                      spreadRadius: 10 + (_glowController.value * 15),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/imgs/logo2.png',
                                  fit: BoxFit.contain,
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 30),

                          // Título
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFFFFFFFF),
                                Color(0xFF00FFB8),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: Text(
                              'Crear Cuenta',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Subtítulo
                          Text(
                            '¡Únete a la experiencia GhostFood!',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 15,
                              height: 1.4,
                              letterSpacing: 0.3,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 40),

                          // Campo de correo
                          AppTextFormField( // Usamos el widget compartido
                            controller: _emailController,
                            hintText: "Correo electrónico",
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor ingresa tu correo';
                              }
                              // Opcional: validación de formato de email
                              if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                                return 'Por favor ingresa un correo válido';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Campo de contraseña
                          AppTextFormField( // Usamos el widget compartido
                            controller: _passwordController,
                            hintText: "Contraseña",
                            icon: Icons.lock_outline,
                            obscureText: _isPasswordObscured,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa una contraseña';
                              }
                              if (value.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white54,
                                size: 22,
                              ),
                              onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Campo de confirmar contraseña
                          AppTextFormField( // Usamos el widget compartido
                            controller: _confirmPasswordController,
                            hintText: "Confirmar contraseña",
                            icon: Icons.lock_outline,
                            obscureText: _isConfirmPasswordObscured,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor confirma tu contraseña';
                              }
                              if (value != _passwordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordObscured ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white54,
                                size: 22,
                              ),
                              onPressed: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Botón de registro
                          AnimatedFlameButton(
                            text: 'Registrarse',
                            onTap: signUp,
                            isLoading: _isLoading,
                            width: double.infinity,
                            height: 60,
                          ),

                          const SizedBox(height: 30),

                          // Divisor "O regístrate con"
                          Text(
                            'O regístrate con',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Botones de redes sociales
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SocialAuthButton( // Usamos el widget compartido
                                icon: FontAwesomeIcons.facebookF,
                                color: const Color(0xFF1877F2),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Registro con Facebook - En desarrollo"),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 32),
                              SocialAuthButton( // Usamos el widget compartido
                                icon: FontAwesomeIcons.google,
                                color: const Color(0xFFDB4437),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Registro con Google - En desarrollo"),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),

                          // Enlace a login
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                children: const [
                                  TextSpan(text: "¿Ya tienes una cuenta? "),
                                  TextSpan(
                                    text: "Inicia sesión",
                                    style: TextStyle(
                                      color: Color(0xFF00FFB8),
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}