import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:le_nhat_truong/features/shop/screens/crop_item_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PHOTO SEARCH SCREEN — "Search by taking a photo"
// ─────────────────────────────────────────────────────────────────────────────
class PhotoSearchScreen extends StatefulWidget {
  const PhotoSearchScreen({super.key});

  @override
  State<PhotoSearchScreen> createState() => _PhotoSearchScreenState();
}

class _PhotoSearchScreenState extends State<PhotoSearchScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  bool _flashOn = false;
  bool _isCapturing = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      if (photo != null && mounted) {
        final Uint8List bytes = await photo.readAsBytes();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CropItemScreen(imageBytes: bytes),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Simulated camera viewfinder ──────────────────────────────
          Container(color: Colors.black),

          // Subtle vignette overlay
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [Colors.transparent, Color(0x66000000)],
              ),
            ),
          ),

          // Blue left edge indicator (like in the design)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xFF2196F3),
                    Color(0xFF2196F3),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.2, 0.8, 1.0],
                ),
              ),
            ),
          ),

          // ── Viewfinder guide lines ────────────────────────────────────
          Center(
            child: CustomPaint(
              size: const Size(double.infinity, double.infinity),
              painter: _ViewfinderPainter(),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── AppBar ─────────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Search by taking a photo',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Camera placeholder hint
                const Spacer(),
                Text(
                  'Point your camera at an outfit',
                  style: GoogleFonts.inter(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Bottom controls ────────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 36),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Flash button
                      _ControlButton(
                        icon: _flashOn
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        size: 28,
                        onTap: () => setState(() => _flashOn = !_flashOn),
                        active: _flashOn,
                      ),

                      // Capture button
                      GestureDetector(
                        onTap: _capturePhoto,
                        child: AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (_, child) => Transform.scale(
                            scale: _isCapturing ? 0.92 : _pulseAnim.value,
                            child: child,
                          ),
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDB3022),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFDB3022)
                                      .withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: _isCapturing
                                ? const Center(
                                    child: SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                          ),
                        ),
                      ),

                      // Flip camera button
                      _ControlButton(
                        icon: Icons.flip_camera_ios_rounded,
                        size: 28,
                        onTap: () {
                          // flip camera — handled by OS picker
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small control button ────────────────────────────────────────────────────
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;
  final bool active;

  const _ControlButton({
    required this.icon,
    required this.size,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withOpacity(0.25)
              : Colors.white.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            color: active ? Colors.yellow : Colors.white, size: size),
      ),
    );
  }
}

// ── Viewfinder corner painter ───────────────────────────────────────────────
class _ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double margin = 60;
    const double cornerLen = 24;
    final rect = Rect.fromLTRB(
      margin,
      size.height * 0.15,
      size.width - margin,
      size.height * 0.82,
    );

    // Top-left
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(cornerLen, 0), paint);
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(0, cornerLen), paint);
    // Top-right
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(-cornerLen, 0), paint);
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(0, cornerLen), paint);
    // Bottom-left
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(cornerLen, 0), paint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(0, -cornerLen), paint);
    // Bottom-right
    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(-cornerLen, 0), paint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(0, -cornerLen), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
