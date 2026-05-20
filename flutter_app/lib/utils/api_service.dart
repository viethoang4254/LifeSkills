import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum ApiErrorType { network, timeout, server, unknown }

class ApiException implements Exception {
  final String message;
  final ApiErrorType type;
  final String? debugMessage;

  const ApiException(
    this.message, {
    this.type = ApiErrorType.unknown,
    this.debugMessage,
  });

  static String userMessageFor(ApiErrorType type) {
    switch (type) {
      case ApiErrorType.network:
        return 'Không có kết nối internet';
      case ApiErrorType.timeout:
        return 'Kết nối chậm, vui lòng thử lại';
      case ApiErrorType.server:
        return 'Không thể kết nối tới máy chủ';
      case ApiErrorType.unknown:
        return 'Đã có lỗi xảy ra, vui lòng thử lại';
    }
  }

  @override
  String toString() {
    return 'ApiException(type: $type, message: $message, debugMessage: $debugMessage)';
  }
}

class ApiService {
  static const String _baseUrlOverride = String.fromEnvironment('API_BASE_URL');
  static const String _androidLanBaseUrl = String.fromEnvironment(
    'API_BASE_URL_ANDROID',
    defaultValue:
        'https://8951-2402-800-62ee-33d1-451f-5ab4-6496-3a30.ngrok-free.app',
  );
  static const bool _useAndroidEmulatorHost = bool.fromEnvironment(
    'ANDROID_EMULATOR_HOST',
    defaultValue: false,
  );
  static const Duration _requestTimeout = Duration(seconds: 12);

