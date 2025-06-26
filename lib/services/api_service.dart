import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/comment.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // Fetch all posts
  static Future<List<Post>> fetchPosts() async {
    try {
      final uri = Uri.parse('$baseUrl/posts');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        throw Exception(
            'Access denied. Please check your internet connection or try again later.');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception(
            'Request timeout. Please check your internet connection.');
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }

  // // when we want to Fetch single post by using its ID
  // static Future<Post> fetchPost(int id) async {
  //   try {
  //     final response = await http.get(Uri.parse('$baseUrl/posts/$id'));

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonData = json.decode(response.body);
  //       return Post.fromJson(jsonData);
  //     } else {
  //       throw Exception('Failed to load post: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to load post: $e');
  //   }
  // }

  // Fetch comments for a specific post
  static Future<List<Comment>> fetchComments(int postId) async {
    try {
      final uri = Uri.parse('$baseUrl/posts/$postId/comments');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Comment.fromJson(json)).toList();
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e.toString().contains('403')) {
        throw Exception(
            'Access denied. Please check your internet connection or try again later.');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception(
            'Request timeout. Please check your internet connection.');
      } else {
        throw Exception('Network error: ${e.toString()}');
      }
    }
  }
}
