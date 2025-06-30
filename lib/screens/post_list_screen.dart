import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../providers/app_state_provider.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart' as common;
import 'post_detail_screen.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  @override
  void initState() {
    super.initState();
    // Load posts when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppStateProvider>().fetchPosts();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<AppStateProvider>().refreshPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Threads',
          style: AppConstants.appBarTitleStyle,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black, size: 28),
            onPressed: () {
              // Add post functionality
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        if (appState.isLoadingPosts) {
          return const common.LoadingWidget();
        }

        if (appState.postsError != null) {
          return common.ErrorWidget(
            title: 'Something went wrong',
            message: appState.postsError!,
            onRetry: () => appState.fetchPosts(),
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            itemCount: appState.posts.length,
            itemBuilder: (context, index) {
              final post = appState.posts[index];
              return _buildPostCard(post, index);
            },
          ),
        );
      },
    );
  }

  Widget _buildPostCard(Post post, int index) {
    // Create different avatar colors for variety
    final avatarColor = AppUtils.getAvatarColor(index);

    // Create mock user names
    final userName = AppUtils.getMockUserName(index);

    // Calculate time ago (mock data)
    final timeAgo = AppUtils.getTimeAgo(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(post: post),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: avatarColor,
                child: Text(
                  AppUtils.getUserInitials(userName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User name
                    Text(
                      userName,
                      style: AppConstants.userNameStyle,
                    ),
                    const SizedBox(height: 6),
                    // Post content
                    Text(
                      post.body,
                      style: AppConstants.postBodyStyle.copyWith(fontSize: 15),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Time ago
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 70,
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, true),
          _buildNavItem(Icons.search, false),
          _buildNavItem(Icons.add_box_outlined, false),
          _buildNavItem(Icons.favorite_border, false),
          _buildNavItem(Icons.person_outline, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // we can add navigation functionality here later we are just showing icons for now
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            size: 28,
            color: isSelected ? Colors.black : Colors.grey[400],
          ),
        ),
      ),
    );
  }
}
