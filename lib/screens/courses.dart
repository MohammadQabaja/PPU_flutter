import 'package:flutter/material.dart';
import 'package:flutterpro/models/course.dart';
import 'package:flutterpro/services/api_service.dart';

class CoursesScreen extends StatefulWidget {
  final List<Course> selectedCourses;
  final List<Course> availableCourses;

  CoursesScreen(
      {required this.selectedCourses, required this.availableCourses});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  late List<Course> courses;
  bool isLoading = true;
  final Set<Course> tempSelectedCourses =
      {}; // Temporary selection for CheckBox

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    try {
      final fetchedCourses = await ApiService.fetchCourses();
      setState(() {
        courses = fetchedCourses.map((data) => Course.fromJson(data as Map<String, dynamic>)).toList();

        // إزالة المساقات التي تم اختيارها بالفعل
        courses.removeWhere((course) =>
            widget.selectedCourses.any((selected) => selected.id == course.id));

        // إضافة المساقات التي تم إرجاعها من HomeScreen إلى availableCourses
        courses.addAll(widget.availableCourses); // إعادة تحميل المساقات المتاحة
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching courses: $error");
    }
  }

  void toggleSelection(Course course, bool isSelected) {
    setState(() {
      if (isSelected) {
        tempSelectedCourses.add(course);
      } else {
        tempSelectedCourses.remove(course);
      }
    });
  }

  void confirmSelection() {
    setState(() {
      widget.availableCourses
          .removeWhere((course) => tempSelectedCourses.contains(course));
      widget.selectedCourses.addAll(tempSelectedCourses);
      tempSelectedCourses.clear();
    });
    Navigator.pop(context, {
      'selectedCourses': widget.selectedCourses,
      'availableCourses': widget.availableCourses,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Courses"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return ListTile(
                  title: Text(course.name),
                  subtitle: Text(course.college ?? ""),
                  trailing: Checkbox(
                    value: tempSelectedCourses.contains(course),
                    onChanged: (isSelected) =>
                        toggleSelection(course, isSelected ?? false),
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: tempSelectedCourses.isEmpty ? null : confirmSelection,
          child: const Text("Confirm Selection"),
        ),
      ),
    );
  }
}
