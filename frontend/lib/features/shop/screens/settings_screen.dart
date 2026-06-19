import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:le_nhat_truong/features/auth/providers/auth_provider.dart';
import 'package:le_nhat_truong/features/auth/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const SettingsScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _passwordController;

  bool _salesNotification = true;
  bool _newArrivalsNotification = false;
  bool _deliveryStatusNotification = false;
  bool _initialized = false;
  bool _isSavingDob = false;
  String _originalDob = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _dobController = TextEditingController();
    _passwordController = TextEditingController(text: 'password123456');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        _nameController.text = auth.user!.name;
        final dob = auth.user!.dateOfBirth ?? '1989-12-12';
        _dobController.text = dob;
        _originalDob = dob;
        _salesNotification = auth.user!.salesNotification;
        _newArrivalsNotification = auth.user!.newArrivalsNotification;
        _deliveryStatusNotification = auth.user!.deliveryStatusNotification;
      } else {
        _nameController.text = 'Matilda Brown';
        _dobController.text = '1989-12-12';
        _originalDob = '1989-12-12';
        _salesNotification = true;
        _newArrivalsNotification = false;
        _deliveryStatusNotification = false;
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showChangePasswordBottomSheet(double scale) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final repeatPasswordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30 * scale)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16 * scale,
            right: 16 * scale,
            top: 32 * scale,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 60 * scale,
                  height: 6 * scale,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC4C4C4),
                    borderRadius: BorderRadius.circular(3 * scale),
                  ),
                ),
                SizedBox(height: 24 * scale),
                Text(
                  'Password Change',
                  style: GoogleFonts.inter(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF222222),
                  ),
                ),
                SizedBox(height: 20 * scale),
                _buildModalInputField(
                  label: 'Old Password',
                  controller: oldPasswordController,
                  scale: scale,
                  obscureText: true,
                ),
                SizedBox(height: 12 * scale),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Chức năng khôi phục mật khẩu đang phát triển!',
                            style:
                                GoogleFonts.inter(fontWeight: FontWeight.w500),
                          ),
                          backgroundColor: const Color(0xFF222222),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.inter(
                        fontSize: 14 * scale,
                        color: const Color(0xFF9B9B9B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 18 * scale),
                _buildModalInputField(
                  label: 'New Password',
                  controller: newPasswordController,
                  scale: scale,
                  obscureText: true,
                ),
                SizedBox(height: 16 * scale),
                _buildModalInputField(
                  label: 'Repeat New Password',
                  controller: repeatPasswordController,
                  scale: scale,
                  obscureText: true,
                ),
                SizedBox(height: 32 * scale),
                SizedBox(
                  width: double.infinity,
                  height: 48 * scale,
                  child: ElevatedButton(
                    onPressed: () {
                      if (newPasswordController.text !=
                          repeatPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Mật khẩu mới không trùng khớp!',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500),
                            ),
                            backgroundColor: const Color(0xFFDB3022),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        _passwordController.text = newPasswordController.text;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Đổi mật khẩu thành công!',
                            style:
                                GoogleFonts.inter(fontWeight: FontWeight.w500),
                          ),
                          backgroundColor: const Color(0xFF2AA95C),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDB3022),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24 * scale),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'SAVE PASSWORD',
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
        );
      },
    );
  }

  Widget _buildModalInputField({
    required String label,
    required TextEditingController controller,
    required double scale,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      padding:
          EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 8 * scale),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.inter(
          fontSize: 14 * scale,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF222222),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(
            fontSize: 11 * scale,
            color: const Color(0xFF9B9B9B),
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          contentPadding: EdgeInsets.zero,
          filled: false,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime(1989, 12, 12);
    if (_dobController.text.isNotEmpty) {
      try {
        final parsed = DateTime.parse(_dobController.text.trim());
        initialDate = parsed;
      } catch (e) {
        // use default
      }
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFDB3022), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Color(0xFF222222), // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFDB3022), // button text color
              ),
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );
    if (picked != null) {
      final formattedDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        _dobController.text = formattedDate;
      });
    }
  }

  Widget _buildDobInputField({
    required double scale,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      padding:
          EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 8 * scale),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _selectDate(context),
              behavior: HitTestBehavior.opaque,
              child: IgnorePointer(
                child: TextField(
                  controller: _dobController,
                  readOnly: true,
                  style: GoogleFonts.inter(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF222222),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    labelStyle: GoogleFonts.inter(
                      fontSize: 11 * scale,
                      color: const Color(0xFF9B9B9B),
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    contentPadding: EdgeInsets.zero,
                    filled: false,
                    fillColor: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
          if (_isSavingDob)
            SizedBox(
              width: 24 * scale,
              height: 24 * scale,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDB3022)),
              ),
            )
          else if (_dobController.text != _originalDob) ...[  
            SizedBox(width: 8 * scale),
            ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _isSavingDob = true;
                    });
                    try {
                      final authService = AuthService();
                      await authService.updateProfile(
                        name: _nameController.text.trim(),
                        dateOfBirth: _dobController.text.trim(),
                        sales: _salesNotification,
                        newArrivals: _newArrivalsNotification,
                        deliveryStatus: _deliveryStatusNotification,
                      );
                      final authProvider =
                          Provider.of<AuthProvider>(context, listen: false);
                      await authProvider.checkAuthStatus();
                      if (mounted) {
                        setState(() {
                          _originalDob = _dobController.text;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Cập nhật ngày sinh thành công!',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                            ),
                            backgroundColor: const Color(0xFF2AA95C),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Cập nhật ngày sinh thất bại: $e',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                            ),
                            backgroundColor: const Color(0xFFDB3022),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isSavingDob = false;
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB3022),
                    foregroundColor: Colors.white,
                    minimumSize: Size(60 * scale, 36 * scale),
                    padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16 * scale),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Save',
                    style: GoogleFonts.inter(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.of(context).size.width / 375).clamp(0.5, 1.5);

    return Container(
      color: const Color(0xFFF9F9F9),
      child: Column(
        children: [
          // App Bar Row
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
                  onPressed: () async {
                    try {
                      final authService = AuthService();
                      await authService.updateProfile(
                        name: _nameController.text.trim(),
                        dateOfBirth: _dobController.text.trim(),
                        sales: _salesNotification,
                        newArrivals: _newArrivalsNotification,
                        deliveryStatus: _deliveryStatusNotification,
                      );
                      final authProvider =
                          Provider.of<AuthProvider>(context, listen: false);
                      await authProvider.checkAuthStatus();
                    } catch (e) {
                      print('>>> Error updating settings profile: $e');
                    }
                    widget.onBack();
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

          // Main Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8 * scale),

                  // Title "Settings"
                  Text(
                    'Settings',
                    style: GoogleFonts.outfit(
                      fontSize: 34 * scale,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF222222),
                    ),
                  ),

                  SizedBox(height: 24 * scale),

                  // Section: Personal Information
                  Text(
                    'Personal Information',
                    style: GoogleFonts.inter(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF222222),
                    ),
                  ),
                  SizedBox(height: 16 * scale),

                  // Full name input
                  _buildInputField(
                    label: 'Full name',
                    controller: _nameController,
                    scale: scale,
                  ),
                  SizedBox(height: 16 * scale),

                  // Date of birth input
                  _buildDobInputField(
                    scale: scale,
                  ),

                  SizedBox(height: 24 * scale),

                  // Section: Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Password',
                        style: GoogleFonts.inter(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF222222),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showChangePasswordBottomSheet(scale),
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          'Change',
                          style: GoogleFonts.inter(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF9B9B9B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * scale),

                  // Password input
                  _buildInputField(
                    label: 'Password',
                    controller: _passwordController,
                    scale: scale,
                    obscureText: true,
                  ),

                  SizedBox(height: 28 * scale),

                  // Section: Notifications
                  Text(
                    'Notifications',
                    style: GoogleFonts.inter(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF222222),
                    ),
                  ),
                  SizedBox(height: 16 * scale),

                  // Notification toggles
                  _buildNotificationToggle(
                    'Sales',
                    _salesNotification,
                    (val) => setState(() => _salesNotification = val),
                    scale,
                  ),
                  SizedBox(height: 12 * scale),
                  _buildNotificationToggle(
                    'New arrivals',
                    _newArrivalsNotification,
                    (val) => setState(() => _newArrivalsNotification = val),
                    scale,
                  ),
                  SizedBox(height: 12 * scale),
                  _buildNotificationToggle(
                    'Delivery status changes',
                    _deliveryStatusNotification,
                    (val) => setState(() => _deliveryStatusNotification = val),
                    scale,
                  ),

                  SizedBox(height: 48 * scale),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required double scale,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      padding:
          EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 8 * scale),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        obscuringCharacter: '*',
        style: GoogleFonts.inter(
          fontSize: 14 * scale,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF222222),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(
            fontSize: 11 * scale,
            color: const Color(0xFF9B9B9B),
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          contentPadding: EdgeInsets.zero,
          filled: false,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(
      String title, bool value, ValueChanged<bool> onChanged, double scale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14 * scale,
            color: const Color(0xFF222222),
            fontWeight: FontWeight.w500,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: const Color(0xFF2AA95C),
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFE0E0E0),
        ),
      ],
    );
  }
}
