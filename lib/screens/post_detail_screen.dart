import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../providers/app_state_provider.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  // Controllers for UI interactions
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _commentsKey = GlobalKey();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Load comments when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppStateProvider>();
      if (!appState.hasCommentsCache(widget.post.id)) {
        appState.fetchComments(widget.post.id);
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _focusCommentInput() {
    _commentFocusNode.requestFocus();
  }

  void _sharePost() {
    final shareText = '''
${widget.post.title}

${widget.post.body}

#FlutterApp #SocialPost
''';

    Share.share(shareText, subject: widget.post.title);
  }

  Future<void> _pickImage() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Camera feature temporarily disabled for build stability'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleCommentSubmit(String commentText) {
    if (commentText.trim().isEmpty) return;
    if (!mounted) return;

    final appState = context.read<AppStateProvider>();
    final comments = appState.getComments(widget.post.id);

    final newComment = Comment(
      id: comments.length + 1,
      postId: widget.post.id,
      name: 'You',
      email: 'user@example.com',
      body: commentText.trim(),
    );

    appState.addComment(widget.post.id, newComment);
    _commentController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment added successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleCommentLike(int commentId) {
    context
        .read<AppStateProvider>()
        .toggleCommentLike(widget.post.id, commentId);
  }

  void _handleCommentDislike(int commentId) {
    context
        .read<AppStateProvider>()
        .toggleCommentDislike(widget.post.id, commentId);
  }

  Widget _buildCommentVoteButton(
      IconData icon, String count, bool isActive, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive
                    ? (icon == Icons.thumb_up || icon == Icons.thumb_up_outlined
                        ? Colors.blue
                        : Colors.red)
                    : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                count,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive
                      ? (icon == Icons.thumb_up ||
                              icon == Icons.thumb_up_outlined
                          ? Colors.blue
                          : Colors.red)
                      : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Post',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPostContent(),
                  const SizedBox(height: 15),
                  _buildEngagementSection(),
                  const SizedBox(height: 10),
                  _buildSortingHeader(),
                  const SizedBox(height: 10),
                  _buildCommentsList(),
                ],
              ),
            ),
          ),
          _buildAddCommentSection(),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.post.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.post.body,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEngagementSection() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final isLiked = appState.isPostLiked(widget.post.id);
        final likeCount = appState.getLikeCount(widget.post.id);
        final commentCount = appState.getCommentCount(widget.post.id);
        const shareCount = 5;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEngagementIcon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                likeCount.toString(),
                isLiked ? Colors.red : Colors.grey[600]!,
                () => appState.toggleLike(widget.post.id),
              ),
              _buildEngagementIcon(
                Icons.chat_rounded,
                commentCount.toString(),
                Colors.grey[600]!,
                _focusCommentInput,
              ),
              _buildEngagementIcon(
                Icons.share_outlined,
                shareCount.toString(),
                Colors.grey[600]!,
                _sharePost,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEngagementIcon(
      IconData icon, String count, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 4),
              Text(
                count,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortingHeader() {
    return Row(
      children: [
        Text(
          'Comments',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const Spacer(),
        Consumer<AppStateProvider>(
          builder: (context, appState, child) {
            final commentCount = appState.getCommentCount(widget.post.id);
            return Text(
              '$commentCount comments',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommentsList() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        if (appState.isLoadingComments(widget.post.id)) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: Colors.black),
            ),
          );
        }

        final error = appState.getCommentsError(widget.post.id);
        if (error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Text(
                    'Failed to load comments',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => appState.fetchComments(widget.post.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final comments = appState.getComments(widget.post.id);
        return Column(
          key: _commentsKey,
          children:
              comments.map((comment) => _buildCommentItem(comment)).toList(),
        );
      },
    );
  }

  Widget _buildCommentItem(Comment comment) {
    final avatarColors = [
      Colors.blue[300]!,
      Colors.green[300]!,
      Colors.orange[300]!,
      Colors.purple[300]!,
      Colors.red[300]!,
    ];

    final avatarColor = avatarColors[comment.id % avatarColors.length];
    final initials = comment.name
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join('')
        .toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: avatarColor,
            child: Text(
              initials.isNotEmpty ? initials : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Consumer<AppStateProvider>(
              builder: (context, appState, child) {
                final isLiked =
                    appState.isCommentLiked(widget.post.id, comment.id);
                final isDisliked =
                    appState.isCommentDisliked(widget.post.id, comment.id);
                final likeCount =
                    appState.getCommentLikeCount(widget.post.id, comment.id);
                final dislikeCount =
                    appState.getCommentDislikeCount(widget.post.id, comment.id);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and time row
                    Row(
                      children: [
                        Text(
                          comment.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '2h',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Comment body
                    Text(
                      comment.body,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Like/Dislike section
                    Row(
                      children: [
                        _buildCommentVoteButton(
                          isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          likeCount.toString(),
                          isLiked,
                          () => _handleCommentLike(comment.id),
                        ),
                        const SizedBox(width: 20),
                        _buildCommentVoteButton(
                          isDisliked
                              ? Icons.thumb_down
                              : Icons.thumb_down_outlined,
                          dislikeCount.toString(),
                          isDisliked,
                          () => _handleCommentDislike(comment.id),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCommentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue[300],
              child: const Text(
                'U',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _commentController,
                focusNode: _commentFocusNode,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: _handleCommentSubmit,
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
