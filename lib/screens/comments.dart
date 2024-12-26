import 'package:flutter/material.dart';
import 'package:flutterpro/services/api_service.dart';
import 'package:flutterpro/models/comment.dart'; // استيراد نموذج Comment

class CommentsPage extends StatefulWidget {
  final int courseId;
  final int sectionId;
  final int postId;

  const CommentsPage({
    Key? key,
    required this.courseId,
    required this.sectionId,
    required this.postId,
  }) : super(key: key);

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  late Future<List<Comment>> _commentsFuture;
  TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;
  List<Comment> _comments = [];
  int _likesCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchComments();
    _fetchLikesCount();
  }

  Future<void> _fetchComments() async {
    try {
      List<Comment> comments = await ApiService.fetchComments(
        widget.courseId,
        widget.sectionId,
        widget.postId,
      );
      setState(() {
        _comments = comments;
      });
    } catch (error) {
      print("Error fetching comments: $error");
    }
  }

  Future<void> _fetchLikesCount() async {
    try {
      int likes = await ApiService.fetchLikesCount(widget.postId);
      setState(() {
        _likesCount = likes;
      });
    } catch (error) {
      print("Error fetching likes count: $error");
    }
  }

  Future<void> _likePost() async {
    try {
      await ApiService.addLike(widget.postId);
      setState(() {
        _likesCount++;
      });
    } catch (error) {
      print("Error liking post: $error");
    }
  }

  Future<void> _unlikePost() async {
    try {
      await ApiService.removeLike(widget.postId);
      setState(() {
        _likesCount--;
      });
    } catch (error) {
      print("Error unliking post: $error");
    }
  }

  Future<void> _editComment(int commentId, String newBody) async {
    try {
      await ApiService.editComment(
        widget.courseId,
        widget.sectionId,
        widget.postId,
        commentId,
        newBody,
      );
      setState(() {
        // Update the comment in the list
        _comments = _comments.map((comment) {
          if (comment.id == commentId) {
            comment.body = newBody;
          }
          return comment;
        }).toList();
      });
    } catch (error) {
      print("Error editing comment: $error");
    }
  }

  Future<void> _deleteComment(int commentId) async {
    try {
      await ApiService.deleteComment(
        widget.courseId,
        widget.sectionId,
        widget.postId,
        commentId,
      );
      setState(() {
        _comments.removeWhere((comment) => comment.id == commentId);
      });
    } catch (error) {
      print("Error deleting comment: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up),
                  onPressed: _likesCount > 0 ? _unlikePost : _likePost,
                ),
                Text('Likes: $_likesCount'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return ListTile(
                  title: Text(comment.body),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Author: ${comment.author}'),
                      Text('Date Posted: ${comment.datePosted}'),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          // Open a dialog to edit the comment
                          String newBody = await _showEditDialog(comment.body);
                          if (newBody.isNotEmpty) {
                            _editComment(comment.id, newBody);
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteComment(comment.id);
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
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: _isLoading
                      ? CircularProgressIndicator()
                      : Icon(Icons.send),
                  onPressed: _isLoading ? null : _postComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _postComment() async {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ApiService.postComment(
          widget.courseId,
          widget.sectionId,
          widget.postId,
          _commentController.text,
        );
        setState(() {
          _comments.insert(
            0,
            Comment(
              id: _comments.length + 1,
              author: 'You',
              body: _commentController.text,
              datePosted: DateTime.now().toString(),
              likesCount: 0,
            ),
          );
          _isLoading = false;
          _commentController.clear();
        });
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        print("Error posting comment: $error");
      }
    }
  }

  Future<String> _showEditDialog(String currentBody) async {
    TextEditingController controller = TextEditingController(text: currentBody);
    String newBody = currentBody;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Comment'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Edit your comment...',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              newBody = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    return newBody;
  }
}
