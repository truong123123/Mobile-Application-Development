import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:le_nhat_truong/features/shop/models/product.dart';
import 'package:le_nhat_truong/features/shop/models/category.dart';
import 'package:le_nhat_truong/core/constants/constants.dart';

import 'package:le_nhat_truong/features/shop/models/rating_summary.dart';

class ProductService {
  Future<RatingSummary?> getRatingSummary(String productId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${AppConstants.baseUrl}/api/reviews/product/$productId/summary'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            jsonDecode(utf8.decode(response.bodyBytes));
        return RatingSummary.fromJson(body);
      } else {
        return null;
      }
    } catch (e) {
      print('>>> Error getting rating summary: $e');
      return null;
    }
  }

  Future<List<Product>> getSaleProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/products/sale'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Không thể lấy danh sách sản phẩm giảm giá');
      }
    } catch (e) {
      print('>>> Error getting sale products: $e');
      return [];
    }
  }

  Future<List<Product>> getNewProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/products/new'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Không thể lấy danh sách sản phẩm mới');
      }
    } catch (e) {
      print('>>> Error getting new products: $e');
      return [];
    }
  }

  Future<List<Product>> getProductsByTag(String tagName) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/products/tag/$tagName'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Không thể lấy danh sách sản phẩm theo tag $tagName');
      }
    } catch (e) {
      print('>>> Error getting products by tag $tagName: $e');
      return [];
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((item) => CategoryModel.fromJson(item)).toList();
      } else {
        throw Exception('Không thể lấy danh sách danh mục');
      }
    } catch (e) {
      print('>>> Error getting categories: $e');
      return [];
    }
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/products/category/$categoryId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Không thể lấy danh sách sản phẩm theo danh mục');
      }
    } catch (e) {
      print('>>> Error getting products by category $categoryId: $e');
      return [];
    }
  }

  Future<List<Product>> getAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/products'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Không thể lấy danh sách tất cả sản phẩm');
      }
    } catch (e) {
      print('>>> Error getting all products: $e');
      return [];
    }
  }

  Future<Product> createProduct(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      final decoded = utf8.decode(response.bodyBytes);
      String errMsg = 'Thêm sản phẩm thất bại';
      try {
        final body = jsonDecode(decoded);
        errMsg = body['message'] ?? errMsg;
      } catch (_) {}
      throw Exception(errMsg);
    }
  }

  Future<Product> updateProduct(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}/api/products/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      final decoded = utf8.decode(response.bodyBytes);
      String errMsg = 'Cập nhật sản phẩm thất bại';
      try {
        final body = jsonDecode(decoded);
        errMsg = body['message'] ?? errMsg;
      } catch (_) {}
      throw Exception(errMsg);
    }
  }

  Future<void> deleteProduct(String id) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/api/products/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Xóa sản phẩm thất bại');
    }
  }

  Future<List<Map<String, dynamic>>> getProductReviews(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/reviews/product/$productId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return List<Map<String, dynamic>>.from(body);
      } else {
        return [];
      }
    } catch (e) {
      print('>>> Error getting product reviews: $e');
      return [];
    }
  }

  Future<bool> createReview(
      String productId, int rating, String content, List<String> photos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.accessTokenKey);
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/reviews/product/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'rating': rating,
          'content': content,
          'photos': photos,
        }),
      );

      print('>>> createReview statusCode: ${response.statusCode}');
      print('>>> createReview body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('>>> Error creating review: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getMyReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.accessTokenKey);
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/reviews/my'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return List<Map<String, dynamic>>.from(body);
      } else {
        return [];
      }
    } catch (e) {
      print('>>> Error getting my reviews: $e');
      return [];
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/products/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        return Product.fromJson(body);
      } else {
        return null;
      }
    } catch (e) {
      print('>>> Error getting product by id: $e');
      return null;
    }
  }
}
