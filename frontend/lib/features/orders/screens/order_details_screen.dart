import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_nhat_truong/features/orders/screens/my_orders_screen.dart';
import 'package:le_nhat_truong/features/shop/screens/rating_reviews_screen.dart';
import 'package:le_nhat_truong/core/constants/constants.dart';
import 'package:le_nhat_truong/features/orders/services/order_service.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderItemData order;
  final VoidCallback onBack;

  const OrderDetailsScreen({
    super.key,
    required this.order,
    required this.onBack,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _isUpdating = false;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
  }

  Future<void> _markAsDelivered() async {
    setState(() {
      _isUpdating = true;
    });
    try {
      await OrderService().updateOrderStatus(widget.order.orderNo, 'Delivered');
      if (!mounted) return;
      setState(() {
        _currentStatus = 'Delivered';
        _isUpdating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cập nhật trạng thái đơn hàng thành công!',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2AA95C),
          duration: const Duration(seconds: 2),
        ),
      );
      // Wait a brief moment to show success snackbar, then return to orders list which auto-refreshes
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        widget.onBack();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUpdating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: const Color(0xFFDB3022),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.of(context).size.width / 375).clamp(0.5, 1.5);

    // Determine the status color
    Color statusColor;
    switch (_currentStatus) {
      case 'Delivered':
        statusColor = const Color(0xFF2AA95C); // Green
        break;
      case 'Processing':
        statusColor = const Color(0xFFFFBA49); // Orange
        break;
      case 'Cancelled':
        statusColor = const Color(0xFFDB3022); // Red
        break;
      default:
        statusColor = const Color(0xFF9B9B9B);
    }

    return Container(
      color: const Color(0xFFF9F9F9),
      child: Column(
        children: [
          // Custom Header Bar
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 4 * scale, vertical: 8 * scale),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: const Color(0xFF222222),
                    size: 18 * scale,
                  ),
                  onPressed: widget.onBack,
                ),
                Text(
                  'Order Details',
                  style: GoogleFonts.inter(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF222222),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: const Color(0xFF222222),
                    size: 24 * scale,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8 * scale),

                  // Order No & Date row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Order №${widget.order.orderNo}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF222222),
                          ),
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      Text(
                        widget.order.date,
                        style: GoogleFonts.inter(
                          fontSize: 14 * scale,
                          color: const Color(0xFF9B9B9B),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12 * scale),

                  // Tracking No & Status row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              'Tracking number: ',
                              style: GoogleFonts.inter(
                                fontSize: 14 * scale,
                                color: const Color(0xFF9B9B9B),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget.order.trackingNumber,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 14 * scale,
                                  color: const Color(0xFF222222),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentStatus,
                            style: GoogleFonts.inter(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                          if (_currentStatus != 'Delivered' && _currentStatus != 'Cancelled') ...[
                            SizedBox(height: 4 * scale),
                            GestureDetector(
                              onTap: _isUpdating ? null : _markAsDelivered,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8 * scale,
                                  vertical: 4 * scale,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2AA95C).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4 * scale),
                                  border: Border.all(
                                    color: const Color(0xFF2AA95C),
                                    width: 1 * scale,
                                  ),
                                ),
                                child: _isUpdating
                                    ? SizedBox(
                                        width: 12 * scale,
                                        height: 12 * scale,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          color: Color(0xFF2AA95C),
                                        ),
                                      )
                                    : Text(
                                        'Set Deli',
                                        style: GoogleFonts.inter(
                                          fontSize: 10 * scale,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF2AA95C),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20 * scale),

                  // Items Count Title
                  Text(
                    '${widget.order.items.length} item${widget.order.items.length > 1 ? 's' : ''}',
                    style: GoogleFonts.inter(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF222222),
                    ),
                  ),
                  SizedBox(height: 16 * scale),

                  // List of items
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.order.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.order.items[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 24 * scale),
                        child: _buildItemCard(item, scale),
                      );
                    },
                  ),

                  SizedBox(height: 12 * scale),

                  // Order Information Header
                  Text(
                    'Order information',
                    style: GoogleFonts.inter(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF222222),
                    ),
                  ),
                  SizedBox(height: 16 * scale),

                  // Order Details attributes (Shipping address, payment method, etc.)
                  _buildInfoRow(
                      'Shipping Address:', widget.order.shippingAddress, scale),
                  SizedBox(height: 16 * scale),
                  _buildPaymentMethodRow(scale),
                  SizedBox(height: 16 * scale),
                  _buildInfoRow(
                      'Delivery method:', widget.order.deliveryMethod, scale),
                  SizedBox(height: 16 * scale),
                  _buildInfoRow('Discount:', widget.order.discount, scale),
                  SizedBox(height: 16 * scale),
                  _buildInfoRow(
                      'Total Amount:',
                      '${widget.order.totalAmount % 1 == 0 ? widget.order.totalAmount.toInt() : widget.order.totalAmount}\$',
                      scale,
                      isTotal: true),

                  SizedBox(height: 36 * scale),

                  // Bottom Buttons (Reorder, Leave feedback)
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48 * scale,
                          child: OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Đã thêm tất cả mặt hàng vào giỏ hàng!',
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: const Color(0xFF222222),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF222222),
                              side: const BorderSide(
                                  color: Color(0xFF222222), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24 * scale),
                              ),
                            ),
                            child: Text(
                              'Reorder',
                              style: GoogleFonts.inter(
                                  fontSize: 14 * scale,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16 * scale),
                      Expanded(
                        child: SizedBox(
                          height: 48 * scale,
                          child: ElevatedButton(
                            onPressed: () {
                              if (widget.order.items.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RatingReviewsScreen(
                                      productName: widget.order.items.first.title,
                                      productId: widget.order.items.first.productId,
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDB3022),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24 * scale),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              'Leave feedback',
                              style: GoogleFonts.inter(
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32 * scale),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(OrderProductItem item, double scale) {
    final photoW = 104 * scale;
    final photoH = 104 * scale;
    final String fullImageUrl = item.imageUrl.startsWith('http')
        ? item.imageUrl
        : '${AppConstants.baseUrl}${item.imageUrl}';

    return Container(
      height: 104 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8 * scale),
              bottomLeft: Radius.circular(8 * scale),
            ),
            child: Image.network(
              fullImageUrl,
              width: photoW,
              height: photoH,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: photoW,
                  height: photoH,
                  color: const Color(0xFFC4C4C4),
                  child: const Icon(Icons.image, color: Colors.white),
                );
              },
            ),
          ),

          // Product Info
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 12 * scale, vertical: 8 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF222222),
                        ),
                      ),
                      SizedBox(height: 2 * scale),
                      Text(
                        item.brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11 * scale,
                          color: const Color(0xFF9B9B9B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Row(
                        children: [
                          Text(
                            'Color: ',
                            style: GoogleFonts.inter(
                              fontSize: 11 * scale,
                              color: const Color(0xFF9B9B9B),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              item.color,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11 * scale,
                                color: const Color(0xFF222222),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: 12 * scale),
                          Text(
                            'Size: ',
                            style: GoogleFonts.inter(
                              fontSize: 11 * scale,
                              color: const Color(0xFF9B9B9B),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              item.size,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11 * scale,
                                color: const Color(0xFF222222),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4 * scale),
                      Row(
                        children: [
                          Text(
                            'Units: ',
                            style: GoogleFonts.inter(
                              fontSize: 11 * scale,
                              color: const Color(0xFF9B9B9B),
                            ),
                          ),
                          Text(
                            '${item.units}',
                            style: GoogleFonts.inter(
                              fontSize: 11 * scale,
                              color: const Color(0xFF222222),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Price info
          Padding(
            padding: EdgeInsets.only(right: 16 * scale, bottom: 8 * scale),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '${item.price % 1 == 0 ? item.price.toInt() : item.price}\$',
                style: GoogleFonts.inter(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF222222),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, double scale,
      {bool isTotal = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130 * scale,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14 * scale,
              color: const Color(0xFF9B9B9B),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14 * scale,
              color: const Color(0xFF222222),
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodRow(double scale) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 130 * scale,
          child: Text(
            'Payment method:',
            style: GoogleFonts.inter(
              fontSize: 14 * scale,
              color: const Color(0xFF9B9B9B),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              // Mastercard Logo Overlay
              if (widget.order.paymentMethodType.toLowerCase() == 'mastercard')
                Container(
                  width: 32 * scale,
                  height: 20 * scale,
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 2 * scale,
                        child: Container(
                          width: 16 * scale,
                          height: 16 * scale,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEB001B),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10 * scale,
                        top: 2 * scale,
                        child: Container(
                          width: 16 * scale,
                          height: 16 * scale,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF79E1B),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Icon(
                  Icons.credit_card,
                  size: 20 * scale,
                  color: const Color(0xFF222222),
                ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: Text(
                  widget.order.paymentMethodCardNumber,
                  style: GoogleFonts.inter(
                    fontSize: 14 * scale,
                    color: const Color(0xFF222222),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
