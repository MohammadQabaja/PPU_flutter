import 'package:flutter/material.dart';
import 'package:flutterpro/screens/feeds.dart';
import 'package:flutterpro/services/api_service.dart';

class SectionsScreen extends StatelessWidget {
  final int courseId;
  final String courseName;
  final String instructor;

  const SectionsScreen({Key? key, required this.courseId, required this.courseName, required this.instructor}) : super(key: key);

  Future<List<dynamic>> fetchSections() async {
    try {
      final sections = await ApiService.fetchSections(courseId); 
      return sections;
    } catch (e) {
      throw Exception('Failed to load sections: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$courseName - Sections'), //  المساق في العنوان
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchSections(), // جلب الأقسام
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // عرض دائرة تحميل 
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // عرض رسالة الخطأ
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No sections available.'));
          } else {
            final sections = snapshot.data!;
            return ListView.builder(
              itemCount: sections.length, // عدد الأقسام
              itemBuilder: (context, index) {
                final section = sections[index];
                return ListTile(
                  title: Text(section['name']), 
                  subtitle: Text(
                    'Instructor: ${section['instructor'] ?? "Not Assigned"}\nSection ID: ${section['id']}', 
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FeedsScreen(
                          courseId: courseId,
                          sectionId: section['id'],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
