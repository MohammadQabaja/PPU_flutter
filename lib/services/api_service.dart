import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterpro/models/comment.dart'; // استيراد كلاس Comment

class ApiService {
  static const String baseUrl = "http://feeds.ppu.edu/api/v1/";

  // تسجيل الدخول
  static Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', data['session_token']);
      return data['session_token'];
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Unknown error');
    }
  }

  // جلب قائمة الدورات
  static Future<List<dynamic>> fetchCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception("User not authenticated");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/courses"),
      headers: {"Authorization": token},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['courses'];
    } else {
      throw Exception('Failed to load courses');
    }
  }

  // جلب تفاصيل الدورة
  static Future<Map<String, dynamic>> fetchCourseDetails(int courseId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception("User not authenticated");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/courses/$courseId"),
      headers: {"Authorization": token},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['course'];
    } else {
      throw Exception('Failed to load course details');
    }
  }

  // جلب الأقسام لدورة معينة
static Future<List<dynamic>> fetchSections(int courseId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  
  if (token == null) {
    throw Exception("User not authenticated");
  }

  final response = await http.get(
    Uri.parse('$baseUrl/courses/$courseId/sections'),
    headers: {"Authorization": token},
  );

  if (response.statusCode == 200) {
    final List<dynamic> sections = jsonDecode(response.body)['sections'];
    sections.forEach((section) {
      // إذا لم يكن هناك مدرس، يمكنك تعيين قيمة افتراضية
      section['instructor'] = section['instructor'] ?? 'Not Assigned';
    });
    return sections;
  } else {
    throw Exception('Failed to load sections');
  }
}


  // جلب المنشورات لقسم معين
  static Future<List<dynamic>> fetchPosts(int courseId, int sectionId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception("User not authenticated");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/courses/$courseId/sections/$sectionId/posts"),
      headers: {"Authorization": token},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['posts'];
    } else {
      throw Exception('Failed to load posts');
    }
  }

  // جلب تفاصيل المنشور
  static Future<Map<String, dynamic>> fetchPostDetails(int courseId, int sectionId, int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception("User not authenticated");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/courses/$courseId/sections/$sectionId/posts/$postId'),
      headers: {"Authorization": token},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['post'];
    } else {
      throw Exception('Failed to load post details');
    }
  }

  // جلب التعليقات لمنشور معين
  static Future<List<Comment>> fetchComments(int courseId, int sectionId, int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception("User not authenticated");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/courses/$courseId/sections/$sectionId/posts/$postId/comments'),
      headers: {"Authorization": token},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      if (data['comments'] != null) {
        List<dynamic> commentsData = data['comments'];
        return commentsData.map((comment) => Comment.fromJson(comment)).toList();
      } else {
        throw Exception('No comments found');
      }
    } else {
      throw Exception('Failed to load comments');
    }
  }

  // إرسال تعليق جديد
  static Future<void> postComment(int courseId, int sectionId, int postId, String commentBody) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception("User not authenticated");
    }

    final response = await http.post(
      Uri.parse('$baseUrl/courses/$courseId/sections/$sectionId/posts/$postId/comments'),
      headers: {"Authorization": token, "Content-Type": "application/json"},
      body: jsonEncode({"body": commentBody}),
    );

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to post comment');
    }
  }

 // تعديل التعليق
static Future<void> editComment(int courseId, int sectionId, int postId, int commentId, String newBody) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) {
    throw Exception("User not authenticated");
  }

  final response = await http.put(
    Uri.parse('$baseUrl/courses/$courseId/sections/$sectionId/posts/$postId/comments/$commentId'),
    headers: {"Authorization": token, "Content-Type": "application/json"},
    body: jsonEncode({"body": newBody}),
  );

  if (response.statusCode != 200) {
    final error = jsonDecode(response.body);
    throw Exception(error['error'] ?? 'Failed to edit comment');
  }
}

  // حذف التعليق
static Future<void> deleteComment(int courseId, int sectionId, int postId, int commentId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) {
    throw Exception("User not authenticated");
  }

  final response = await http.delete(
    Uri.parse('$baseUrl/courses/$courseId/sections/$sectionId/posts/$postId/comments/$commentId'),
    headers: {"Authorization": token},
  );

  if (response.statusCode != 200) {
    final error = jsonDecode(response.body);
    throw Exception(error['error'] ?? 'Failed to delete comment');
  }
}

  // جلب الاشتراكات للمستخدم
  static Future<List<dynamic>> fetchSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception("User not authenticated");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/subscriptions"),
      headers: {"Authorization": token},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['subscriptions'];
    } else {
      throw Exception('Failed to load subscriptions');
    }
  }

  // تسجيل الخروج
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
  }
// نشر منشور جديد
  static Future<void> createPost(int courseId, int sectionId, String content) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception("User not authenticated");
    }

    final response = await http.post(
      Uri.parse('$baseUrl/courses/$courseId/sections/$sectionId/posts'),
      headers: {"Authorization": token, "Content-Type": "application/json"},
      body: jsonEncode({"body": content}),
    );

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to post content');
    }
    }

// تعديل المنشور
static Future<void> editPost(int courseId, int sectionId, int postId, String newContent) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) {
    throw Exception("User not authenticated");
  }

  final response = await http.put(
    Uri.parse('$baseUrl/courses/$courseId/sections/$sectionId/posts/$postId'),
    headers: {"Authorization": token, "Content-Type": "application/json"},
    body: jsonEncode({"body": newContent}),
  );

  if (response.statusCode != 200) {
    final error = jsonDecode(response.body);
    throw Exception(error['error'] ?? 'Failed to edit post');
  }
}


// حذف المنشور
static Future<void> deletePost(int courseId, int sectionId, int postId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) {
    throw Exception("User not authenticated");
  }

  final response = await http.delete(
    Uri.parse('$baseUrl/courses/$courseId/sections/$sectionId/posts/$postId'),
    headers: {"Authorization": token},
  );

  if (response.statusCode != 200) {
    final error = jsonDecode(response.body);
    throw Exception(error['error'] ?? 'Failed to delete post');
  }
}
  // إضافة لايك على منشور
  static Future<void> addLike(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception("User not authenticated");
    }

    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/like'),
      headers: {"Authorization": token, "Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to like post');
    }
  }
  // إزالة لايك من منشور
  static Future<void> removeLike(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception("User not authenticated");
    }

    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/unlike'),
      headers: {"Authorization": token, "Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to unlike post');
    }
  
  }
 // جلب عدد اللايكات للمنشور
  static Future<int> fetchLikesCount(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception("User not authenticated");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/posts/$postId/likes'),
      headers: {"Authorization": token},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['likes_count'] ?? 0;
    } else {
      throw Exception('Failed to fetch likes count');
    }
  }

}
