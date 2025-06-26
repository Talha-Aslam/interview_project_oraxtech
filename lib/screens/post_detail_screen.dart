import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:image_picker/image_picker.dart';  // Temporarily commented
import '../models/post.dart';
import '../models/comment.dart';
import '../services/api_service.dart';

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
  List<Comment> _comments = [];
  bool _isLoadingComments = true;
  String? _errorMessage;
  bool _isLiked = false;
  int _likeCount = 67;
  int _commentCount = 32;
  final int _shareCount = 5;

  // ScrollController to control scrolling to comments
  final ScrollController _scrollController = ScrollController();
  // GlobalKey to find the comments section
  final GlobalKey _commentsKey = GlobalKey();
  // Controller for the comment input field
  final TextEditingController _commentController = TextEditingController();
  // FocusNode for the comment input field
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoadingComments = true;
        _errorMessage = null;
      });

      final comments = await ApiService.fetchComments(widget.post.id);
      if (!mounted) return;
      setState(() {
        _comments = comments;
        _commentCount = comments.length;
        _isLoadingComments = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoadingComments = false;
      });
    }
  }

  void _toggleLike() {
    if (!mounted) return;
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  void _focusCommentInput() {
    // Focus on the comment input field to encourage user interaction
    _commentFocusNode.requestFocus();
  }

  void _sharePost() {
    final shareText = '''
${widget.post.title}

${widget.post.body}

#FlutterApp #SocialPost
''';

    Share.share(
      shareText,
      subject: widget.post.title,
    );
  }

  Future<void> _pickImage() async {
    // Temporarily simplified camera functionality
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

    // Create a new comment object (simulated)
    final newComment = Comment(
      id: _comments.length + 1,
      postId: widget.post.id,
      name: 'You', // In a real app, this would be the current user's name
      email: 'user@example.com', // Current user's email
      body: commentText.trim(),
    );

    // Add the comment to the list
    setState(() {
      _comments.insert(
          0, newComment); // Add at the beginning for latest-first order
      _commentCount++;
    });

    // Clear the input field
    _commentController.clear();

    // Show feedback to user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment added successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
                  const SizedBox(height: 24),
                  _buildEngagementSection(),
                  const SizedBox(height: 24),
                  _buildSortingHeader(),
                  const SizedBox(height: 16),
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
        // Title
        Text(
          widget.post.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        // Body
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Heart icon - clickable
        _buildEngagementIcon(
          _isLiked ? Icons.favorite : Icons.favorite_border,
          _likeCount.toString(),
          _isLiked ? Colors.red : Colors.grey[600]!,
          () {
            _toggleLike();
          },
        ),
        // Message icon - clickable and functional
        _buildEngagementIcon(
          Icons.chat_bubble_outline,
          _commentCount.toString(),
          Colors.grey[600]!,
          () {
            _focusCommentInput();
          },
        ),
        // Share icon - clickable
        _buildEngagementIcon(
          Icons.share_outlined,
          _shareCount.toString(),
          Colors.grey[600]!,
          () {
            _sharePost();
          },
        ),
      ],
    );
  }

  Widget _buildEngagementIcon(
      IconData icon, String count, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                count,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
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
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // You can implement a bottom sheet with sort options here
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Most Relevant',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey[700],
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsList() {
    if (_isLoadingComments) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: Colors.black),
        ),
      );
    }

    if (_errorMessage != null) {
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
                onPressed: _loadComments,
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

    return Column(
      key: _commentsKey,
      children: _comments.map((comment) => _buildCommentItem(comment)).toList(),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    // Create avatar colors and names for comments
    final avatarColors = [
      Colors.blue[300]!,
      Colors.green[300]!,
      Colors.orange[300]!,
      Colors.purple[300]!,
      Colors.red[300]!,
    ];

    final userNames = [
      'Sophia Clark',
      'Ethan Carter',
      'Olivia Bennett',
      'Liam Davis',
      'Ava Johnson',
    ];

    final index = comment.id % avatarColors.length;
    final avatarColor = avatarColors[index];
    final userName = userNames[index];

    // Mock engagement data
    final likeCount = (comment.id * 5) % 30 + 5;
    final dislikeCount = (comment.id * 2) % 5;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar - clickable
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // User avatar tap functionality can be implemented here
              },
              borderRadius: BorderRadius.circular(20),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: avatarColor,
                child: Text(
                  userName.split(' ').map((e) => e[0]).join(''),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User name and date - clickable
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // User name tap functionality can be implemented here
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Nov 12',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Comment text
                Text(
                  comment.body,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                // Like/dislike buttons - clickable
                Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Comment like functionality can be implemented here
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          child: Row(
                            children: [
                              Icon(
                                Icons.thumb_up_outlined,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                likeCount.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Comment dislike functionality can be implemented here
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          child: Row(
                            children: [
                              Icon(
                                Icons.thumb_down_outlined,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dislikeCount.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // User avatar - non-clickable
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[300],
            child: Icon(
              Icons.person,
              color: Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Comment input - functional text field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _commentController,
                focusNode: _commentFocusNode,
                decoration: InputDecoration(
                  hintText: 'Add a comment',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: _handleCommentSubmit,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Camera button - clickable
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _pickImage();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
