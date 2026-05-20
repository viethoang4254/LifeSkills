import '../../utils/api_service.dart';

class PostRepository {
  Future<List<dynamic>> getPosts({String sort = 'new'}) =>
      ApiService.getPosts(sort: sort);

  Future<void> toggleLike(String postId, String userId) =>
      ApiService.toggleLike(postId, userId);

  Future<void> reportPost(String postId, String userId) =>
      ApiService.reportPost(postId, userId);

  Future<Map<String, dynamic>> createPost({
    required String userId,
    required String userName,
    required String content,
    required String topic,
  }) => ApiService.createPost(
    userId: userId,
    userName: userName,
    content: content,
    topic: topic,
  );

  Future<List<dynamic>> getComments(String postId) =>
      ApiService.getComments(postId);

  Future<Map<String, dynamic>> addComment({
    required String postId,
    required String userId,
    required String userName,
    required String content,
  }) => ApiService.addComment(
    postId: postId,
    userId: userId,
    userName: userName,
    content: content,
  );

  Future<void> reportComment(String commentId, String userId) =>
      ApiService.reportComment(commentId, userId);
}
