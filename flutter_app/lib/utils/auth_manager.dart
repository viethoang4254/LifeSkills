import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static const _keyLoggedIn = 'kns_logged_in';
  static const _keyUserId = 'kns_user_id';
  static const _keyUserName = 'kns_user_name';
  static const _keyUserEmail = 'kns_user_email';
  static const _keyUserRole = 'kns_user_role';
  static const _keyUserAvatar = 'kns_user_avatar';
  static const _keyOnboardingDonePrefix = 'kns_onboarding_done_';
  static const _keyFavoriteSkillsPrefix = 'kns_favorite_skills_';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyUserId, user['id'] ?? '');
    await prefs.setString(_keyUserName, user['name'] ?? '');
    await prefs.setString(_keyUserEmail, user['email'] ?? '');
    await prefs.setString(_keyUserRole, user['role'] ?? 'user');
    await prefs.setString(_keyUserAvatar, user['avatar_url'] ?? '');
  }

  static Future<Map<String, String>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString(_keyUserId) ?? '',
      'name': prefs.getString(_keyUserName) ?? '',
      'email': prefs.getString(_keyUserEmail) ?? '',
      'role': prefs.getString(_keyUserRole) ?? 'user',
      'avatar_url': prefs.getString(_keyUserAvatar) ?? '',
    };
  }

  static String _userScopeKey(String prefix, String userId, String email) {
    final normalizedId = userId.trim();
    if (normalizedId.isNotEmpty) return '$prefix$normalizedId';

    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isNotEmpty) return '$prefix$normalizedEmail';

    return '${prefix}guest';
  }

  static Future<bool> shouldShowFirstLoginOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_keyUserId) ?? '';
    final email = prefs.getString(_keyUserEmail) ?? '';
    final key = _userScopeKey(_keyOnboardingDonePrefix, userId, email);
    return !(prefs.getBool(key) ?? false);
  }

  static Future<void> completeFirstLoginOnboarding({
    List<String>? favoriteSkills,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_keyUserId) ?? '';
    final email = prefs.getString(_keyUserEmail) ?? '';
    final doneKey = _userScopeKey(_keyOnboardingDonePrefix, userId, email);
    await prefs.setBool(doneKey, true);

    if (favoriteSkills != null) {
      final skillsKey = _userScopeKey(_keyFavoriteSkillsPrefix, userId, email);
      await prefs.setStringList(skillsKey, favoriteSkills);
    }
  }

  static Future<List<String>> getFavoriteSkills() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_keyUserId) ?? '';
    final email = prefs.getString(_keyUserEmail) ?? '';
    final key = _userScopeKey(_keyFavoriteSkillsPrefix, userId, email);
    return prefs.getStringList(key) ?? [];
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> updateAvatar(String newUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserAvatar, newUrl);
  }
}
