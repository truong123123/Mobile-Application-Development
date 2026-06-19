import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:le_nhat_truong/features/auth/models/auth_response.dart';
import 'package:le_nhat_truong/features/auth/models/user_response.dart';
import 'package:le_nhat_truong/core/constants/constants.dart';

class AuthService {
  // ───────────── Token helpers ─────────────

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.accessTokenKey);
  }

  Future<void> saveTokens(AuthResponse auth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.accessTokenKey, auth.accessToken);
    await prefs.setString(AppConstants.refreshTokenKey, auth.refreshToken);
    await prefs.setString(AppConstants.userNameKey, auth.name);
    await prefs.setString(AppConstants.userEmailKey, auth.email);
  }

  Future<void> saveOAuth2Tokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.accessTokenKey, accessToken);
    await prefs.setString(AppConstants.refreshTokenKey, refreshToken);
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.accessTokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
    await prefs.remove(AppConstants.userNameKey);
    await prefs.remove(AppConstants.userEmailKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ───────────── API Calls ─────────────

  Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.loginEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final auth = AuthResponse.fromJson(jsonDecode(response.body));
      await saveTokens(auth);
      return auth;
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Đăng nhập thất bại');
    }
  }

  Future<void> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.registerEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Đăng ký thất bại');
    }
  }

  Future<UserResponse> getMe() async {
    final token = await getAccessToken();
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.meEndpoint}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Không thể lấy thông tin user');
    }
  }

  Future<Map<String, dynamic>> getUserProfileStats() async {
    final token = await getAccessToken();
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/api/users/profile-stats'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Không thể lấy thông tin thống kê người dùng');
    }
  }

  Future<void> createRealOrder(Map<String, dynamic> orderPayload) async {
    final token = await getAccessToken();
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/users/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(orderPayload),
    );
    print('>>> createRealOrder statusCode: ${response.statusCode}');
    print('>>> createRealOrder body: ${response.body}');
    if (response.statusCode != 200) {
      try {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(body['message'] ?? 'Không thể tạo đơn hàng trên server (Status: ${response.statusCode})');
      } catch (_) {
        throw Exception('Không thể tạo đơn hàng trên server (Status: ${response.statusCode}, Body: ${response.body})');
      }
    }
  }

  Future<void> updateProfile({
    required String name,
    required String dateOfBirth,
    required bool sales,
    required bool newArrivals,
    required bool deliveryStatus,
  }) async {
    final token = await getAccessToken();
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}/api/users/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'dateOfBirth': dateOfBirth,
        'salesNotification': sales,
        'newArrivalsNotification': newArrivals,
        'deliveryStatusNotification': deliveryStatus,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Cập nhật thông tin cá nhân thất bại');
    }
  }

  Future<List<Map<String, dynamic>>> getUserCards() async {
    final token = await getAccessToken();
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/api/users/cards'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(data);
    } else {
      return [];
    }
  }

  Future<void> addUserCard(String cardType, String lastFour) async {
    final token = await getAccessToken();
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/users/cards'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'cardType': cardType,
        'lastFour': lastFour,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Không thể thêm thẻ thanh toán');
    }
  }

  Future<void> simulateAddOrder() async {
    final token = await getAccessToken();
    await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/users/simulate/order'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<void> simulateAddAddress() async {
    final token = await getAccessToken();
    await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/users/simulate/address'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<void> simulateAddCard() async {
    final token = await getAccessToken();
    await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/users/simulate/card'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<void> simulateAddCoupon() async {
    final token = await getAccessToken();
    await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/users/simulate/coupon'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<void> simulateAddReview() async {
    final token = await getAccessToken();
    await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/users/simulate/review'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<List<Map<String, dynamic>>> getUserAddresses() async {
    final token = await getAccessToken();
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/api/users/addresses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(data);
    } else {
      try {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(body['message'] ?? 'Không thể lấy danh sách địa chỉ');
      } catch (_) {
        throw Exception('Không thể lấy danh sách địa chỉ');
      }
    }
  }

  Future<Map<String, dynamic>> addUserAddress(Map<String, dynamic> data) async {
    final token = await getAccessToken();
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/users/addresses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Không thể thêm địa chỉ');
    }
  }

  Future<Map<String, dynamic>> updateUserAddress(String id, Map<String, dynamic> data) async {
    final token = await getAccessToken();
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}/api/users/addresses/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Không thể cập nhật địa chỉ');
    }
  }

  Future<void> deleteUserAddress(String id) async {
    final token = await getAccessToken();
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/api/users/addresses/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Không thể xóa địa chỉ');
    }
  }

  Future<void> logout() async {
    try {
      final token = await getAccessToken();
      await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.logoutEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (_) {
      // Ignore lỗi mạng, vẫn xóa token local
    } finally {
      await clearTokens();
    }
  }
}
