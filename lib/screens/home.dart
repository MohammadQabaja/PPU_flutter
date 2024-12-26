import 'package:flutter/material.dart';
import 'package:flutterpro/models/course.dart';
import 'package:flutterpro/screens/courses.dart';
import 'package:flutterpro/screens/loginpage.dart';
import 'package:flutterpro/screens/section.dart';
import 'package:flutterpro/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Course> selectedCourses = [];
  List<Course> availableCourses = [];

  // شاشة اختيار الدورات
  void navigateToCourses() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CoursesScreen(
          selectedCourses: selectedCourses,
          availableCourses: availableCourses,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        selectedCourses = List<Course>.from(result['selectedCourses']);
        availableCourses = List<Course>.from(result['availableCourses']);
      });
    }
  }

  void removeCourse(Course course) {
    setState(() {
      if (selectedCourses.contains(course)) {
        selectedCourses.remove(course);

        // مرة واحدة فقط
        if (!availableCourses.any((available) => available.id == course.id)) {
          availableCourses.add(course); // إضافة الدورة إلى availableCourses
        }
      }
    });
  }

  void navigateToSections(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SectionsScreen(
          courseId: course.id,
          courseName: course.name, instructor: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        leading: IconButton(
  icon: const Icon(Icons.logout),
  onPressed: () async {
    await ApiService.logout(); // تسجيل الخروج وإزالة التوكين
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // الذهاب إلى صفحة تسجيل الدخول
    );
  },
),
        actions: [
          IconButton(
            onPressed: navigateToCourses,
            icon: const Icon(Icons.add),
            tooltip: 'Add Courses',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: selectedCourses.isEmpty
                ? const Center(child: Text('No courses added'))
                : ListView.builder(
                    itemCount: selectedCourses.length,
                    itemBuilder: (context, index) {
                      final course = selectedCourses[index];
                      return ListTile(
                        title: Text(course.name),
                        subtitle: Text(course.college ?? ""),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => removeCourse(course),
                        ),
                        onTap: () => navigateToSections(course), 
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
