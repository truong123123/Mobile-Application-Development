import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_nhat_truong/features/orders/services/order_service.dart';

class OrderProductItem {
  final String title;
  final String brand;
  final String color;
  final String size;
  final int units;
  final double price;
  final String imageUrl;
  final String productId;

  OrderProductItem({
    required this.title,
    required this.brand,
    required this.color,
    required this.size,
    required this.units,
    required this.price,
    required this.imageUrl,
    this.productId = '3fa85f64-5717-4562-b3fc-2c963f66afa6', // dummy default
  });

  factory OrderProductItem.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'] as Map<String, dynamic>?;

    final title = productJson?['productName'] ?? json['title'] ?? '';
    final brand = productJson?['brandName'] ?? json['brand'] ?? '';
    final imageUrl = productJson?['imageUrl'] ?? json['imageUrl'] ?? '';
    final productId = productJson?['id'] ?? json['productId'] ?? '';

    final units = json['quantity'] ?? json['units'] ?? 0;
    final color = json['selectedColor'] ?? json['color'] ?? '';
    final size = json['selectedSize'] ?? json['size'] ?? '';
    final price = (json['price'] as num?)?.toDouble() ?? 0.0;

    return OrderProductItem(
      title: title,
      brand: brand,
      color: color,
      size: size,
      units: units,
      price: price,
      imageUrl: imageUrl,
      productId: productId,
    );
  }
}

class OrderItemData {
  final String orderNo;
  final String date;
  final String trackingNumber;
  final int quantity;
  final double totalAmount;
  final String status; // 'Delivered', 'Processing', 'Cancelled'
  final String shippingAddress;
  final String paymentMethodCardNumber;
  final String paymentMethodType;
  final String deliveryMethod;
  final String discount;
  final List<OrderProductItem> items;

  OrderItemData({
    required this.orderNo,
    required this.date,
    required this.trackingNumber,
    required this.quantity,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.paymentMethodCardNumber,
    required this.paymentMethodType,
    required this.deliveryMethod,
    required this.discount,
    required this.items,
  });

  factory OrderItemData.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>?)
            ?.map((item) => OrderProductItem.fromJson(item))
            .toList() ??
        [];

    final computedQty = items.fold<int>(0, (sum, item) => sum + item.units);
    final quantity = json['quantity'] ?? computedQty;

    final status = json['orderStatus']?['statusName'] ?? json['status'] ?? '';

    String rawDate = json['createdAt'] ?? json['date'] ?? '';
    if (rawDate.length > 10) {
      rawDate = rawDate.substring(0, 10);
    }

    final pm = json['paymentMethod']?.toString() ?? '';
    String pmCard = '****';
    String pmType = 'Visa';
    if (pm.contains(' **** ')) {
      final parts = pm.split(' **** ');
      pmType = parts[0];
      pmCard = parts[1];
    } else if (pm.isNotEmpty) {
      pmType = pm;
    }

    final paymentCard = json['paymentMethodCardNumber'] ?? pmCard;
    final paymentType = json['paymentMethodType'] ?? pmType;

    return OrderItemData(
      orderNo: json['id'] ?? json['orderNo'] ?? '',
      date: rawDate,
      trackingNumber: json['trackingNumber'] ?? 'IW347545345',
      quantity: quantity,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: status,
      shippingAddress: json['shippingAddress'] ?? '',
      paymentMethodCardNumber: paymentCard,
      paymentMethodType: paymentType,
      deliveryMethod: json['deliveryMethod'] ?? '',
      discount: json['discount']?.toString() ?? '',
      items: items,
    );
  }
}

class MyOrdersScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<OrderItemData>? onOrderDetails;

  const MyOrdersScreen({super.key, this.onBack, this.onOrderDetails});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  String _selectedTab = 'Delivered';
  bool _isLoading = true;
  List<OrderItemData> _allOrders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await OrderService().getMyOrders();
      if (mounted) {
        setState(() {
          _allOrders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load orders: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.of(context).size.width / 375).clamp(0.5, 1.5);

    // Filter orders based on the selected tab
    final filteredOrders =
        _allOrders.where((order) => order.status == _selectedTab).toList();

    return Container(
      color: const Color(0xFFF9F9F9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom header bar (Back arrow and Search icon)
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
                  onPressed: () {
                    if (widget.onBack != null) {
                      widget.onBack!();
                    } else {
                      Navigator.maybePop(context);
                    }
                  },
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

          // Large Title "My Orders"
          Padding(
            padding: EdgeInsets.only(
                left: 16 * scale, right: 16 * scale, bottom: 20 * scale),
            child: Text(
              'My Orders',
              style: GoogleFonts.outfit(
                fontSize: 34 * scale,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF222222),
              ),
            ),
          ),

          // Tab Filters Row (Delivered, Processing, Cancelled)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * scale),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTabButton('Delivered', scale),
                _buildTabButton('Processing', scale),
                _buildTabButton('Cancelled', scale),
              ],
            ),
          ),

          SizedBox(height: 24 * scale),

          // Scrollable Order List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFDB3022)),
                  )
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: filteredOrders.isEmpty
                        ? Center(
                            key: ValueKey('empty_$_selectedTab'),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 48 * scale,
                                  color: const Color(0xFF9B9B9B),
                                ),
                                SizedBox(height: 12 * scale),
                                Text(
                                  'No orders found',
                                  style: GoogleFonts.inter(
                                    fontSize: 15 * scale,
                                    color: const Color(0xFF9B9B9B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            key: ValueKey('list_$_selectedTab'),
                            padding:
                                EdgeInsets.symmetric(horizontal: 16 * scale),
                            itemCount: filteredOrders.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 24 * scale),
                                child: _buildOrderCard(
                                    filteredOrders[index], scale),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabTitle, double scale) {
    final isSelected = _selectedTab == tabTitle;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tabTitle;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: 20 * scale,
          vertical: 8 * scale,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF222222) : Colors.transparent,
          borderRadius: BorderRadius.circular(24 * scale),
        ),
        child: Text(
          tabTitle,
          style: GoogleFonts.inter(
            fontSize: 14 * scale,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF222222),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderItemData order, double scale) {
    // Determine the text color for the order status
    Color statusColor;
    switch (order.status) {
      case 'Delivered':
        statusColor = const Color(0xFF2AA95C); // Green
        break;
      case 'Processing':
        statusColor = const Color(0xFFFFBA49); // Orange/Yellow
        break;
      case 'Cancelled':
        statusColor = const Color(0xFFDB3022); // Red
        break;
      default:
        statusColor = const Color(0xFF9B9B9B);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      padding: EdgeInsets.all(18 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Order Number & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Order №${order.orderNo}',
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
                order.date,
                style: GoogleFonts.inter(
                  fontSize: 14 * scale,
                  color: const Color(0xFF9B9B9B),
                ),
              ),
            ],
          ),

          SizedBox(height: 12 * scale),

          // Tracking number row
          Row(
            children: [
              Text(
                'Tracking number: ',
                style: GoogleFonts.inter(
                  fontSize: 14 * scale,
                  color: const Color(0xFF9B9B9B),
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                order.trackingNumber,
                style: GoogleFonts.inter(
                  fontSize: 14 * scale,
                  color: const Color(0xFF222222),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 10 * scale),

          // Quantity and Total Amount row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Quantity: ',
                    style: GoogleFonts.inter(
                      fontSize: 14 * scale,
                      color: const Color(0xFF9B9B9B),
                    ),
                  ),
                  Text(
                    '${order.quantity}',
                    style: GoogleFonts.inter(
                      fontSize: 14 * scale,
                      color: const Color(0xFF222222),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Total Amount: ',
                    style: GoogleFonts.inter(
                      fontSize: 14 * scale,
                      color: const Color(0xFF9B9B9B),
                    ),
                  ),
                  Text(
                    '${order.totalAmount % 1 == 0 ? order.totalAmount.toInt() : order.totalAmount}\$',
                    style: GoogleFonts.inter(
                      fontSize: 14 * scale,
                      color: const Color(0xFF222222),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 16 * scale),

          // Bottom row: Details button & Status text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Details Button
              SizedBox(
                height: 36 * scale,
                child: OutlinedButton(
                  onPressed: () {
                    if (widget.onOrderDetails != null) {
                      widget.onOrderDetails!(order);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF222222),
                    side:
                        const BorderSide(color: Color(0xFF222222), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24 * scale),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                  ),
                  child: Text(
                    'Details',
                    style: GoogleFonts.inter(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Status text
              Text(
                order.status,
                style: GoogleFonts.inter(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
