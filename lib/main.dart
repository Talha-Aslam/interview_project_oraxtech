import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';
import 'screens/post_list_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AppStateProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Social Posts App',
        theme: AppTheme.appTheme,
        home: const PostListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
