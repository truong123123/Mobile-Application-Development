import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_nhat_truong/features/shop/services/product_service.dart';
import 'package:le_nhat_truong/features/shop/screens/product_detail_screen.dart';
import 'package:le_nhat_truong/core/constants/constants.dart';

class MyReviewsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final double scale;
  const MyReviewsScreen({super.key, required this.onBack, this.scale = 1.0});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  final ProductService _productService = ProductService();
  List<Map<String, dynamic>> _myReviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyReviews();
  }

  Future<void> _loadMyReviews() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final reviews = await _productService.getMyReviews();
      if (mounted) {
        setState(() {
          _myReviews = reviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('>>> Error loading my reviews: $e');
    }
  }

  Future<void> _navigateToProductDetails(String productId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFDB3022)),
      ),
    );
    try {
      final product = await _productService.getProductById(productId);
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        if (product != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không tìm thấy thông tin sản phẩm')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải sản phẩm: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    return Container(
      color: const Color(0xFFF9F9F9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // AppBar
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                  horizontal: 4 * scale, vertical: 8 * scale),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                        color: const Color(0xFF222222), size: 18 * scale),
                    onPressed: widget.onBack,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'My reviews',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF222222),
                          fontWeight: FontWeight.w700,
                          fontSize: 18 * scale,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 48 * scale), // spacer to match back button
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFDB3022),
                      ),
                    )
                  : _myReviews.isEmpty
                      ? _buildEmptyState(scale)
                      : RefreshIndicator(
                          onRefresh: _loadMyReviews,
                          color: const Color(0xFFDB3022),
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16 * scale, vertical: 16 * scale),
                            itemCount: _myReviews.length,
                            itemBuilder: (context, index) {
                              final review = _myReviews[index];
                              return _buildReviewCard(review, scale);
                            },
                          ),
                        ),
            ),
          ],
      ),
    );
  }

  Widget _buildEmptyState(double scale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined,
              size: 72 * scale, color: Colors.grey.shade300),
          SizedBox(height: 16 * scale),
          Text(
            'Chưa có đánh giá nào',
            style: GoogleFonts.outfit(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF444444),
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            'Các đánh giá của bạn sẽ xuất hiện tại đây.',
            style: GoogleFonts.inter(
              fontSize: 13 * scale,
              color: const Color(0xFF9B9B9B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review, double scale) {
    final rating = review['rating'] ?? 5;
    final date = review['date'] ?? 'Today';
    final title = review['title'] ?? '';
    final content = review['content'] ?? '';
    final photos = (review['photos'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final productName = review['productName'] ?? 'Product';
    final productImg = review['productImageUrl'] ?? '';
    final productId = review['productId'];

    final productImgUrl = (productImg.isNotEmpty)
        ? (productImg.startsWith('http')
            ? productImg
            : '${AppConstants.baseUrl}$productImg')
        : '';

    return Container(
      margin: EdgeInsets.only(bottom: 20 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewed Product Header Row (clickable)
          if (productId != null)
            InkWell(
              onTap: () => _navigateToProductDetails(productId.toString()),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10 * scale),
                topRight: Radius.circular(10 * scale),
              ),
              child: Padding(
                padding: EdgeInsets.all(12 * scale),
                child: Row(
                  children: [
                    // Product image thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6 * scale),
                      child: productImgUrl.isNotEmpty
                          ? Image.network(
                              productImgUrl,
                              width: 48 * scale,
                              height: 48 * scale,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 48 * scale,
                                height: 48 * scale,
                                color: const Color(0xFFE0E0E0),
                                child: const Icon(Icons.image, color: Colors.grey, size: 20),
                              ),
                            )
                          : Container(
                              width: 48 * scale,
                              height: 48 * scale,
                              color: const Color(0xFFE0E0E0),
                              child: const Icon(Icons.image, color: Colors.grey, size: 20),
                            ),
                    ),
                    SizedBox(width: 12 * scale),
                    // Product name and indicator
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productName,
                            style: GoogleFonts.outfit(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF222222),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2 * scale),
                          Row(
                            children: [
                              Text(
                                'View item',
                                style: GoogleFonts.inter(
                                  fontSize: 11 * scale,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFDB3022),
                                ),
                              ),
                              SizedBox(width: 2 * scale),
                              Icon(Icons.arrow_forward_ios_rounded,
                                  size: 10 * scale, color: const Color(0xFFDB3022)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const Divider(height: 1, color: Color(0xFFF1F1F1)),

          // Review Content
          Padding(
            padding: EdgeInsets.all(16 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stars & Date Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          Icons.star,
                          size: 14 * scale,
                          color: i < rating
                              ? const Color(0xFFFFBA49)
                              : const Color(0xFFE0E0E0),
                        ),
                      ),
                    ),
                    Text(
                      date,
                      style: GoogleFonts.inter(
                        fontSize: 11 * scale,
                        color: const Color(0xFF9B9B9B),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10 * scale),

                // Review Title (if present)
                if (title.isNotEmpty) ...[
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF222222),
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                ],

                // Review Text
                Text(
                  content,
                  style: GoogleFonts.inter(
                    fontSize: 13 * scale,
                    color: const Color(0xFF444444),
                    height: 1.4,
                  ),
                ),

                // Photos row (if any)
                if (photos.isNotEmpty) ...[
                  SizedBox(height: 12 * scale),
                  SizedBox(
                    height: 64 * scale,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: photos.length,
                      itemBuilder: (context, idx) {
                        final photoUrl = photos[idx];
                        return Padding(
                          padding: EdgeInsets.only(right: 8 * scale),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6 * scale),
                            child: _buildImageWidget(
                              photoUrl,
                              64 * scale,
                              64 * scale,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String path, double width, double height) {
    if (kIsWeb ||
        path.startsWith('http://') ||
        path.startsWith('https://') ||
        path.startsWith('blob:')) {
      final url = path.startsWith('http') ? path : '${AppConstants.baseUrl}$path';
      return Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildErrorImage(width, height),
      );
    } else {
      return Image.file(
        File(path),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildErrorImage(width, height),
      );
    }
  }

  Widget _buildErrorImage(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE0E0E0),
      child: const Icon(Icons.image, color: Colors.grey, size: 16),
    );
  }
}
