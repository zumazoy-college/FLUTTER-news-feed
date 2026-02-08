import '../models/post.dart';
import '../services/api_service.dart';

class PostRepository {
  final ApiService _apiService = ApiService();
  int _currentPage = 0;
  bool _hasMore = true;
  final List<Post> _posts = [];

  Future<List<Post>> loadPosts() async {
    if (!_hasMore) return _posts;
    
    _currentPage++;
    final newPosts = await _apiService.fetchPosts(_currentPage);
    
    if (newPosts.isEmpty) {
      _hasMore = false;
    } else {
      _posts.addAll(newPosts);
    }
    
    return _posts;
  }

  Future<void> refreshPosts() async {
    _currentPage = 0;
    _hasMore = true;
    _posts.clear();
    await loadPosts();
  }

  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  List<Post> get posts => _posts;
}
