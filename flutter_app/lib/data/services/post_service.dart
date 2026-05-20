import '../repositories/post_repository.dart';

class PostService {
  PostService({PostRepository? repository})
    : _repository = repository ?? PostRepository();

  final PostRepository _repository;

  Future<List<dynamic>> getPosts({String sort = 'new'}) =>
      _repository.getPosts(sort: sort);

  Future<void> toggleLike(String postId, String userId) =>
      _repository.toggleLike(postId, userId);

  Future<void> reportPost(String postId, String userId) =>
      _repository.reportPost(postId, userId);

  Future<Map<String, dynamic>> createPost({
    required String userId,
    required String userName,
    required String content,
    required String topic,
  }) => _repository.createPost(
    userId: userId,
    userName: userName,
    content: content,
    topic: topic,
  );

  Future<List<dynamic>> getComments(String postId) =>
      _repository.getComments(postId);

  Future<Map<String, dynamic>> addComment({
    required String postId,
    required String userId,
    required String userName,
    required String content,
  }) => _repository.addComment(
    postId: postId,
    userId: userId,
    userName: userName,
    content: content,
  );

  Future<void> reportComment(String commentId, String userId) =>
      _repository.reportComment(commentId, userId);
}
