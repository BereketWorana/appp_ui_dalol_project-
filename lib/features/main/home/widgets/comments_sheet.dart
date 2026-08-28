import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../data/models/comment.dart';
import '../../../../data/services/post_service.dart';
import '../providers/feed_provider.dart';

class CommentsSheet extends StatefulWidget {
  final int postId;

  const CommentsSheet({super.key, required this.postId});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  
  List<Comment> _comments = [];
  bool _isLoading = true;
  String? _error;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final comments = await PostService.getComments(widget.postId);
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load comments';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSubmitting) return;

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
    });

    // Optimistic comment creation
    final optimisticComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch,
      postId: widget.postId,
      userId: 1, // mock
      userName: 'Current User',
      userAvatar: 'assets/images/r1.jpg',
      text: text,
      createdAt: DateTime.now(),
    );

    setState(() {
      _comments.insert(0, optimisticComment);
      _commentController.clear();
    });

    // Increment count in feed provider
    final feedProvider = context.read<FeedProvider>();
    feedProvider.incrementCommentCount(widget.postId);

    try {
      // Simulate API call
      await PostService.submitComment(widget.postId, text);
    } catch (e) {
      // Rollback
      if (mounted) {
        setState(() {
          _comments.removeWhere((c) => c.id == optimisticComment.id);
          _commentController.text = text; // restore text
        });
        
        // Revert count
        feedProvider.decrementCommentCount(widget.postId);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to post comment. Try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.85,
      minChildSize: 0.4,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Drag handle
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                "Comments",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

              // Comments List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.black))
                    : _error != null
                        ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                        : _comments.isEmpty
                            ? const Center(
                                child: Text(
                                  'No comments yet. Be the first to comment!',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              )
                            : ListView.builder(
                                controller: controller,
                                padding: const EdgeInsets.all(16),
                                itemCount: _comments.length,
                                itemBuilder: (context, index) {
                                  final comment = _comments[index];
                                  return CommentItem(comment: comment);
                                },
                              ),
              ),

              // Comment input
              Container(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.black12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          hintText: "Add comment...",
                          hintStyle: TextStyle(color: Colors.black45),
                          filled: true,
                          fillColor: Color(0xFFF2F2F2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onSubmitted: (_) => _submitComment(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _submitComment,
                      child: CircleAvatar(
                        backgroundColor: _isSubmitting ? Colors.grey : Colors.black,
                        child: _isSubmitting 
                            ? const SizedBox(
                                width: 20, 
                                height: 20, 
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              )
                            : const Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CommentItem extends StatelessWidget {
  final Comment comment;

  const CommentItem({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
            child: ClipOval(
              child: comment.userAvatar.startsWith('assets') 
              ? Image.asset(comment.userAvatar, fit: BoxFit.cover)
              : CachedNetworkImage(
                  imageUrl: comment.userAvatar,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const CircularProgressIndicator(),
                  errorWidget: (_, __, ___) => const Icon(Icons.person, color: Colors.white),
                ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.userName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  comment.text,
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
