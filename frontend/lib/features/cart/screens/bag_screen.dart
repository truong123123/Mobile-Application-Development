import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:le_nhat_truong/features/cart/providers/cart_provider.dart';
import 'package:le_nhat_truong/features/favorites/providers/favorites_provider.dart';
import 'package:le_nhat_truong/core/constants/constants.dart';
import 'package:le_nhat_truong/features/orders/screens/checkout_screen.dart';

class BagScreen extends StatefulWidget {
  const BagScreen({super.key});

  @override
  State<BagScreen> createState() => _BagScreenState();
}

class _BagScreenState extends State<BagScreen> {
  final TextEditingController _promoController = TextEditingController();

  final List<PromoCode> _availablePromos = [
    PromoCode(
      code: 'mypromocode2020',
      title: 'Personal offer',
      discountPercent: 10,
      discountLabel: '10%\noff',
      daysRemaining: 6,
    ),
    PromoCode(
      code: 'summer2020',
      title: 'Summer Sale',
      discountPercent: 15,
      discountLabel: '15%\noff',
      daysRemaining: 23,
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=200&fit=crop',
    ),
    PromoCode(
      code: 'mypromocode2022',
      title: 'Personal offer',
      discountPercent: 22,
      discountLabel: '22%\noff',
      daysRemaining: 6,
    ),
  ];

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _showPromoCodesBottomSheet(
      BuildContext context, double scale, CartProvider cartProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF9F9F9),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: EdgeInsets.only(
            left: 16 * scale,
            right: 16 * scale,
            top: 8 * scale,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24 * scale,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 60 * scale,
                    height: 6 * scale,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC4C4C4),
                      borderRadius: BorderRadius.circular(3 * scale),
                    ),
                  ),
                ),
                SizedBox(height: 24 * scale),

                // Promo input inside bottom sheet
                Container(
                  height: 48 * scale,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8 * scale),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4 * scale,
                        offset: Offset(0, 2 * scale),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _promoController,
                          decoration: InputDecoration(
                            hintText: 'Enter your promo code',
                            hintStyle: GoogleFonts.inter(
                              color: const Color(0xFF9B9B9B),
                              fontSize: 14 * scale,
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16 * scale),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          final code = _promoController.text.trim();
                          if (code.isNotEmpty) {
                            final matched = _availablePromos.firstWhere(
                              (p) => p.code.toLowerCase() == code.toLowerCase(),
                              orElse: () => PromoCode(
                                code: code,
                                title: 'Promo Offer',
                                discountPercent: 5,
                                discountLabel: '5%\noff',
                                daysRemaining: 1,
                              ),
                            );
                            cartProvider.applyPromoCode(matched);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Applied promo code: ${matched.code} (-${matched.discountPercent.round()}%)'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 36 * scale,
                          height: 36 * scale,
                          margin: EdgeInsets.only(right: 6 * scale),
                          decoration: const BoxDecoration(
                            color: Color(0xFF222222),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24 * scale),

                // Title
                Text(
                  'Your Promo Codes',
                  style: GoogleFonts.outfit(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF222222),
                  ),
                ),
                SizedBox(height: 16 * scale),

                // Promo Codes List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _availablePromos.length,
                  separatorBuilder: (_, __) => SizedBox(height: 16 * scale),
                  itemBuilder: (ctx, index) {
                    final promo = _availablePromos[index];
                    final isApplied =
                        cartProvider.activePromoCode?.code == promo.code;
                    return Container(
                      height: 80 * scale,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8 * scale,
                            offset: Offset(0, 2 * scale),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Left promo section (image or solid color)
                          ClipRRect(
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(8 * scale)),
                            child: SizedBox(
                              width: 80 * scale,
                              height: 80 * scale,
                              child: promo.imageUrl != null
                                  ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          promo.imageUrl!,
                                          fit: BoxFit.cover,
                                        ),
                                        Container(
                                          color: Colors.black.withValues(alpha: 0.4),
                                        ),
                                        Center(
                                          child: Text(
                                            promo.discountLabel,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.outfit(
                                              fontSize: 18 * scale,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              height: 1.1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(
                                      color: promo.discountPercent >= 20
                                          ? const Color(0xFF222222)
                                          : const Color(0xFFDB3022),
                                      child: Center(
                                        child: Text(
                                          promo.discountLabel,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.outfit(
                                            fontSize: 18 * scale,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            height: 1.1,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),

                          // Middle text section
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14 * scale, vertical: 10 * scale),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        promo.title,
                                        style: GoogleFonts.outfit(
                                          fontSize: 14 * scale,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF222222),
                                        ),
                                      ),
                                      Text(
                                        promo.code,
                                        style: GoogleFonts.inter(
                                          fontSize: 11 * scale,
                                          color: const Color(0xFF222222),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${promo.daysRemaining} days remaining',
                                    style: GoogleFonts.inter(
                                      fontSize: 11 * scale,
                                      color: const Color(0xFF9B9B9B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Right Apply Button
                          Padding(
                            padding: EdgeInsets.only(right: 14 * scale),
                            child: SizedBox(
                              width: 76 * scale,
                              height: 32 * scale,
                              child: ElevatedButton(
                                onPressed: isApplied
                                    ? () {
                                        cartProvider.removePromoCode();
                                        Navigator.pop(ctx);
                                      }
                                    : () {
                                        cartProvider.applyPromoCode(promo);
                                        _promoController.text = promo.code;
                                        Navigator.pop(ctx);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isApplied
                                      ? Colors.grey
                                      : const Color(0xFFDB3022),
                                  elevation: 0,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(16 * scale),
                                  ),
                                ),
                                child: Text(
                                  isApplied ? 'Applied' : 'Apply',
                                  style: GoogleFonts.inter(
                                    fontSize: 12 * scale,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
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
                SizedBox(height: 16 * scale),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.of(context).size.width / 375).clamp(0.5, 1.5);
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items;

    if (cartProvider.activePromoCode != null &&
        _promoController.text != cartProvider.activePromoCode!.code) {
      _promoController.text = cartProvider.activePromoCode!.code;
    } else if (cartProvider.activePromoCode == null) {
      _promoController.clear();
    }

    return Container(
      color: const Color(0xFFF9F9F9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Search Icon
            Padding(
              padding: EdgeInsets.only(right: 12 * scale),
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.search,
                      size: 26 * scale, color: const Color(0xFF222222)),
                  onPressed: () {},
                ),
              ),
            ),

            // Title "My Bag"
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale),
              child: Text(
                'My Bag',
                style: GoogleFonts.outfit(
                  fontSize: 34 * scale,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF222222),
                  height: 1.1,
                ),
              ),
            ),
            SizedBox(height: 20 * scale),

            // Bag items
            Expanded(
              child: cartItems.isEmpty
                  ? _buildEmptyState(scale)
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                      itemCount: cartItems.length,
                      separatorBuilder: (_, __) => SizedBox(height: 24 * scale),
                      itemBuilder: (ctx, index) {
                        final item = cartItems[index];
                        final product = item.product;
                        final String imageUrl = product.imageUrl != null
                            ? (product.imageUrl!.startsWith('http')
                                ? product.imageUrl!
                                : '${AppConstants.baseUrl}${product.imageUrl}')
                            : '';
                        return Container(
                          constraints: BoxConstraints(minHeight: 115 * scale),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8 * scale),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8 * scale,
                                offset: Offset(0, 2 * scale),
                              ),
                            ],
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Product Image
                                ClipRRect(
                                  borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(8 * scale)),
                                  child: SizedBox(
                                    width: 115 * scale,
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            alignment: Alignment.center,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                              color: const Color(0xFFE0E0E0),
                                              child: const Icon(Icons.image,
                                                  color: Colors.grey),
                                            ),
                                          )
                                        : Container(
                                            color: const Color(0xFFE0E0E0),
                                            child: const Icon(Icons.image,
                                                color: Colors.grey),
                                          ),
                                  ),
                                ),

                                // Product Info
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12 * scale,
                                      vertical: 6 * scale,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // Product Name
                                                Expanded(
                                                  child: Text(
                                                    product.productName,
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 16 * scale,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: const Color(
                                                          0xFF222222),
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                // Three-dot menu button
                                                PopupMenuButton<String>(
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(
                                                    minWidth: 32 * scale,
                                                    minHeight: 32 * scale,
                                                  ),
                                                  icon: Icon(
                                                    Icons.more_vert,
                                                    color:
                                                        const Color(0xFF9B9B9B),
                                                    size: 20 * scale,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8 * scale),
                                                  ),
                                                  color: Colors.white,
                                                  elevation: 4,
                                                  offset:
                                                      Offset(-10 * scale, 0),
                                                  onSelected: (value) {
                                                    if (value == 'favorites') {
                                                      final favProvider = Provider
                                                          .of<FavoritesProvider>(
                                                              context,
                                                              listen: false);
                                                      favProvider.addFavorite(
                                                        item.product,
                                                        item.selectedSize,
                                                        item.selectedColor,
                                                      );
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Added to favorites'),
                                                          backgroundColor:
                                                              Colors.green,
                                                        ),
                                                      );
                                                    } else if (value ==
                                                        'delete') {
                                                      cartProvider.removeItem(
                                                        item.product.id,
                                                        item.selectedSize,
                                                        item.selectedColor,
                                                      );
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'Removed ${item.product.productName} from bag'),
                                                          backgroundColor:
                                                              Colors.green,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  itemBuilder: (context) => [
                                                    PopupMenuItem<String>(
                                                      value: 'favorites',
                                                      height: 36 * scale,
                                                      child: Center(
                                                        child: Text(
                                                          'Add to favorites',
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize:
                                                                11 * scale,
                                                            color: const Color(
                                                                0xFF222222),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const PopupMenuDivider(
                                                        height: 1),
                                                    PopupMenuItem<String>(
                                                      value: 'delete',
                                                      height: 36 * scale,
                                                      child: Center(
                                                        child: Text(
                                                          'Delete from the list',
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize:
                                                                11 * scale,
                                                            color: const Color(
                                                                0xFF222222),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            // Color & Size Subtitle
                                            SizedBox(height: 2 * scale),
                                            Row(
                                              children: [
                                                Text(
                                                  'Color: ',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 11 * scale,
                                                    color:
                                                        const Color(0xFF9B9B9B),
                                                  ),
                                                ),
                                                Text(
                                                  item.selectedColor,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 11 * scale,
                                                    color:
                                                        const Color(0xFF222222),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(width: 12 * scale),
                                                Text(
                                                  'Size: ',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 11 * scale,
                                                    color:
                                                        const Color(0xFF9B9B9B),
                                                  ),
                                                ),
                                                Text(
                                                  item.selectedSize,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 11 * scale,
                                                    color:
                                                        const Color(0xFF222222),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        // Quantity row & Price
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                // Minus Button
                                                _buildQtyButton(
                                                  icon: Icons.remove,
                                                  onTap: () => cartProvider
                                                      .decrementQuantity(
                                                    product.id,
                                                    item.selectedSize,
                                                    item.selectedColor,
                                                  ),
                                                  scale: scale,
                                                ),
                                                SizedBox(width: 8 * scale),
                                                // Quantity value
                                                Text(
                                                  '${item.quantity}',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14 * scale,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        const Color(0xFF222222),
                                                  ),
                                                ),
                                                SizedBox(width: 8 * scale),
                                                // Plus Button
                                                _buildQtyButton(
                                                  icon: Icons.add,
                                                  onTap: () => cartProvider
                                                      .incrementQuantity(
                                                    product.id,
                                                    item.selectedSize,
                                                    item.selectedColor,
                                                  ),
                                                  scale: scale,
                                                ),
                                              ],
                                            ),
                                            // Price
                                            Text(
                                              '${(product.salePrice * item.quantity).round()}\$',
                                              style: GoogleFonts.inter(
                                                fontSize: 14 * scale,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF222222),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Bottom checkout & promo code bar
            if (cartItems.isNotEmpty)
              Container(
                padding: EdgeInsets.fromLTRB(
                    16 * scale, 16 * scale, 16 * scale, 24 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10 * scale,
                      offset: Offset(0, -5 * scale),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Promo code input trigger
                    GestureDetector(
                      onTap: () => _showPromoCodesBottomSheet(
                          context, scale, cartProvider),
                      child: Container(
                        height: 48 * scale,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8 * scale),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4 * scale,
                              offset: Offset(0, 2 * scale),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: AbsorbPointer(
                                child: TextField(
                                  controller: _promoController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your promo code',
                                    hintStyle: GoogleFonts.inter(
                                      color: const Color(0xFF9B9B9B),
                                      fontSize: 14 * scale,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16 * scale),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 36 * scale,
                              height: 36 * scale,
                              margin: EdgeInsets.only(right: 6 * scale),
                              decoration: const BoxDecoration(
                                color: Color(0xFF222222),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_forward,
                                  color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24 * scale),

                    // Total amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total amount:',
                          style: GoogleFonts.inter(
                            fontSize: 14 * scale,
                            color: const Color(0xFF9B9B9B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${cartProvider.finalAmount.round()}\$',
                          style: GoogleFonts.outfit(
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF222222),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24 * scale),

                    // CHECK OUT Button
                    SizedBox(
                      width: double.infinity,
                      height: 48 * scale,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CheckoutScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDB3022),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24 * scale),
                          ),
                          elevation: 4,
                          shadowColor:
                              const Color(0xFFDB3022).withValues(alpha: 0.35),
                        ),
                        child: Text(
                          'CHECK OUT',
                          style: GoogleFonts.inter(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
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
  }

  Widget _buildEmptyState(double scale) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 80 * scale, color: const Color(0xFFE0E0E0)),
          SizedBox(height: 16 * scale),
          Text(
            'Your bag is empty',
            style: GoogleFonts.outfit(
              fontSize: 22 * scale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF222222),
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            'Add items to your shopping bag to check out.',
            style: GoogleFonts.inter(
              fontSize: 14 * scale,
              color: const Color(0xFF9B9B9B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onTap,
    required double scale,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32 * scale,
        height: 32 * scale,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4 * scale,
              offset: Offset(0, 2 * scale),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 16 * scale,
          color: const Color(0xFF9B9B9B),
        ),
      ),
    );
  }
}
