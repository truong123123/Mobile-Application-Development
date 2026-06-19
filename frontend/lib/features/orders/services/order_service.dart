import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:le_nhat_truong/core/constants/constants.dart';
import 'package:le_nhat_truong/features/orders/screens/my_orders_screen.dart';

class OrderService {
  Future<List<OrderItemData>> getMyOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.accessTokenKey);
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/api/orders/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => OrderItemData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders: ${response.statusCode}');
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.accessTokenKey);
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}/api/users/orders/$orderId/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'status': status}),
    );

    if (response.statusCode != 200) {
      try {
        final body = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(body['message'] ?? 'Failed to update order status');
      } catch (_) {
        throw Exception('Failed to update order status');
      }
    }
  }
}
