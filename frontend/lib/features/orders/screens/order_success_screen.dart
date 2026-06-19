import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_nhat_truong/features/shop/screens/main_page.dart';

class OrderSuccessScreen extends StatelessWidget {
  final bool isYellow;

  const OrderSuccessScreen({super.key, required this.isYellow});

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.of(context).size.width / 375).clamp(0.5, 1.5);
    final size = MediaQuery.of(context).size;

    // Make status bar icons dark (visible on yellow/white bg)
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    if (isYellow) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFC107),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background image covering the whole screen to make it seamless
            Image.asset(
              'assets/images/success_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment
                  .bottomCenter, // Keeps the tablet at the bottom visible
            ),

            // Foreground content
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: size.height *
                          0.12), // Align text section higher to match mockup

                  // "Success!" Title
                  Text(
                    'Success!',
                    style: GoogleFonts.outfit(
                      fontSize: 34 * scale,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF222222),
                      height: 1.1,
                    ),
                  ),

                  SizedBox(height: 12 * scale),

                  // Subtitle
                  Text(
                    'Your order will be delivered soon.\nThank you for choosing our app!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14 * scale,
                      color: const Color(0xFF222222),
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  SizedBox(height: 16 * scale),

                  // Continue Shopping Button
                  SizedBox(
                    height: 36 * scale,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const MainPage()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDB3022),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18 * scale),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 28 * scale),
                        elevation: 4,
                        shadowColor: const Color(0xFFDB3022).withValues(alpha: 0.25),
                      ),
                      child: Text(
                        'Continue shopping',
                        style: GoogleFonts.inter(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // White success screen
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Custom Bags Illustration
                Center(
                  child: ShoppingBagsIllustration(scale: scale),
                ),

                const Spacer(flex: 1),

                // "Success!" Title
                Text(
                  'Success!',
                  style: GoogleFonts.outfit(
                    fontSize: 34 * scale,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF222222),
                  ),
                ),

                SizedBox(height: 16 * scale),

                // Subtitle
                Text(
                  'Your order will be delivered soon.\nThank you for choosing our app!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14 * scale,
                    color: const Color(0xFF222222),
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const Spacer(flex: 2),

                // CONTINUE SHOPPING Button
                SizedBox(
                  width: double.infinity,
                  height: 48 * scale,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MainPage()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDB3022),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24 * scale),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0xFFDB3022).withValues(alpha: 0.35),
                    ),
                    child: Text(
                      'CONTINUE SHOPPING',
                      style: GoogleFonts.inter(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24 * scale),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class ShoppingBagsIllustration extends StatelessWidget {
  final double scale;
  const ShoppingBagsIllustration({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200 * scale,
      height: 200 * scale,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Confetti background particles
          // Red curved accent line left
          Positioned(
            left: 20 * scale,
            top: 60 * scale,
            child: Transform.rotate(
              angle: -0.4,
              child: Container(
                width: 2 * scale,
                height: 10 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFFDB3022),
                  borderRadius: BorderRadius.circular(1 * scale),
                ),
              ),
            ),
          ),
          // Yellow line top right
          Positioned(
            right: 40 * scale,
            top: 40 * scale,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                width: 2 * scale,
                height: 12 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFBA49),
                  borderRadius: BorderRadius.circular(1 * scale),
                ),
              ),
            ),
          ),
          // Blue confetti curve top left
          Positioned(
            left: 50 * scale,
            top: 30 * scale,
            child: Container(
              width: 6 * scale,
              height: 6 * scale,
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A8A),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Black hollow circle left
          Positioned(
            left: 35 * scale,
            bottom: 75 * scale,
            child: Container(
              width: 8 * scale,
              height: 8 * scale,
              decoration: BoxDecoration(
                border: Border.all(
                    color: const Color(0xFF222222), width: 1.5 * scale),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Black hollow circle top right
          Positioned(
            right: 50 * scale,
            top: 25 * scale,
            child: Container(
              width: 6 * scale,
              height: 6 * scale,
              decoration: BoxDecoration(
                border: Border.all(
                    color: const Color(0xFF222222), width: 1.2 * scale),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Tilted yellow shopping bag (behind, tilted left)
          Positioned(
            left: 35 * scale,
            top: 45 * scale,
            child: Transform.rotate(
              angle: -0.22,
              child: Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  // Handle
                  Positioned(
                    top: -12 * scale,
                    child: Container(
                      width: 30 * scale,
                      height: 24 * scale,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFF222222), width: 2.2 * scale),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15 * scale),
                          topRight: Radius.circular(15 * scale),
                        ),
                      ),
                    ),
                  ),
                  // Bag body
                  Container(
                    width: 76 * scale,
                    height: 84 * scale,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107), // Yellow
                      borderRadius: BorderRadius.circular(4 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8 * scale,
                          offset: Offset(0, 4 * scale),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tilted red shopping bag (front, tilted right)
          Positioned(
            right: 30 * scale,
            bottom: 30 * scale,
            child: Transform.rotate(
              angle: 0.15,
              child: Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  // Handle
                  Positioned(
                    top: -14 * scale,
                    child: Container(
                      width: 36 * scale,
                      height: 28 * scale,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFFE08E79), width: 2.2 * scale),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18 * scale),
                          topRight: Radius.circular(18 * scale),
                        ),
                      ),
                    ),
                  ),
                  // Bag body
                  Container(
                    width: 86 * scale,
                    height: 108 * scale,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDB3022), // Red
                      borderRadius: BorderRadius.circular(6 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 12 * scale,
                          offset: Offset(0, 6 * scale),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // More confetti pieces in front
          // Red curve right
          Positioned(
            right: 20 * scale,
            bottom: 70 * scale,
            child: Container(
              width: 5 * scale,
              height: 5 * scale,
              decoration: const BoxDecoration(
                color: Color(0xFFDB3022),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Green piece bottom left
          Positioned(
            left: 60 * scale,
            bottom: 35 * scale,
            child: Container(
              width: 6 * scale,
              height: 6 * scale,
              decoration: const BoxDecoration(
                color: Color(0xFF2AA95C),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Orange piece top center
          Positioned(
            left: 100 * scale,
            top: 25 * scale,
            child: Container(
              width: 5 * scale,
              height: 5 * scale,
              decoration: const BoxDecoration(
                color: Color(0xFFFFBA49),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
