import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghost_food/auth/auth_service.dart';
import 'package:ghost_food/presentation/pages/register_page.dart';
import 'package:ghost_food/presentation/widgets/animated_flame_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ghost_food/presentation/widgets/shared_widgets.dart'; // Importamos los widgets compartidos
import 'package:ghost_food/utils/error_handler.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _authService = Get.find<AuthService>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isObscured = true;

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
    super.dispose();
  }

  void login() async {
    if (_isLoading) return;

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      try {
        await _authService.signInWithEmailAndPassword(email, password);
      } catch (e) {
        if (mounted) {
          showAuthErrorSnackBar(context, e);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  final fadeValue = Curves.easeOut.transform(_fadeController.value);
                  return Opacity(
                    opacity: fadeValue,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 60),

                          // Logo con efecto de brillo
                          AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) {
                              return Container(
                                width: 200,
                                height: 200,
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

                          const SizedBox(height: 40),

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
                              'GhostFood',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 46,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Subtítulo
                          Text(
                            'Explora, elige y disfruta lo que te antoje.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 15,
                              height: 1.4,
                              letterSpacing: 0.3,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 50),

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
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Campo de contraseña
                          AppTextFormField( // Usamos el widget compartido
                            controller: _passwordController,
                            hintText: "Contraseña",
                            icon: Icons.lock_outline,
                            obscureText: _isObscured,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu contraseña';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscured ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white54,
                                size: 22,
                              ),
                              onPressed: () {
                                setState(() => _isObscured = !_isObscured);
                              },
                            ),
                          ),

                          const SizedBox(height: 50),

                          // Botón de login
                          AnimatedFlameButton(
                            text: 'Entrar',
                            onTap: login,
                            isLoading: _isLoading,
                            width: double.infinity,
                            height: 60,
                          ),

                          const SizedBox(height: 40),

                          // Divisor "O continúa con"
                          Text(
                            'O continúa con',
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
                                      content: Text("Login con Facebook - En desarrollo"),
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
                                      content: Text("Login con Google - En desarrollo"),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 50),

                          // Enlace a registro
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                children: const [
                                  TextSpan(text: "¿No tienes una cuenta? "),
                                  TextSpan(
                                    text: "Regístrate aquí",
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