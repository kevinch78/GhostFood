import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:ghost_food/presentation/widgets/animated_flame_button.dart';
import 'package:ghost_food/presentation/widgets/auth_gate.dart';

class GhostFoodSplash extends StatefulWidget {
  const GhostFoodSplash({super.key});

  @override
  State<GhostFoodSplash> createState() => _GhostFoodSplashState();
}

class _GhostFoodSplashState extends State<GhostFoodSplash>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _glowController;
  late AnimationController _floatController;
  late AnimationController _flameController;
  late AnimationController _scaleController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _flameController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _glowController.dispose();
    _floatController.dispose();
    _flameController.dispose();
    _scaleController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _navigateToAuthGate() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthGate(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          // Gradiente más vibrante y dinámico
          final color1 = Color.lerp(
            const Color(0xFF0A1612),
            const Color(0xFF1A3A2E),
            _bgController.value,
          )!;
          final color2 = Color.lerp(
            const Color(0xFF1C3A2E),
            const Color(0xFF2D5F4A),
            _bgController.value,
          )!;
          final color3 = Color.lerp(
            const Color(0xFF0D2318),
            const Color(0xFF1A3D2E),
            _bgController.value,
          )!;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color1, color2, color3],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Partículas flotantes de fondo
                ...List.generate(15, (index) {
                  return AnimatedBuilder(
                    animation: _particleController,
                    builder: (context, child) {
                      final offset = (_particleController.value + index / 15) % 1.0;
                      final screenHeight = MediaQuery.of(context).size.height;
                      final screenWidth = MediaQuery.of(context).size.width;
                      
                      return Positioned(
                        left: (index * 50.0) % screenWidth,
                        top: screenHeight * offset,
                        child: Opacity(
                          opacity: 0.1 + (0.2 * math.sin(offset * math.pi)),
                          child: Container(
                            width: 4 + (index % 3) * 2,
                            height: 4 + (index % 3) * 2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index % 2 == 0
                                  ? const Color(0xFF00FFAA)
                                  : const Color(0xFFFFA726),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),

                // Contenido principal
                SafeArea(
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _scaleController,
                      curve: Curves.elasticOut,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: 40),

                        // Logo con múltiples efectos
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _floatController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    5 * math.sin(_floatController.value * math.pi),
                                    -12 * _floatController.value,
                                  ),
                                  child: Transform.rotate(
                                    angle: 0.05 * math.sin(_floatController.value * math.pi),
                                    child: AnimatedBuilder(
                                      animation: _glowController,
                                      builder: (context, child) {
                                        return Container(
                                          width: 500,
                                          height: 500,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF00FFAA)
                                                    .withOpacity(
                                                  0.4 + (_glowController.value * 0.4),
                                                ),
                                                blurRadius:
                                                    80 + (_glowController.value * 50),
                                                spreadRadius:
                                                    15 + (_glowController.value * 25),
                                              ),
                                              BoxShadow(
                                                color: const Color(0xFFFFA726)
                                                    .withOpacity(0.2),
                                                blurRadius: 60,
                                                spreadRadius: 10,
                                              ),
                                            ],
                                          ),
                                          child: child,
                                        );
                                      },
                                      child: Image.asset(
                                        'assets/imgs/logo2.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Sección de texto mejorada
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Título con efecto más llamativo
                              Stack(
                                children: [
                                  // Sombra del texto
                                  ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [
                                        Color(0xFFFFA726),
                                        Color(0xFFFF7043),
                                        Color(0xFF00FFAA),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                    child: Text(
                                      'GhostFood',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 62,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 3,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.5),
                                            blurRadius: 20,
                                            offset: const Offset(0, 4),
                                          ),
                                          const Shadow(
                                            color: Color(0xFF00FFAA),
                                            blurRadius: 30,
                                            offset: Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Slogan principal
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                child: Column(
                                  children: [
                                    Text(
                                      'Un mundo de sabores en un solo lugar',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white.withOpacity(0.95),
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
                                        letterSpacing: 0.5,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Explora, elige y disfruta lo que se te antoje',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white.withOpacity(0.7),
                                        fontStyle: FontStyle.italic,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Botón mejorado con efectos
                        Padding(
                          padding: const EdgeInsets.only(bottom: 60),
                          child: AnimatedFlameButton(
                            text: 'Empezar',
                            onTap: _navigateToAuthGate,
                            icon: Icons.local_fire_department,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}