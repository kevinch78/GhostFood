import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';

class AnimatedFlameButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading;
  final IconData? icon;
  final double width;
  final double height;

  const AnimatedFlameButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
    this.icon,
    this.width = 260,
    this.height = 68,
  });

  @override
  State<AnimatedFlameButton> createState() => _AnimatedFlameButtonState();
}

class _AnimatedFlameButtonState extends State<AnimatedFlameButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _flameController;

  @override
  void initState() {
    super.initState();
    _flameController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _flameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _flameController,
        builder: (context, child) {
          final pulse = 0.5 + 0.5 * math.sin(_flameController.value * 2 * math.pi);

          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.height / 2),
              gradient: LinearGradient(
                colors: [
                  Color.lerp(
                    const Color(0xFFFF7043),
                    const Color(0xFFFFA726),
                    _flameController.value,
                  )!,
                  const Color(0xFFFFC107),
                  Color.lerp(
                    const Color(0xFFFFD54F),
                    const Color(0xFFFFA726),
                    _flameController.value,
                  )!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFA726).withOpacity(widget.isLoading ? 0.2 : (0.5 + 0.3 * pulse)),
                  blurRadius: widget.isLoading ? 10 : (30 + (10 * pulse)),
                  spreadRadius: widget.isLoading ? 1 : (2 + (3 * pulse)),
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFFFF7043).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(widget.height / 2),
                onTap: widget.isLoading ? null : widget.onTap,
                child: Center(
                  child: widget.isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.icon != null) ...[
                              Transform.scale(
                                scale: 1 + (0.1 * pulse),
                                child: Icon(
                                  widget.icon,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Text(
                              widget.text,
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
