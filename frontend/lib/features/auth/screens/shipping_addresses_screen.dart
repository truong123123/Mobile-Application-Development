import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_nhat_truong/features/auth/services/auth_service.dart';
import 'package:le_nhat_truong/features/auth/screens/add_shipping_address_screen.dart';

class ShippingAddressesScreen extends StatefulWidget {
  final bool selectMode;
  const ShippingAddressesScreen({super.key, this.selectMode = false});

  @override
  State<ShippingAddressesScreen> createState() => _ShippingAddressesScreenState();
}

class _ShippingAddressesScreenState extends State<ShippingAddressesScreen> {
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final list = await _authService.getUserAddresses();
      setState(() {
        _addresses = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải địa chỉ: $e'),
            backgroundColor: const Color(0xFFDB3022),
          ),
        );
      }
    }
  }

  Future<void> _toggleDefault(Map<String, dynamic> address, bool? value) async {
    if (value == null) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final id = address['id'];
      final updatedData = Map<String, dynamic>.from(address);
      updatedData['isDefault'] = value;
      // Remove hibernate lazy loading fields just in case
      updatedData.remove('customer');
      
      await _authService.updateUserAddress(id, updatedData);
      
      if (widget.selectMode && value) {
        if (mounted) {
          Navigator.pop(context, updatedData);
        }
        return;
      }
      
      await _loadAddresses();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật địa chỉ mặc định: $e'),
            backgroundColor: const Color(0xFFDB3022),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.of(context).size.width / 375).clamp(0.5, 1.5);

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
          'Shipping Addresses',
          style: GoogleFonts.outfit(
            color: const Color(0xFF222222),
            fontWeight: FontWeight.w700,
            fontSize: 18 * scale,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFDB3022),
                ),
              )
            : _addresses.isEmpty
                ? Center(
                    child: Text(
                      'Chưa có địa chỉ giao hàng nào.',
                      style: GoogleFonts.inter(
                        fontSize: 14 * scale,
                        color: const Color(0xFF9B9B9B),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(16 * scale),
                    itemCount: _addresses.length,
                    separatorBuilder: (_, __) => SizedBox(height: 16 * scale),
                    itemBuilder: (context, index) {
                      final address = _addresses[index];
                      final fullName = address['fullName'] ?? 'Chưa đặt tên';
                      final addressLine1 = address['addressLine1'] ?? '';
                      final city = address['city'] ?? '';
                      final state = address['state'] ?? '';
                      final postalCode = address['postalCode'] ?? '';
                      final country = address['country'] ?? '';
                      final isDefault = address['isDefault'] == true;

                      final addressText = '$addressLine1\n$city, $state $postalCode, $country';

                      return InkWell(
                        onTap: widget.selectMode
                            ? () => Navigator.pop(context, address)
                            : null,
                        child: Container(
                          padding: EdgeInsets.all(16 * scale),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8 * scale),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8 * scale,
                                offset: Offset(0, 4 * scale),
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
                                    fullName,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14 * scale,
                                      color: const Color(0xFF222222),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final updated = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddShippingAddressScreen(address: address),
                                        ),
                                      );
                                      if (updated == true) {
                                        _loadAddresses();
                                      }
                                    },
                                    child: Text(
                                      'Edit',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14 * scale,
                                        color: const Color(0xFFDB3022),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8 * scale),
                              Text(
                                addressText,
                                style: GoogleFonts.inter(
                                  fontSize: 13 * scale,
                                  color: const Color(0xFF222222),
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(height: 12 * scale),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20 * scale,
                                    height: 20 * scale,
                                    child: Checkbox(
                                      value: isDefault,
                                      activeColor: const Color(0xFF222222),
                                      onChanged: (val) => _toggleDefault(address, val),
                                    ),
                                  ),
                                  SizedBox(width: 12 * scale),
                                  Text(
                                    'Use as the shipping address',
                                    style: GoogleFonts.inter(
                                      fontSize: 13 * scale,
                                      color: const Color(0xFF222222),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddShippingAddressScreen(),
            ),
          );
          if (added == true) {
            _loadAddresses();
          }
        },
        backgroundColor: const Color(0xFF222222),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
