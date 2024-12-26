import 'package:flutter/material.dart';
import 'package:flutterpro/screens/loginpage.dart';
import 'package:flutterpro/screens/home.dart';
import 'package:flutterpro/screens/courses.dart';
import 'package:flutterpro/screens/feeds.dart';
import 'package:flutterpro/screens/comments.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PPU Feed',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(), // root
        '/home': (context) => HomeScreen(),
        '/courses': (context) => CoursesScreen(
              selectedCourses: [],
              availableCourses: [],
            ),
        '/feeds': (context) => FeedsScreen(courseId: 1, sectionId: 1),

        '/comments': (context) => CommentsPage(
              courseId: 1,
              sectionId: 1,
              postId: 1,
            ),
      },
    );
  }
}
