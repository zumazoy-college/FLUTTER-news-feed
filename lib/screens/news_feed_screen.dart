import 'package:flutter/material.dart';
import '../widgets/post_card.dart';
import '../repositories/post_repository.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final PostRepository _postRepository = PostRepository();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isInitialLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadInitialPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialPosts() async {
    setState(() {
      _isInitialLoading = true;
      _errorMessage = '';
    });

    try {
      await _postRepository.loadPosts();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load posts. Please try again.';
      });
    } finally {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading || !_postRepository.hasMore) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _postRepository.loadPosts();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load more posts';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _errorMessage = '';
    });
    await _postRepository.refreshPosts();
    setState(() {});
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Feed'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _postRepository.posts.length + 1,
                      itemBuilder: (context, index) {
                        if (index < _postRepository.posts.length) {
                          return PostCard(post: _postRepository.posts[index]);
                        } else if (_isLoading) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else if (!_postRepository.hasMore) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'No more posts to load',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.red[50],
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[400]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                          TextButton(
                            onPressed: _loadMorePosts,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
