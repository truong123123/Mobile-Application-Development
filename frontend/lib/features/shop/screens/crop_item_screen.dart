import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CROP ITEM SCREEN — "Crop the item"
// Works on Web, Android, iOS, Windows (uses Image.memory instead of Image.file)
// ─────────────────────────────────────────────────────────────────────────────
class CropItemScreen extends StatefulWidget {
  final Uint8List imageBytes;

  const CropItemScreen({super.key, required this.imageBytes});

  @override
  State<CropItemScreen> createState() => _CropItemScreenState();
}

class _CropItemScreenState extends State<CropItemScreen>
    with SingleTickerProviderStateMixin {
  // Crop rectangle in relative coords (0.0 – 1.0)
  double _cropLeft   = 0.08;
  double _cropTop    = 0.05;
  double _cropRight  = 0.92;
  double _cropBottom = 0.60;

  bool _isSearching = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onSearch() async {
    setState(() => _isSearching = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isSearching = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Searching for similar outfits...',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFDB3022),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              // ── AppBar ────────────────────────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Color(0xFF222222), size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Crop the item',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF222222),
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // ── Image + crop overlay ──────────────────────────────────
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;

                    return GestureDetector(
                      onPanUpdate: (details) {
                        final dx = details.delta.dx / w;
                        final dy = details.delta.dy / h;
                        final cropW = _cropRight - _cropLeft;
                        final cropH = _cropBottom - _cropTop;

                        setState(() {
                          _cropLeft   = (_cropLeft + dx).clamp(0.0, 1.0 - cropW);
                          _cropRight  = _cropLeft + cropW;
                          _cropTop    = (_cropTop + dy).clamp(0.0, 1.0 - cropH);
                          _cropBottom = _cropTop + cropH;
                        });
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // ── Full image — works on web & native ────────
                          Image.memory(
                            widget.imageBytes,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),

                          // ── Dark overlay with crop window cutout ──────
                          CustomPaint(
                            painter: _CropOverlayPainter(
                              cropLeft:   _cropLeft,
                              cropTop:    _cropTop,
                              cropRight:  _cropRight,
                              cropBottom: _cropBottom,
                            ),
                          ),

                          // ── Drag hint ─────────────────────────────────
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Drag to move selection',
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ── Bottom bar with Search button ─────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Center(
                  child: GestureDetector(
                    onTap: _isSearching ? null : _onSearch,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _isSearching
                            ? const Color(0xFFB83822)
                            : const Color(0xFFDB3022),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFDB3022).withValues(alpha: 0.4),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: _isSearching
                          ? const Center(
                              child: SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.search_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Crop overlay painter
// ─────────────────────────────────────────────────────────────────────────────
class _CropOverlayPainter extends CustomPainter {
  final double cropLeft;
  final double cropTop;
  final double cropRight;
  final double cropBottom;

  const _CropOverlayPainter({
    required this.cropLeft,
    required this.cropTop,
    required this.cropRight,
    required this.cropBottom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(
      cropLeft   * size.width,
      cropTop    * size.height,
      cropRight  * size.width,
      cropBottom * size.height,
    );

    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, rect.top), overlayPaint);
    canvas.drawRect(Rect.fromLTRB(0, rect.top, rect.left, rect.bottom), overlayPaint);
    canvas.drawRect(Rect.fromLTRB(rect.right, rect.top, size.width, rect.bottom), overlayPaint);
    canvas.drawRect(Rect.fromLTRB(0, rect.bottom, size.width, size.height), overlayPaint);

    const cornerLen = 22.0;
    final bracketPaint = Paint()
      ..color       = Colors.white
      ..strokeWidth = 2.5
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.square;

    canvas.drawLine(rect.topLeft,     rect.topLeft     + const Offset(cornerLen, 0),  bracketPaint);
    canvas.drawLine(rect.topLeft,     rect.topLeft     + const Offset(0, cornerLen),  bracketPaint);
    canvas.drawLine(rect.topRight,    rect.topRight    + const Offset(-cornerLen, 0), bracketPaint);
    canvas.drawLine(rect.topRight,    rect.topRight    + const Offset(0, cornerLen),  bracketPaint);
    canvas.drawLine(rect.bottomLeft,  rect.bottomLeft  + const Offset(cornerLen, 0),  bracketPaint);
    canvas.drawLine(rect.bottomLeft,  rect.bottomLeft  + const Offset(0, -cornerLen), bracketPaint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(-cornerLen, 0), bracketPaint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(0, -cornerLen), bracketPaint);

    final crossPaint = Paint()
      ..color       = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(rect.left, rect.center.dy), Offset(rect.right, rect.center.dy), crossPaint);
    canvas.drawLine(Offset(rect.center.dx, rect.top),  Offset(rect.center.dx, rect.bottom), crossPaint);
  }

  @override
  bool shouldRepaint(_CropOverlayPainter old) =>
      old.cropLeft != cropLeft || old.cropTop != cropTop ||
      old.cropRight != cropRight || old.cropBottom != cropBottom;
}
