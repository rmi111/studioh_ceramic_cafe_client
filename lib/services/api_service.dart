import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'dart:convert';
import 'package:flutter/foundation.dart';

// ... other imports ...

class ApiService {
  // TODO: Update this to your production URL
  static const String baseUrl = 'https://studio.tech2view.org';

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: '$baseUrl/api/v1',
    headers: {'Accept': 'application/json'},
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  // ==================== INITIALIZATION ====================

  static String _prettyPrint(dynamic data) {
    if (data == null) return 'null';
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (e) {
      return data.toString();
    }
  }

  /// Call once in main.dart before runApp()
  static void init() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        debugPrint('🚀 API REQUEST[${options.method}] => PATH: ${options.path}');
        debugPrint('   Data: ${_prettyPrint(options.data)}');
        final token = await _storage.read(key: _tokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('✅ API RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        debugPrint('   Data: ${_prettyPrint(response.data)}');
        return handler.next(response);
      },
      onError: (error, handler) {
        debugPrint('❌ API ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
        debugPrint('   Message: ${error.message}');
        debugPrint('   Data: ${_prettyPrint(error.response?.data)}');
        if (error.response?.statusCode == 401) {
          // Token expired or invalid — clear it
          clearToken();
        }
        return handler.next(error);
      },
    ));
  }

  // ==================== TOKEN MANAGEMENT ====================

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<bool> hasToken() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  // ==================== AUTH ====================

  static Future<Response> register({
    required String email,
    required String name,
    String? phoneNumber,
    required String password,
  }) =>
      _dio.post('/auth/register', data: {
        'email': email,
        'name': name,
        'phone_number': phoneNumber,
        'password': password,
      });

  static Future<Response> login({
    required String email,
    required String password,
  }) =>
      _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

  static Future<Response> loginEmail({required String email}) =>
      _dio.post('/auth/login-email', data: {'email': email});

  static Future<Response> logout() => _dio.post('/auth/logout');

  static Future<Response> me() => _dio.get('/auth/me');

  // ==================== USERS ====================

  static Future<Response> listUsers({
    String? type,
    String? search,
    int perPage = 20,
  }) =>
      _dio.get('/users', queryParameters: {
        if (type != null) 'type': type,
        if (search != null && search.isNotEmpty) 'search': search,
        'per_page': perPage,
      });

  static Future<Response> createUser({
    required String email,
    required String name,
    String? phoneNumber,
    String userType = 'customer',
    required String password,
  }) =>
      _dio.post('/users', data: {
        'email': email,
        'name': name,
        'phone_number': phoneNumber,
        'user_type': userType,
        'password': password,
      });

  static Future<Response> showUser(int userId) => _dio.get('/users/$userId');

  static Future<Response> updateUser(
          int userId, Map<String, dynamic> data) =>
      _dio.patch('/users/$userId', data: data);

  // ==================== ORDERS ====================

  static Future<Response> myOrders({String? status, int perPage = 20}) =>
      _dio.get('/orders/my-orders', queryParameters: {
        if (status != null) 'status': status,
        'per_page': perPage,
      });

  static Future<Response> categorizedOrders() =>
      _dio.get('/orders/categorized');

  static Future<Response> searchOrderByRef(String ref) =>
      _dio.get('/orders/search', queryParameters: {'ref': ref});

  static Future<Response> showOrder(String orderRef) =>
      _dio.get('/orders/$orderRef');

  static Future<Response> listOrders({String? status, int perPage = 20}) =>
      _dio.get('/orders', queryParameters: {
        if (status != null) 'status': status,
        'per_page': perPage,
      });

  static Future<Response> generateRef() => _dio.get('/orders/generate-ref');

  static Future<Response> createOrder({
    String? refNumber,
    required String email,
    String? phoneNumber,
    String? name,
    String? description,
  }) =>
      _dio.post('/orders', data: {
        'ref_number': refNumber,
        'email': email,
        'phone_number': phoneNumber,
        'name': name ?? '',
        'description': description ?? '',
      });

  static Future<Response> updateOrderStatus(String orderRef, String status) =>
      _dio.put('/orders/$orderRef/status', data: {'status': status});

  static Future<Response> addParticipant(
    String orderRef, {
    required String email,
    String? name,
    String? phoneNumber,
  }) =>
      _dio.post('/orders/$orderRef/users', data: {
        'email': email,
        'name': name ?? '',
        'phone_number': phoneNumber,
      });

  static Future<Response> addOrderImages(
      String orderRef, List<File> images) async {
    final formData = FormData();
    for (final img in images) {
      formData.files.add(MapEntry(
        'images[]',
        await MultipartFile.fromFile(img.path,
            filename: img.path.split('/').last),
      ));
    }
    return _dio.post('/orders/$orderRef/images', data: formData);
  }

  static Future<Response> deleteOrderImage(String orderRef, int imageId) =>
      _dio.delete('/orders/$orderRef/images/$imageId');

  // ==================== VOUCHERS ====================

  static Future<Response> listVouchers({String? type, int perPage = 20}) =>
      _dio.get('/vouchers', queryParameters: {
        if (type != null) 'type': type,
        'per_page': perPage,
      });

  static Future<Response> showVoucher(String code) =>
      _dio.get('/vouchers/$code');

  static Future<Response> subscriptionVoucher() =>
      _dio.get('/vouchers/subscription');

  static Future<Response> redeemVoucher({
    required String code,
    required String email,
  }) =>
      _dio.post('/vouchers/redeem', data: {
        'code': code,
        'email': email,
      });

  static Future<Response> createVoucher({
    required String type,
    required String value,
    required String description,
    required int expiryDays,
  }) =>
      _dio.post('/vouchers', data: {
        'type': type,
        'value': value,
        'description': description,
        'expiry_days': expiryDays,
      });

  static Future<Response> updateVoucher(
          String code, Map<String, dynamic> data) =>
      _dio.patch('/vouchers/$code', data: data);

  // ==================== ADVERTISEMENTS ====================

  static Future<Response> listAds({String? status}) =>
      _dio.get('/ads', queryParameters: {
        if (status != null) 'status': status,
      });

  static Future<Response> createAd({
    required String title,
    required String body,
    String status = 'draft',
    String? scheduledAt,
    File? image,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'body': body,
      'status': status,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (image != null)
        'image': await MultipartFile.fromFile(image.path),
    });
    return _dio.post('/ads', data: formData);
  }

  static Future<Response> updateAd(
          int adId, Map<String, dynamic> data) =>
      _dio.patch('/ads/$adId', data: data);

  static Future<Response> deleteAd(int adId) => _dio.delete('/ads/$adId');

  // ==================== USER NOTIFICATIONS ====================

  static Future<Response> listNotifications({int perPage = 20}) =>
      _dio.get('/user-notifications',
          queryParameters: {'per_page': perPage});

  static Future<Response> markNotificationRead(String id) =>
      _dio.post('/user-notifications/$id/read');

  static Future<Response> markAllNotificationsRead() =>
      _dio.post('/user-notifications/read-all');

  // ==================== PUSH (FIREBASE) ====================

  static Future<Response> sendPush({
    required String title,
    required String body,
    String? topic,
    Map<String, dynamic>? data,
  }) =>
      _dio.post('/notifications/send', data: {
        'title': title,
        'body': body,
        if (topic != null) 'topic': topic,
        if (data != null) 'data': data,
      });

  // ==================== DEVICES ====================

  static Future<Response> registerDevice({
    required String fcmToken,
    required String platform,
  }) =>
      _dio.post('/devices/register', data: {
        'fcm_token': fcmToken,
        'platform': platform,
      });

  // ==================== UPLOAD ====================

  static Future<Response> uploadImage(File file,
      {String folder = 'uploads'}) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(file.path),
      'folder': folder,
    });
    return _dio.post('/upload/image', data: formData);
  }

  static Future<Response> deleteImage(String url) =>
      _dio.delete('/upload/image', data: {'url': url});

  // ==================== DASHBOARD ====================

  static Future<Response> dashboardStats() => _dio.get('/dashboard/stats');

  static Future<Response> recentOrders() =>
      _dio.get('/dashboard/recent-orders');
}
