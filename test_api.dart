import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> testApi() async {
  try {
    print('Testing JSONPlaceholder API...');
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
      headers: {'Accept': 'application/json'},
    );

    print('Status Code: ${response.statusCode}');
    print('Response: ${response.body.substring(0, 100)}...');

    if (response.statusCode == 200) {
      print('✅ API is working!');
    } else {
      print('❌ API returned status: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}

void main() {
  testApi();
}