  static String get _baseUrl {
    if (_baseUrlOverride.isNotEmpty) return _baseUrlOverride;
    if (kIsWeb) return 'http://127.0.0.1:8000';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Default to LAN host for physical Android devices.
        // Set --dart-define=ANDROID_EMULATOR_HOST=true for Android emulator.
        return _useAndroidEmulatorHost
            ? 'http://10.0.2.2:8000'
            : _androidLanBaseUrl;
      case TargetPlatform.iOS:
        return 'http://127.0.0.1:8000';
      default:
        return 'http://127.0.0.1:8000';
    }
  }

  static Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  static List<String> get _candidateBaseUrls {
    final urls = <String>[];
    final base = _baseUrl;
    urls.add(base);
    if (base.startsWith('https://')) {
      urls.add(base.replaceFirst('https://', 'http://'));
    }
    return urls.toSet().toList();
  }

  static Future<http.Response> _withFallback(
    Future<http.Response> Function(Uri uri) sender,
    String path,
  ) async {
    Object? lastError;
    ApiErrorType lastErrorType = ApiErrorType.unknown;
    String? lastBaseUrl;

    for (final base in _candidateBaseUrls) {
      lastBaseUrl = base;
      final uri = Uri.parse('$base$path');

      try {
        final response = await sender(uri).timeout(_requestTimeout);
        if (response.statusCode >= 500) {
          lastErrorType = ApiErrorType.server;
          lastError = 'HTTP ${response.statusCode}';
          continue;
        }
        return response;
      } on TimeoutException catch (e) {
        lastError = e;
        lastErrorType = ApiErrorType.timeout;
      } on http.ClientException catch (e) {
        lastError = e;
        lastErrorType = ApiErrorType.network;
      } catch (e) {
        lastError = e;
        lastErrorType = ApiErrorType.unknown;
      }
    }

    debugPrint(
      '[ApiService] Request failed on all bases. '
      'path=$path, triedBases=${_candidateBaseUrls.join(', ')}, '
      'lastBase=$lastBaseUrl, lastError=$lastError',
    );

    throw ApiException(
      ApiException.userMessageFor(lastErrorType),
      type: lastErrorType,
      debugMessage:
          'All candidate base URLs failed. path=$path, triedBases=${_candidateBaseUrls.join(', ')}, lastBase=$lastBaseUrl, lastError=$lastError',
    );
  }

  static Future<http.Response> _get(String path) =>
      _withFallback((uri) => http.get(uri), path);

  static Future<http.Response> _post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) => _withFallback(
    (uri) => http.post(uri, headers: headers, body: body),
    path,
  );

  static Future<http.Response> _put(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      _withFallback((uri) => http.put(uri, headers: headers, body: body), path);

  static Future<http.Response> _delete(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) => _withFallback(
    (uri) => http.delete(uri, headers: headers, body: body),
    path,
  );

  static dynamic _decodeBody(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      return null;
    }
  }

  // ── Auth ──────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await _post(
        '/api/auth/login',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final body = _decodeBody(response);
      if (response.statusCode == 200 && body is Map<String, dynamic>)
        return body;
      if (body is Map && body['detail'] != null) {
        throw ApiException(
          body['detail'].toString(),
          type: ApiErrorType.server,
          debugMessage:
              'login rejected by server: status=${response.statusCode}',
        );
      }
      throw ApiException(
        'Đăng nhập thất bại, vui lòng thử lại',
        type: ApiErrorType.server,
        debugMessage: 'login unexpected status=${response.statusCode}',
      );
    } on ApiException {
      rethrow;
    } catch (e, st) {
      throw ApiException(
        ApiException.userMessageFor(ApiErrorType.unknown),
        type: ApiErrorType.unknown,
        debugMessage: 'login unexpected error: $e\n$st',
      );
    }
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await _post(
        '/api/auth/register',
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );
      final body = _decodeBody(response);
      if (response.statusCode == 200 && body is Map<String, dynamic>)
        return body;
      if (body is Map && body['detail'] != null) {
        throw ApiException(
          body['detail'].toString(),
          type: ApiErrorType.server,
          debugMessage:
              'register rejected by server: status=${response.statusCode}',
        );
      }
      throw ApiException(
        'Đăng ký thất bại, vui lòng thử lại',
        type: ApiErrorType.server,
        debugMessage: 'register unexpected status=${response.statusCode}',
      );
    } on ApiException {
      rethrow;
    } catch (e, st) {
      throw ApiException(
        ApiException.userMessageFor(ApiErrorType.unknown),
        type: ApiErrorType.unknown,
        debugMessage: 'register unexpected error: $e\n$st',
      );
    }
  }

  static Future<String> uploadAvatar(String userId, String filePath) async {
    final request = http.MultipartRequest(
      'POST',
      _uri('/api/users/$userId/avatar'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    final response = await request.send().timeout(_requestTimeout);
    final respStr = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      final body = jsonDecode(respStr);
      return body['avatar_url'] as String;
    }
    throw ApiException('Lỗi tải ảnh lên');
  }

  // ── Content ───────────────────────────────────────────────────────────────
  static Future<List<dynamic>> getSkills() async {
    final response = await _get('/api/skills');
    if (response.statusCode == 200)
      return jsonDecode(utf8.decode(response.bodyBytes)) as List;
    throw ApiException('Lỗi tải danh sách kỹ năng');
  }

  static Future<List<dynamic>> getNews() async {
    final response = await _get('/api/news');
    if (response.statusCode == 200)
      return jsonDecode(utf8.decode(response.bodyBytes)) as List;
    throw ApiException('Lỗi tải danh sách tin tức');
  }

  static Future<List<dynamic>> getFun() async {
    final response = await _get('/api/fun');
    if (response.statusCode == 200)
      return jsonDecode(utf8.decode(response.bodyBytes)) as List;
    throw ApiException('Lỗi tải danh sách vui học');
  }

  // ── Admin Users ───────────────────────────────────────────────────────────
  static Future<List<dynamic>> getAllUsers(String adminId) async {
    final response = await _get('/api/admin/users?admin_id=$adminId');
    if (response.statusCode == 200)
      return jsonDecode(utf8.decode(response.bodyBytes)) as List;
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    throw ApiException(body['detail'] ?? 'Lỗi tải danh sách người dùng');
  }

  static Future<void> setRole(
    String adminId,
    String targetEmail,
    String newRole,
  ) async {
    final response = await _post(
      '/api/admin/set_role',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'admin_id': adminId,
        'target_email': targetEmail,
        'new_role': newRole,
      }),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      throw ApiException(body['detail'] ?? 'Lỗi cập nhật quyền');
    }
  }

  // ── Community ─────────────────────────────────────────────────────────────
  static Future<List<dynamic>> getPosts({String sort = 'new'}) async {
    final response = await _get('/api/community/posts?sort=$sort');
    if (response.statusCode == 200)
      return jsonDecode(utf8.decode(response.bodyBytes)) as List;
    throw ApiException('Lỗi tải bài đăng');
  }

  static Future<Map<String, dynamic>> createPost({
    required String userId,
    required String userName,
    required String content,
    required String topic,
  }) async {
    final response = await _post(
      '/api/community/posts',
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'user_id': userId,
        'user_name': userName,
        'content': content,
        'topic': topic,
      }),
    );
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return body as Map<String, dynamic>;
    throw ApiException(body['detail'] ?? 'Đăng bài thất bại');
  }

  static Future<Map<String, dynamic>> toggleLike(
    String postId,
    String userId,
  ) async {
    final response = await _post(
      '/api/community/posts/$postId/like',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return body as Map<String, dynamic>;
    throw ApiException(body['detail'] ?? 'Lỗi thích bài');
  }

  static Future<List<dynamic>> getComments(String postId) async {
    final response = await _get('/api/community/posts/$postId/comments');
    if (response.statusCode == 200)
      return jsonDecode(utf8.decode(response.bodyBytes)) as List;
    throw ApiException('Lỗi tải bình luận');
  }

  static Future<Map<String, dynamic>> addComment({
    required String postId,
    required String userId,
    required String userName,
    required String content,
  }) async {
    final response = await _post(
      '/api/community/posts/$postId/comments',
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'user_id': userId,
        'user_name': userName,
        'content': content,
      }),
    );

    if (response.statusCode != 200) {
      try {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        throw ApiException(body['detail'] ?? 'Gửi bình luận thất bại');
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException('Lỗi máy chủ (HTTP ${response.statusCode})');
      }
    }
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<void> reportPost(String postId, String userId) async {
    final response = await _post(
      '/api/community/posts/$postId/report',
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'user_id': userId}),
    );
    if (response.statusCode != 200) throw ApiException('Báo cáo thất bại');
  }

  static Future<void> reportComment(String commentId, String userId) async {
    final response = await _post(
      '/api/community/comments/$commentId/report',
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'user_id': userId}),
    );
    if (response.statusCode != 200)
      throw ApiException('Báo cáo bình luận thất bại');
  }

  static Future<void> deletePost(String postId, String adminId) async {
    final response = await _delete(
      '/api/community/posts/$postId?admin_id=$adminId',
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      throw ApiException(body['detail'] ?? 'Lỗi xóa bài');
    }
  }

  // ── Admin Community ───────────────────────────────────────────────────────
  static Future<List<dynamic>> adminGetPosts(String adminId) async {
    final response = await _get('/api/admin/community/posts?admin_id=$adminId');
    if (response.statusCode == 200)
      return jsonDecode(utf8.decode(response.bodyBytes)) as List;
    throw ApiException('Lỗi tải bài đăng');
  }

  static Future<void> toggleHidePost(String postId, String adminId) async {
    final response = await _post(
      '/api/admin/community/posts/$postId/toggle_hide?admin_id=$adminId',
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      throw ApiException(body['detail'] ?? 'Lỗi ẩn/hiện bài');
    }
  }

  // ── Admin CMS — Skills ────────────────────────────────────────────────────
  static Future<void> createSkill({
    required String adminId,
    required String title,
    required String category,
    required String description,
    required String imageUrl,
    required String content,
    required int durationMinutes,
  }) async {
    final response = await _post(
      '/api/admin/skills',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'admin_id': adminId,
        'title': title,
        'category': category,
        'description': description,
        'image_url': imageUrl,
        'content': content,
        'duration_minutes': durationMinutes,
      }),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      throw ApiException(body['detail'] ?? 'Lỗi tạo kỹ năng');
    }
  }

  static Future<void> updateSkill(
    String id, {
    required String adminId,
    required String title,
    required String category,
    required String description,
    required String imageUrl,
    required String content,
    required int durationMinutes,
  }) async {
    final response = await _put(
      '/api/admin/skills/$id',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'admin_id': adminId,
        'title': title,
        'category': category,
        'description': description,
        'image_url': imageUrl,
        'content': content,
        'duration_minutes': durationMinutes,
      }),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      throw ApiException(body['detail'] ?? 'Lỗi cập nhật kỹ năng');
    }
  }

  static Future<void> deleteSkill(String id, String adminId) async {
    final response = await _delete('/api/admin/skills/$id?admin_id=$adminId');
    if (response.statusCode != 200) throw ApiException('Lỗi xóa kỹ năng');
  }

  // ── Admin CMS — News ──────────────────────────────────────────────────────
  static Future<void> createNews({
    required String adminId,
    required String title,
    required String summary,
    required String content,
    required String imageUrl,
    required String author,
  }) async {
    final response = await _post(
      '/api/admin/news',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'admin_id': adminId,
        'title': title,
        'summary': summary,
        'content': content,
        'image_url': imageUrl,
        'author': author,
      }),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      throw ApiException(body['detail'] ?? 'Lỗi tạo tin tức');
    }
  }

  static Future<void> updateNews(
    String id, {
    required String adminId,
    required String title,
    required String summary,
    required String content,
    required String imageUrl,
    required String author,
  }) async {
    final response = await _put(
      '/api/admin/news/$id',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'admin_id': adminId,
        'title': title,
        'summary': summary,
        'content': content,
        'image_url': imageUrl,
        'author': author,
      }),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      throw ApiException(body['detail'] ?? 'Lỗi cập nhật tin tức');
    }
  }

  static Future<void> deleteNews(String id, String adminId) async {
    final response = await _delete('/api/admin/news/$id?admin_id=$adminId');
    if (response.statusCode != 200) throw ApiException('Lỗi xóa tin tức');
  }

  // ── Admin CMS — Fun ───────────────────────────────────────────────────────
  static Future<void> createFun({
    required String adminId,
    required String title,
    required String type,
    required String mediaUrl,
    required String content,
  }) async {
    final response = await _post(
      '/api/admin/fun',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'admin_id': adminId,
        'title': title,
        'type': type,
        'media_url': mediaUrl,
        'content': content,
      }),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      throw ApiException(body['detail'] ?? 'Lỗi tạo nội dung');
    }
  }

  static Future<void> updateFun(
    String id, {
    required String adminId,
    required String title,
    required String type,
    required String mediaUrl,
    required String content,
  }) async {
    final response = await _put(
      '/api/admin/fun/$id',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'admin_id': adminId,
        'title': title,
        'type': type,
        'media_url': mediaUrl,
        'content': content,
      }),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      throw ApiException(body['detail'] ?? 'Lỗi cập nhật nội dung');
    }
  }

  static Future<void> deleteFun(String id, String adminId) async {
    final response = await _delete('/api/admin/fun/$id?admin_id=$adminId');
    if (response.statusCode != 200) throw ApiException('Lỗi xóa nội dung');
  }

  // ── AI Copilot ────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> askAi(String query, String userId) async {
    final response = await _post(
      '/api/ai/chat',
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'query': query, 'user_id': userId}),
    );
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) return body as Map<String, dynamic>;
    throw ApiException(body['detail'] ?? 'Lỗi kết nối AI');
  }
}