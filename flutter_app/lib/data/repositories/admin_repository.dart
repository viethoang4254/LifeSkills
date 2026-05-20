import '../../utils/api_service.dart';

class AdminRepository {
  Future<List<dynamic>> getAllUsers(String adminId) =>
      ApiService.getAllUsers(adminId);

  Future<void> setRole({
    required String adminId,
    required String targetEmail,
    required String newRole,
  }) => ApiService.setRole(adminId, targetEmail, newRole);

  Future<List<dynamic>> getSkills() => ApiService.getSkills();

  Future<List<dynamic>> getNews() => ApiService.getNews();

  Future<List<dynamic>> getFun() => ApiService.getFun();

  Future<List<dynamic>> getPosts(String adminId) =>
      ApiService.adminGetPosts(adminId);

  Future<void> toggleHidePost({
    required String postId,
    required String adminId,
  }) => ApiService.toggleHidePost(postId, adminId);

  Future<void> deleteSkill({required String id, required String adminId}) =>
      ApiService.deleteSkill(id, adminId);

  Future<void> deleteNews({required String id, required String adminId}) =>
      ApiService.deleteNews(id, adminId);

  Future<void> deleteFun({required String id, required String adminId}) =>
      ApiService.deleteFun(id, adminId);

  Future<void> deletePost({required String id, required String adminId}) =>
      ApiService.deletePost(id, adminId);

  Future<void> createSkill({
    required String adminId,
    required String title,
    required String category,
    required String description,
    required String imageUrl,
    required String content,
    required int durationMinutes,
  }) => ApiService.createSkill(
    adminId: adminId,
    title: title,
    category: category,
    description: description,
    imageUrl: imageUrl,
    content: content,
    durationMinutes: durationMinutes,
  );

  Future<void> updateSkill({
    required String id,
    required String adminId,
    required String title,
    required String category,
    required String description,
    required String imageUrl,
    required String content,
    required int durationMinutes,
  }) => ApiService.updateSkill(
    id,
    adminId: adminId,
    title: title,
    category: category,
    description: description,
    imageUrl: imageUrl,
    content: content,
    durationMinutes: durationMinutes,
  );

  Future<void> createNews({
    required String adminId,
    required String title,
    required String summary,
    required String content,
    required String imageUrl,
    required String author,
  }) => ApiService.createNews(
    adminId: adminId,
    title: title,
    summary: summary,
    content: content,
    imageUrl: imageUrl,
    author: author,
  );

  Future<void> updateNews({
    required String id,
    required String adminId,
    required String title,
    required String summary,
    required String content,
    required String imageUrl,
    required String author,
  }) => ApiService.updateNews(
    id,
    adminId: adminId,
    title: title,
    summary: summary,
    content: content,
    imageUrl: imageUrl,
    author: author,
  );

  Future<void> createFun({
    required String adminId,
    required String title,
    required String type,
    required String mediaUrl,
    required String content,
  }) => ApiService.createFun(
    adminId: adminId,
    title: title,
    type: type,
    mediaUrl: mediaUrl,
    content: content,
  );

  Future<void> updateFun({
    required String id,
    required String adminId,
    required String title,
    required String type,
    required String mediaUrl,
    required String content,
  }) => ApiService.updateFun(
    id,
    adminId: adminId,
    title: title,
    type: type,
    mediaUrl: mediaUrl,
    content: content,
  );
}
