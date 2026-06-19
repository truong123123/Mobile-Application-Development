import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CollectionsScreen extends StatelessWidget {
  final double scale;
  const CollectionsScreen({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top half
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/banner_new_collection.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
              Positioned(
                right: 18 * scale,
                bottom: 26 * scale,
                child: Text(
                  'New collection',
                  style: GoogleFonts.outfit(
                    fontSize: 34 * scale,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bottom half
        Expanded(
          child: Row(
            children: [
              // Left column
              Expanded(
                child: Column(
                  children: [
                    // Summer sale
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        color: Colors.white,
                        padding: EdgeInsets.only(left: 16 * scale),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Summer\nsale',
                          style: GoogleFonts.outfit(
                            fontSize: 34 * scale,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFDB3022),
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                    // Black
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/images/banner_black.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                          Positioned(
                            left: 16 * scale,
                            bottom: 16 * scale,
                            child: Text(
                              'Black',
                              style: GoogleFonts.outfit(
                                fontSize: 34 * scale,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Right column
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/banner_mens_hoodies.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                    Positioned(
                      left: 16 * scale,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Text(
                          'Men’s\nhoodies',
                          style: GoogleFonts.outfit(
                            fontSize: 34 * scale,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.1,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
