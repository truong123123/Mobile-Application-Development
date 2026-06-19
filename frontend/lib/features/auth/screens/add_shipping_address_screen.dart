import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:le_nhat_truong/features/auth/services/auth_service.dart';

class AddShippingAddressScreen extends StatefulWidget {
  final Map<String, dynamic>? address;
  const AddShippingAddressScreen({super.key, this.address});

  @override
  State<AddShippingAddressScreen> createState() => _AddShippingAddressScreenState();
}

class _AddShippingAddressScreenState extends State<AddShippingAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  late TextEditingController _countryController;

  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    final addr = widget.address;
    _nameController = TextEditingController(text: addr?['fullName'] ?? '');
    _addressController = TextEditingController(text: addr?['addressLine1'] ?? '');
    _cityController = TextEditingController(text: addr?['city'] ?? '');
    _stateController = TextEditingController(text: addr?['state'] ?? '');
    _zipController = TextEditingController(text: addr?['postalCode'] ?? '');
    _countryController = TextEditingController(text: addr?['country'] ?? 'United States');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final payload = {
      'fullName': _nameController.text.trim(),
      'addressLine1': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'postalCode': _zipController.text.trim(),
      'country': _countryController.text.trim(),
      'isDefault': widget.address?['isDefault'] ?? false,
    };

    try {
      if (widget.address != null) {
        final id = widget.address!['id'];
        await _authService.updateUserAddress(id, payload);
      } else {
        await _authService.addUserAddress(payload);
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu địa chỉ: $e'),
            backgroundColor: const Color(0xFFDB3022),
          ),
        );
      }
    }
  }

  Future<void> _deleteAddress() async {
    if (widget.address == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa địa chỉ?', style: TextStyle(color: Color(0xFF222222))),
        content: const Text('Bạn có chắc chắn muốn xóa địa chỉ này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF9B9B9B))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: Color(0xFFDB3022))),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final id = widget.address!['id'];
      await _authService.deleteUserAddress(id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa địa chỉ: $e'),
            backgroundColor: const Color(0xFFDB3022),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.of(context).size.width / 375).clamp(0.5, 1.5);
    final isEdit = widget.address != null;

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
          isEdit ? 'Editing Shipping Address' : 'Adding Shipping Address',
          style: GoogleFonts.outfit(
            color: const Color(0xFF222222),
            fontWeight: FontWeight.w700,
            fontSize: 18 * scale,
          ),
        ),
        centerTitle: true,
        actions: [
          if (isEdit)
            IconButton(
              icon: Icon(Icons.delete_outline, color: const Color(0xFFDB3022), size: 24 * scale),
              onPressed: _isDeleting ? null : _deleteAddress,
            ),
        ],
      ),
      body: SafeArea(
        child: _isSaving || _isDeleting
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFDB3022),
                ),
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16 * scale),
                  child: Column(
                    children: [
                      SizedBox(height: 12 * scale),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full name',
                        scale: scale,
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Vui lòng nhập họ tên' : null,
                      ),
                      SizedBox(height: 20 * scale),
                      _buildTextField(
                        controller: _addressController,
                        label: 'Address',
                        scale: scale,
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Vui lòng nhập địa chỉ' : null,
                      ),
                      SizedBox(height: 20 * scale),
                      _buildTextField(
                        controller: _cityController,
                        label: 'City',
                        scale: scale,
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Vui lòng nhập thành phố' : null,
                      ),
                      SizedBox(height: 20 * scale),
                      _buildTextField(
                        controller: _stateController,
                        label: 'State/Province/Region',
                        scale: scale,
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Vui lòng nhập bang/tỉnh/vùng' : null,
                      ),
                      SizedBox(height: 20 * scale),
                      _buildTextField(
                        controller: _zipController,
                        label: 'Zip Code (Postal Code)',
                        scale: scale,
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Vui lòng nhập mã bưu điện' : null,
                      ),
                      SizedBox(height: 20 * scale),
                      _buildTextField(
                        controller: _countryController,
                        label: 'Country',
                        scale: scale,
                        readOnly: true,
                        onTap: () => _showCountryPicker(scale),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Vui lòng nhập quốc gia' : null,
                        suffixIcon: Icon(Icons.chevron_right, color: const Color(0xFF222222), size: 20 * scale),
                      ),
                      SizedBox(height: 40 * scale),
                      SizedBox(
                        width: double.infinity,
                        height: 48 * scale,
                        child: ElevatedButton(
                          onPressed: _saveAddress,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDB3022),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24 * scale),
                            ),
                            elevation: 2 * scale,
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
              ),
      ),
    );
  }

  void _showCountryPicker(double scale) {
    final countries = [
      'Vietnam',
      'United States',
      'United Kingdom',
      'Japan',
      'Korea',
      'Singapore',
      'Australia',
      'Canada',
      'France',
      'Germany',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20 * scale, horizontal: 16 * scale),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Country',
                style: GoogleFonts.outfit(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF222222),
                ),
              ),
              SizedBox(height: 12 * scale),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: countries.length,
                  itemBuilder: (context, index) {
                    final c = countries[index];
                    final isSelected = _countryController.text.trim().toLowerCase() == c.toLowerCase();
                    return ListTile(
                      onTap: () {
                        setState(() {
                          _countryController.text = c;
                        });
                        Navigator.pop(ctx);
                      },
                      contentPadding: EdgeInsets.symmetric(horizontal: 8 * scale),
                      title: Text(
                        c,
                        style: GoogleFonts.inter(
                          fontSize: 14 * scale,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? const Color(0xFFDB3022) : const Color(0xFF222222),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Color(0xFFDB3022))
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required double scale,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 4 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        style: GoogleFonts.inter(
          fontSize: 14 * scale,
          color: const Color(0xFF222222),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(
            color: const Color(0xFF9B9B9B),
            fontSize: 12 * scale,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4 * scale),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4 * scale),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4 * scale),
            borderSide: const BorderSide(color: Color(0xFFDB3022), width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4 * scale),
            borderSide: const BorderSide(color: Color(0xFFDB3022), width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4 * scale),
            borderSide: const BorderSide(color: Color(0xFFDB3022), width: 1.5),
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
