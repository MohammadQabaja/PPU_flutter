import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterpro/services/api_service.dart';
import 'comments.dart';

class FeedsScreen extends StatefulWidget {
  final int courseId;
  final int sectionId;

  const FeedsScreen({Key? key, required this.courseId, required this.sectionId})
      : super(key: key);

  @override
  State<FeedsScreen> createState() => _FeedsScreenState();
}

class _FeedsScreenState extends State<FeedsScreen> {
  late Future<List<dynamic>> _posts; // منشورات الدورة
  TextEditingController _postController = TextEditingController(); 
  bool _isPosting = false;
  List<dynamic> _postList = []; 

  @override
  void initState() {
    super.initState();
    _fetchPosts(); 
  }

  // جلب المنشورات من API
  void _fetchPosts() async {
    final posts = await ApiService.fetchPosts(
        widget.courseId, widget.sectionId); 
    setState(() {
      _postList = posts;
    });
  }

  void _navigateToComments(int postId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsPage(
          courseId: widget.courseId,
          sectionId: widget.sectionId,
          postId: postId,
        ),
      ),
    );
  }

  // حذف المنشور
  Future<void> _deletePost(int postId) async {
    try {
      await ApiService.deletePost(widget.courseId, widget.sectionId, postId);
      setState(() {
        _postList.removeWhere((post) => post['id'] == postId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post deleted successfully')),
      );
    } catch (error) {
      print("Error deleting post: $error");
    }
  }

  // تأكيد الحذف
  void _showDeletePostDialog(int postId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Post"),
          content: const Text("Are you sure you want to delete this post?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deletePost(postId); 
                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  String _getInitials(String name) {
    if (name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    return '';
  }

  // تعديل المنشور
  void _showEditPostDialog(int postId, String currentContent) {
    TextEditingController _editController = TextEditingController(text: currentContent);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Post"),
          content: TextField(
            controller: _editController,
            decoration: const InputDecoration(hintText: "Edit your post..."),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // إرسال التعديل عبر API
                await _editPost(postId, _editController.text);
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // تعديل المنشور عبر API
  Future<void> _editPost(int postId, String newContent) async {
    try {
      await ApiService.editPost(widget.courseId, widget.sectionId, postId, newContent);
      // تحديث المنشور في القائمة بعد التعديل
      setState(() {
        _postList = _postList.map((post) {
          if (post['id'] == postId) {
            post['body'] = newContent;  
          }
          return post;
        }).toList();
      });
    } catch (error) {
      print("Error editing post: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Feed'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _postList.length,
              itemBuilder: (context, index) {
                final post = _postList[index];
                String authorName = post['author'] ?? 'Unknown'; 
                String avatarInitials = _getInitials(authorName);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      avatarInitials,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(authorName), 
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(post['body'] ?? 'No content'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          _navigateToComments(post['id']);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditPostDialog(post['id'], post['body']);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _showDeletePostDialog(post['id']);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _postController,
                    decoration: InputDecoration(
                      hintText: 'Write a post...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: _isPosting
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                  onPressed: _isPosting ? null : _postNewPost,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _postNewPost() async {
    if (_postController.text.isNotEmpty) {
      setState(() {
        _isPosting = true;
      });

      try {
        await ApiService.createPost(
          widget.courseId,
          widget.sectionId,
          _postController.text,
        );

        setState(() {
          _postList.insert(0, {
            'title': _postController.text,
            'body': _postController.text,
            'id': DateTime.now().millisecondsSinceEpoch, // مثال على معرف مؤقت
            'author': 'John Doe',  // اسم الناشر (مثال)
            'avatar': 'John Doe', // اسم الناشر لاستخدام أول حرف في اللوجو
          });
          _postController.clear(); // مسح النص بعد النشر
        });

        _fetchPosts();
        setState(() {
          _isPosting = false;
        });
      } catch (error) {
        setState(() {
          _isPosting = false;
        });
        print("Error posting new post: $error");
      }
    }
  }
}
