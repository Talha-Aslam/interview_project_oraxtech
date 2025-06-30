import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/api_service.dart';

/// Centralized state management for the entire app
class AppStateProvider extends ChangeNotifier {
  // Posts state
  List<Post> _posts = [];
  bool _isLoadingPosts = false;
  String? _postsError;

  // Comments state (keyed by post ID)
  final Map<int, List<Comment>> _commentsCache = {};
  final Map<int, bool> _loadingComments = {};
  final Map<int, String?> _commentsErrors = {};

  // User interaction state
  final Set<int> _likedPosts = {};
  final Map<int, int> _likeCounts = {};
  final Map<int, int> _commentCounts = {};

  // Comment voting state
  final Map<int, Set<int>> _likedComments =
      {}; // postId -> Set of liked comment IDs
  final Map<int, Set<int>> _dislikedComments =
      {}; // postId -> Set of disliked comment IDs
  final Map<int, Map<int, int>> _commentLikeCounts =
      {}; // postId -> commentId -> like count
  final Map<int, Map<int, int>> _commentDislikeCounts =
      {}; // postId -> commentId -> dislike count

  // Getters for posts
  List<Post> get posts => _posts;
  bool get isLoadingPosts => _isLoadingPosts;
  String? get postsError => _postsError;

  // Getters for comments
  List<Comment> getComments(int postId) => _commentsCache[postId] ?? [];
  bool isLoadingComments(int postId) => _loadingComments[postId] ?? false;
  String? getCommentsError(int postId) => _commentsErrors[postId];

  // Getters for user interactions
  bool isPostLiked(int postId) => _likedPosts.contains(postId);
  int getLikeCount(int postId) => _likeCounts[postId] ?? 67; // Default count
  int getCommentCount(int postId) =>
      _commentCounts[postId] ?? _commentsCache[postId]?.length ?? 0;

  // Getters for comment voting
  bool isCommentLiked(int postId, int commentId) =>
      _likedComments[postId]?.contains(commentId) ?? false;

  bool isCommentDisliked(int postId, int commentId) =>
      _dislikedComments[postId]?.contains(commentId) ?? false;

  int getCommentLikeCount(int postId, int commentId) =>
      _commentLikeCounts[postId]?[commentId] ?? (commentId % 10 + 1);

  int getCommentDislikeCount(int postId, int commentId) =>
      _commentDislikeCounts[postId]?[commentId] ?? (commentId % 3);

  /// Fetch all posts from API
  Future<void> fetchPosts() async {
    _isLoadingPosts = true;
    _postsError = null;
    notifyListeners();

    try {
      final posts = await ApiService.fetchPosts();
      _posts = posts;

      // Initialize like counts for new posts
      for (final post in posts) {
        _likeCounts.putIfAbsent(post.id, () => 67 + (post.id % 50));
      }

      _isLoadingPosts = false;
      notifyListeners();
    } catch (e) {
      _postsError = e.toString();
      _isLoadingPosts = false;
      notifyListeners();
    }
  }

  /// Fetch comments for a specific post
  Future<void> fetchComments(int postId) async {
    _loadingComments[postId] = true;
    _commentsErrors[postId] = null;
    notifyListeners();

    try {
      final comments = await ApiService.fetchComments(postId);
      _commentsCache[postId] = comments;
      _commentCounts[postId] = comments.length;
      _loadingComments[postId] = false;
      notifyListeners();
    } catch (e) {
      _commentsErrors[postId] = e.toString();
      _loadingComments[postId] = false;
      notifyListeners();
    }
  }

  /// Toggle like status for a post
  void toggleLike(int postId) {
    if (_likedPosts.contains(postId)) {
      _likedPosts.remove(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 67) - 1;
    } else {
      _likedPosts.add(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 67) + 1;
    }
    notifyListeners();
  }

  /// Add a new comment to a post
  void addComment(int postId, Comment comment) {
    final comments = _commentsCache[postId] ?? [];
    comments.insert(0, comment); // Add to beginning
    _commentsCache[postId] = comments;
    _commentCounts[postId] = comments.length;
    notifyListeners();
  }

