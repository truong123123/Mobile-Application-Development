import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:le_nhat_truong/features/cart/providers/cart_provider.dart';
import 'package:le_nhat_truong/features/auth/services/auth_service.dart';
import 'package:le_nhat_truong/features/orders/screens/order_success_screen.dart';
import 'package:le_nhat_truong/features/auth/screens/shipping_addresses_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedDeliveryIndex = 0; // 0: FedEx, 1: USPS, 2: DHL
  String _shippingName = 'Jane Doe';
  String _shippingAddress =
      '3 Newbridge Court\nChino Hills, CA 91709, United States';
  String _cardNumber = '3947';
  String _cardType = 'MasterCard';
  List<Map<String, dynamic>> _userCards = [];
  bool _loadingCards = false;

  @override
  void initState() {
    super.initState();
    _loadUserCards();
    _loadUserAddress();
  }

  Future<void> _loadUserAddress() async {
    try {
      final addresses = await AuthService().getUserAddresses();
      if (addresses.isNotEmpty) {
        final defaultAddress = addresses.firstWhere(
          (addr) => addr['isDefault'] == true,
          orElse: () => addresses.first,
        );
        setState(() {
          _shippingName = defaultAddress['fullName'] ?? 'Jane Doe';
          _shippingAddress = '${defaultAddress['addressLine1']}\n${defaultAddress['city']}, ${defaultAddress['state']} ${defaultAddress['postalCode']}, ${defaultAddress['country']}';
        });
      }
    } catch (e) {
      print('>>> Error loading user address: $e');
    }
  }

  Future<void> _loadUserCards() async {
    setState(() {
      _loadingCards = true;
    });
    try {
      final cards = await AuthService().getUserCards();
      setState(() {
        _userCards = cards;
        if (_userCards.isNotEmpty) {
          bool found = false;
          for (var c in _userCards) {
            if (c['lastFour'] == _cardNumber && c['cardType'] == _cardType) {
              found = true;
              break;
            }
          }
          if (!found) {
            _cardType = _userCards.first['cardType'] ?? 'MasterCard';
            _cardNumber = _userCards.first['lastFour'] ?? '3947';
          }
        }
      });
    } catch (e) {
      print('>>> Error loading user cards: $e');
    } finally {
      setState(() {
        _loadingCards = false;
      });
    }
  }

  void _showEditAddressBottomSheet(BuildContext context, double scale) {
    final nameController = TextEditingController(text: _shippingName);
    final addressController = TextEditingController(text: _shippingAddress);

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
            left: 20 * scale,
            right: 20 * scale,
            top: 10 * scale,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24 * scale,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  'Edit Shipping Address',
                  style: GoogleFonts.outfit(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF222222),
                  ),
                ),
                SizedBox(height: 20 * scale),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle:
                        GoogleFonts.inter(color: const Color(0xFF9B9B9B)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8 * scale),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8 * scale),
                      borderSide: const BorderSide(color: Color(0xFFDB3022)),
                    ),
                  ),
                ),
                SizedBox(height: 16 * scale),
                TextField(
                  controller: addressController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Address Details',
                    labelStyle:
                        GoogleFonts.inter(color: const Color(0xFF9B9B9B)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8 * scale),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8 * scale),
                      borderSide: const BorderSide(color: Color(0xFFDB3022)),
                    ),
                  ),
                ),
                SizedBox(height: 24 * scale),
                SizedBox(
                  width: double.infinity,
                  height: 48 * scale,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.trim().isNotEmpty &&
                          addressController.text.trim().isNotEmpty) {
                        setState(() {
                          _shippingName = nameController.text.trim();
                          _shippingAddress = addressController.text.trim();
                        });
                        Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDB3022),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24 * scale),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'SAVE ADDRESS',
                      style: GoogleFonts.inter(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditPaymentBottomSheet(BuildContext context, double scale) {
    final cardController = TextEditingController();
    String selectedCardType = 'MasterCard';
    bool isAddingNewCard = _userCards.isEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF9F9F9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: EdgeInsets.only(
                left: 20 * scale,
                right: 20 * scale,
                top: 10 * scale,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24 * scale,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Text(
                      'Payment Method',
                      style: GoogleFonts.outfit(
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF222222),
                      ),
                    ),
                    SizedBox(height: 16 * scale),
                    if (_userCards.isNotEmpty) ...[
                      Text(
                        'Your Cards',
                        style: GoogleFonts.inter(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9B9B9B),
                        ),
                      ),
                      SizedBox(height: 10 * scale),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _userCards.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: 12 * scale),
                        itemBuilder: (context, index) {
                          final card = _userCards[index];
                          final cardTypeStr = card['cardType'] ?? 'Visa';
                          final lastFourStr = card['lastFour'] ?? '00';
                          final isSelected = (_cardType.toLowerCase() ==
                                  cardTypeStr.toString().toLowerCase() &&
                              _cardNumber == lastFourStr);
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _cardType = cardTypeStr;
                                _cardNumber = lastFourStr;
                              });
                              Navigator.pop(ctx);
                            },
                            child: Container(
                              padding: EdgeInsets.all(12 * scale),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8 * scale),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFDB3022)
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  _CardLogo(
                                      cardType: cardTypeStr, scale: scale),
                                  SizedBox(width: 16 * scale),
                                  Expanded(
                                    child: Text(
                                      '**** **** **** $lastFourStr',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14 * scale,
                                        color: const Color(0xFF222222),
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle,
                                        color: Color(0xFF2AA95C))
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16 * scale),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isAddingNewCard
                              ? 'Add New Card'
                              : 'Or add another method',
                          style: GoogleFonts.inter(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF9B9B9B),
                          ),
                        ),
                        if (_userCards.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                isAddingNewCard = !isAddingNewCard;
                              });
                            },
                            child: Text(
                              isAddingNewCard ? 'Show saved cards' : 'Add Card',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFDB3022),
                                fontWeight: FontWeight.w600,
                                fontSize: 13 * scale,
                              ),
                            ),
                          )
                      ],
                    ),
                    SizedBox(height: 10 * scale),
                    if (isAddingNewCard) ...[
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  selectedCardType = 'MasterCard';
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(12 * scale),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(8 * scale),
                                  border: Border.all(
                                    color: selectedCardType == 'MasterCard'
                                        ? const Color(0xFFDB3022)
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _CardLogo(
                                        cardType: 'MasterCard', scale: scale),
                                    SizedBox(width: 12 * scale),
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'MasterCard',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14 * scale,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12 * scale),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  selectedCardType = 'Visa';
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(12 * scale),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(8 * scale),
                                  border: Border.all(
                                    color: selectedCardType == 'Visa'
                                        ? const Color(0xFFDB3022)
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _CardLogo(cardType: 'Visa', scale: scale),
                                    SizedBox(width: 12 * scale),
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Visa',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14 * scale,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20 * scale),
                      TextField(
                        controller: cardController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Card Number',
                          labelStyle:
                              GoogleFonts.inter(color: const Color(0xFF9B9B9B)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8 * scale),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8 * scale),
                            borderSide:
                                const BorderSide(color: Color(0xFFDB3022)),
                          ),
                        ),
                      ),
                      SizedBox(height: 24 * scale),
                      SizedBox(
                        width: double.infinity,
                        height: 48 * scale,
                        child: ElevatedButton(
                          onPressed: () async {
                            String numStr = cardController.text.trim();
                            if (numStr.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Vui lòng nhập số thẻ'),
                                  backgroundColor: Color(0xFFDB3022),
                                ),
                              );
                              return;
                            }
                            String digits = '00';
                            if (numStr.length >= 4) {
                              digits = numStr.substring(numStr.length - 4);
                            } else {
                              digits = numStr;
                            }

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) => const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFFDB3022)),
                              ),
                            );

                            try {
                              final authService = AuthService();
                              await authService.addUserCard(
                                  selectedCardType, digits);

                              await _loadUserCards();

                              Navigator.pop(context);
                              Navigator.pop(ctx);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã thêm thẻ thành công!'),
                                  backgroundColor: Color(0xFF2AA95C),
                                ),
                              );
                            } catch (e) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Lỗi thêm thẻ: $e'),
                                  backgroundColor: const Color(0xFFDB3022),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDB3022),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24 * scale),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'SAVE PAYMENT',
                            style: GoogleFonts.inter(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.of(context).size.width / 375).clamp(0.5, 1.5);
    final cartProvider = Provider.of<CartProvider>(context);
    final double orderAmount = cartProvider.finalAmount;
    const double deliveryAmount = 15.0;
    final double summaryAmount = orderAmount + deliveryAmount;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: const Color(0xFF222222), size: 20 * scale),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkout',
          style: GoogleFonts.outfit(
            color: const Color(0xFF222222),
            fontWeight: FontWeight.w700,
            fontSize: 18 * scale,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shipping address section
                    Text(
                      'Shipping address',
                      style: GoogleFonts.outfit(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF222222),
                      ),
                    ),
                    SizedBox(height: 12 * scale),
                    Container(
                      padding: EdgeInsets.all(16 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8 * scale,
                            offset: Offset(0, 2 * scale),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _shippingName,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14 * scale,
                                  color: const Color(0xFF222222),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  final selected = await Navigator.push<Map<String, dynamic>>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ShippingAddressesScreen(selectMode: true),
                                    ),
                                  );
                                  if (selected != null) {
                                    setState(() {
                                      _shippingName = selected['fullName'] ?? '';
                                      _shippingAddress = '${selected['addressLine1']}\n${selected['city']}, ${selected['state']} ${selected['postalCode']}, ${selected['country']}';
                                    });
                                  }
                                },
                                child: Text(
                                  'Change',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14 * scale,
                                    color: const Color(0xFFDB3022),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10 * scale),
                          Text(
                            _shippingAddress,
                            style: GoogleFonts.inter(
                              fontSize: 14 * scale,
                              color: const Color(0xFF222222),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 28 * scale),

                    // Payment section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment',
                          style: GoogleFonts.outfit(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF222222),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              _showEditPaymentBottomSheet(context, scale),
                          child: Text(
                            'Change',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 14 * scale,
                              color: const Color(0xFFDB3022),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12 * scale),
                    Row(
                      children: [
                        _CardLogo(cardType: _cardType, scale: scale),
                        SizedBox(width: 16 * scale),
                        Text(
                          '**** **** **** $_cardNumber',
                          style: GoogleFonts.inter(
                            fontSize: 14 * scale,
                            color: const Color(0xFF222222),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 28 * scale),

                    // Delivery method section
                    Text(
                      'Delivery method',
                      style: GoogleFonts.outfit(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF222222),
                      ),
                    ),
                    SizedBox(height: 12 * scale),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _DeliveryCard(
                          logoWidget: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Fed',
                                  style: GoogleFonts.outfit(
                                      color: const Color(0xFF4D148C),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16 * scale)),
                              Text('Ex',
                                  style: GoogleFonts.outfit(
                                      color: const Color(0xFFFF6600),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16 * scale)),
                            ],
                          ),
                          duration: '2-3 days',
                          isSelected: _selectedDeliveryIndex == 0,
                          onTap: () =>
                              setState(() => _selectedDeliveryIndex = 0),
                          scale: scale,
                        ),
                        _DeliveryCard(
                          logoWidget: Padding(
                            padding: EdgeInsets.symmetric(vertical: 2 * scale),
                            child: Text(
                              'USPS.COM',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF003366),
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w900,
                                fontSize: 12 * scale,
                              ),
                            ),
                          ),
                          duration: '2-3 days',
                          isSelected: _selectedDeliveryIndex == 1,
                          onTap: () =>
                              setState(() => _selectedDeliveryIndex = 1),
                          scale: scale,
                        ),
                        _DeliveryCard(
                          logoWidget: Text(
                            'DHL',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFCC00),
                              fontWeight: FontWeight.w900,
                              fontSize: 20 * scale,
                              shadows: [
                                const Shadow(
                                  offset: Offset(1, 1),
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                          duration: '2-3 days',
                          isSelected: _selectedDeliveryIndex == 2,
                          onTap: () =>
                              setState(() => _selectedDeliveryIndex = 2),
                          scale: scale,
                        ),
                      ],
                    ),

                    SizedBox(height: 48 * scale),

                    // Pricing rows
                    _SummaryRow(
                      label: 'Order:',
                      amount: '${orderAmount.round()}\$',
                      scale: scale,
                    ),
                    SizedBox(height: 14 * scale),
                    _SummaryRow(
                      label: 'Delivery:',
                      amount: '${deliveryAmount.round()}\$',
                      scale: scale,
                    ),
                    SizedBox(height: 14 * scale),
                    _SummaryRow(
                      label: 'Summary:',
                      amount: '${summaryAmount.round()}\$',
                      isBold: true,
                      scale: scale,
                    ),
                    SizedBox(height: 24 * scale),
                  ],
                ),
              ),
            ),

            // Submit Button Area
            Container(
              padding: EdgeInsets.fromLTRB(
                  16 * scale, 12 * scale, 16 * scale, 24 * scale),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48 * scale,
                child: ElevatedButton(
                  onPressed: cartProvider.items.isEmpty
                      ? null
                      : () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFFDB3022)),
                            ),
                          );

                          try {
                            final List<Map<String, dynamic>> orderItems =
                                cartProvider.items.map((item) {
                              return {
                                'productId': item.product.id,
                                'quantity': item.quantity,
                                'selectedSize': item.selectedSize,
                                'selectedColor': item.selectedColor,
                                'price': item.product.salePrice,
                              };
                            }).toList();

                            String deliveryMethodStr = 'FedEx';
                            if (_selectedDeliveryIndex == 1) {
                              deliveryMethodStr = 'USPS';
                            } else if (_selectedDeliveryIndex == 2) {
                              deliveryMethodStr = 'DHL';
                            }

                            final orderPayload = {
                              'totalAmount': summaryAmount,
                              'shippingAddress': _shippingAddress,
                              'deliveryMethod': deliveryMethodStr,
                              'paymentMethod': '$_cardType **** $_cardNumber',
                              'discount': cartProvider.discountAmount,
                              'items': orderItems,
                            };

                            final authService = AuthService();
                            await authService.createRealOrder(orderPayload);

                            Navigator.pop(context);

                            cartProvider.clearCart();
                            final isYellow = Random().nextBool();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    OrderSuccessScreen(isYellow: isYellow),
                              ),
                            );
                          } catch (e) {
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFFDB3022),
                                content: Text('Lỗi khi đặt hàng: $e'),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB3022),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24 * scale),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFFDB3022).withOpacity(0.35),
                  ),
                  child: Text(
                    'SUBMIT ORDER',
                    style: GoogleFonts.inter(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardLogo extends StatelessWidget {
  final String cardType;
  final double scale;
  const _CardLogo({required this.cardType, required this.scale});

  @override
  Widget build(BuildContext context) {
    if (cardType.toLowerCase() == 'visa') {
      return Container(
        width: 48 * scale,
        height: 32 * scale,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F71),
          borderRadius: BorderRadius.circular(4 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'VISA',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              fontSize: 14 * scale,
              letterSpacing: 1.0,
            ),
          ),
        ),
      );
    }
    // Default to MasterCard
    return Container(
      width: 48 * scale,
      height: 32 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 32 * scale,
          height: 20 * scale,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                child: Container(
                  width: 20 * scale,
                  height: 20 * scale,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEB001B),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                child: Container(
                  width: 20 * scale,
                  height: 20 * scale,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF79E1B),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 8 * scale,
                  height: 14 * scale,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5F00),
                    borderRadius: BorderRadius.all(Radius.elliptical(4, 7)),
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

class _DeliveryCard extends StatelessWidget {
  final Widget logoWidget;
  final String duration;
  final bool isSelected;
  final VoidCallback onTap;
  final double scale;

  const _DeliveryCard({
    required this.logoWidget,
    required this.duration,
    required this.isSelected,
    required this.onTap,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 104 * scale,
        height: 72 * scale,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8 * scale),
          border: Border.all(
            color: isSelected ? const Color(0xFFDB3022) : Colors.transparent,
            width: 1.5 * scale,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.08 : 0.04),
              blurRadius: 8 * scale,
              offset: Offset(0, 4 * scale),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            logoWidget,
            SizedBox(height: 6 * scale),
            Text(
              duration,
              style: GoogleFonts.inter(
                fontSize: 11 * scale,
                color: const Color(0xFF9B9B9B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool isBold;
  final double scale;

  const _SummaryRow({
    required this.label,
    required this.amount,
    this.isBold = false,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final styleLabel = GoogleFonts.inter(
      fontSize: 14 * scale,
      color: isBold ? const Color(0xFF9B9B9B) : const Color(0xFF9B9B9B),
      fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
    );
    final styleAmount = isBold
        ? GoogleFonts.outfit(
            fontSize: 18 * scale,
            color: const Color(0xFF222222),
            fontWeight: FontWeight.w800,
          )
        : GoogleFonts.inter(
            fontSize: 16 * scale,
            color: const Color(0xFF222222),
            fontWeight: FontWeight.w700,
          );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: styleLabel),
        Text(amount, style: styleAmount),
      ],
    );
  }
}
