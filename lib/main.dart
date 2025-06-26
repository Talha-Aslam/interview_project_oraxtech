import 'package:flutter/material.dart';
import 'screens/post_list_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Posts App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'System',
        useMaterial3: true,
      ),
      home: const PostListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