  /// Toggle like status for a comment
  void toggleCommentLike(int postId, int commentId) {
    _likedComments.putIfAbsent(postId, () => <int>{});
    _commentLikeCounts.putIfAbsent(postId, () => <int, int>{});
    _dislikedComments.putIfAbsent(postId, () => <int>{});
    _commentDislikeCounts.putIfAbsent(postId, () => <int, int>{});

    final isCurrentlyLiked = _likedComments[postId]!.contains(commentId);
    final isCurrentlyDisliked = _dislikedComments[postId]!.contains(commentId);

    if (isCurrentlyLiked) {
      // Remove like
      _likedComments[postId]!.remove(commentId);
      _commentLikeCounts[postId]![commentId] =
          (_commentLikeCounts[postId]![commentId] ?? (commentId % 10 + 1)) - 1;
    } else {
      // Add like
      _likedComments[postId]!.add(commentId);
      _commentLikeCounts[postId]![commentId] =
          (_commentLikeCounts[postId]![commentId] ?? (commentId % 10 + 1)) + 1;

      // Remove dislike if it exists
      if (isCurrentlyDisliked) {
        _dislikedComments[postId]!.remove(commentId);
        _commentDislikeCounts[postId]![commentId] =
            (_commentDislikeCounts[postId]![commentId] ?? (commentId % 3)) - 1;
      }
    }
    notifyListeners();
  }

  /// Toggle dislike status for a comment
  void toggleCommentDislike(int postId, int commentId) {
    _likedComments.putIfAbsent(postId, () => <int>{});
    _commentLikeCounts.putIfAbsent(postId, () => <int, int>{});
    _dislikedComments.putIfAbsent(postId, () => <int>{});
    _commentDislikeCounts.putIfAbsent(postId, () => <int, int>{});

    final isCurrentlyLiked = _likedComments[postId]!.contains(commentId);
    final isCurrentlyDisliked = _dislikedComments[postId]!.contains(commentId);

    if (isCurrentlyDisliked) {
      // Remove dislike
      _dislikedComments[postId]!.remove(commentId);
      _commentDislikeCounts[postId]![commentId] =
          (_commentDislikeCounts[postId]![commentId] ?? (commentId % 3)) - 1;
    } else {
      // Add dislike
      _dislikedComments[postId]!.add(commentId);
      _commentDislikeCounts[postId]![commentId] =
          (_commentDislikeCounts[postId]![commentId] ?? (commentId % 3)) + 1;

      // Remove like if it exists
      if (isCurrentlyLiked) {
        _likedComments[postId]!.remove(commentId);
        _commentLikeCounts[postId]![commentId] =
            (_commentLikeCounts[postId]![commentId] ?? (commentId % 10 + 1)) -
                1;
      }
    }
    notifyListeners();
  }

  /// Clear all cached data (useful for logout or refresh)
  void clearCache() {
    _posts.clear();
    _commentsCache.clear();
    _loadingComments.clear();
    _commentsErrors.clear();
    _likedPosts.clear();
    _likeCounts.clear();
    _commentCounts.clear();
    _likedComments.clear();
    _dislikedComments.clear();
    _commentLikeCounts.clear();
    _commentDislikeCounts.clear();
    _isLoadingPosts = false;
    _postsError = null;
    notifyListeners();
  }

  /// Get a specific post by ID
  Post? getPost(int postId) {
    try {
      return _posts.firstWhere((post) => post.id == postId);
    } catch (e) {
      return null;
    }
  }

  /// Check if comments are cached for a post
  bool hasCommentsCache(int postId) => _commentsCache.containsKey(postId);

  /// Refresh posts (pull-to-refresh)
  Future<void> refreshPosts() async {
    await fetchPosts();
  }

  /// Refresh comments for a post
  Future<void> refreshComments(int postId) async {
    await fetchComments(postId);
  }
}
