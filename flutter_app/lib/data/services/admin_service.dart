import '../repositories/admin_repository.dart';

class AdminService {
  AdminService({AdminRepository? repository})
    : _repository = repository ?? AdminRepository();

  final AdminRepository _repository;

  Future<List<dynamic>> getAllUsers(String adminId) =>
      _repository.getAllUsers(adminId);

  Future<void> setRole({
    required String adminId,
    required String targetEmail,
    required String newRole,
  }) => _repository.setRole(
    adminId: adminId,
    targetEmail: targetEmail,
    newRole: newRole,
  );

  Future<List<dynamic>> getSkills() => _repository.getSkills();

  Future<List<dynamic>> getNews() => _repository.getNews();

  Future<List<dynamic>> getFun() => _repository.getFun();

  Future<List<dynamic>> getPosts(String adminId) =>
      _repository.getPosts(adminId);

  Future<void> toggleHidePost({
    required String postId,
    required String adminId,
  }) => _repository.toggleHidePost(postId: postId, adminId: adminId);

  Future<void> deleteSkill({required String id, required String adminId}) =>
      _repository.deleteSkill(id: id, adminId: adminId);

  Future<void> deleteNews({required String id, required String adminId}) =>
      _repository.deleteNews(id: id, adminId: adminId);

  Future<void> deleteFun({required String id, required String adminId}) =>
      _repository.deleteFun(id: id, adminId: adminId);

  Future<void> deletePost({required String id, required String adminId}) =>
      _repository.deletePost(id: id, adminId: adminId);

  Future<void> createSkill({
    required String adminId,
    required String title,
    required String category,
    required String description,
    required String imageUrl,
    required String content,
    required int durationMinutes,
  }) => _repository.createSkill(
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
  }) => _repository.updateSkill(
    id: id,
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
  }) => _repository.createNews(
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
  }) => _repository.updateNews(
    id: id,
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
  }) => _repository.createFun(
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
  }) => _repository.updateFun(
    id: id,
    adminId: adminId,
    title: title,
    type: type,
    mediaUrl: mediaUrl,
    content: content,
  );
}
