import 'package:dio/dio.dart';
import '../models/post.dart';

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const int _postsPerPage = 10;
  final Dio _dio;

  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  )) {
    // Добавляем логирование запросов
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<List<Post>> fetchPosts(int page) async {
    // Имитация задержки сети
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final response = await _dio.get(
        '/posts',
        queryParameters: {
          '_page': page,
          '_limit': _postsPerPage,
        },
        options: Options(
          // Отключаем кэширование
          headers: {'Cache-Control': 'no-cache'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      // Fallback на мок данные если API не доступен
      return _generateMockPosts(page);
    }
  }

  List<Post> _generateMockPosts(int page) {
    final startIndex = (page - 1) * _postsPerPage;
    return List.generate(_postsPerPage, (index) {
      final id = startIndex + index + 1;
      return Post(
        id: id,
        title: 'Mock Post Title #$id (Page $page)',
        body: 'This is a mock post content for post #$id. '
            'This is used when the API is not available.',
        userId: (id % 10) + 1,
        date: DateTime.now().subtract(Duration(days: id)),
      );
    });
  }
}
