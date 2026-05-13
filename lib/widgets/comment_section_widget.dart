import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/auth_provider.dart';
import '../models/comment_model.dart';
import '../services/comment_service.dart';
import '../utils/theme.dart';

class CommentSectionWidget extends StatefulWidget {
  final String applicationId;

  const CommentSectionWidget({
    super.key,
    required this.applicationId,
  });

  @override
  State<CommentSectionWidget> createState() => _CommentSectionWidgetState();
}

class _CommentSectionWidgetState extends State<CommentSectionWidget> {
  final _commentController = TextEditingController();
  final _commentService = CommentService();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user == null) return;

    final comment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      applicationId: widget.applicationId,
      userId: user.id,
      userName: user.fullNameWithSurname,
      userRole: user.role,
      comment: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    await _commentService.addComment(comment);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comments & Notes',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),

            // Add Comment
            if (user != null) ...[
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send, color: AppTheme.primaryGreen),
                    onPressed: _addComment,
                  ),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16.h),
            ],

            // Comments List
            StreamBuilder<List<CommentModel>>(
              stream: _commentService.getComments(widget.applicationId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      'No comments yet',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return Column(
                  children: snapshot.data!.map((comment) {
                    return _buildCommentItem(comment, user?.id);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment, String? currentUserId) {
    final isOwnComment = comment.userId == currentUserId;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isOwnComment
            ? AppTheme.primaryGreen.withOpacity(0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16.r,
                    backgroundColor: AppTheme.primaryGreen,
                    child: Text(
                      comment.userName.substring(0, 1).toUpperCase(),
                      style: TextStyle(fontSize: 12.sp, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.userName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        comment.userRole.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (isOwnComment)
                IconButton(
                  icon: Icon(Icons.delete, size: 18.sp, color: Colors.red),
                  onPressed: () {
                    _commentService.deleteComment(comment.id);
                  },
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            comment.comment,
            style: TextStyle(fontSize: 14.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            _formatTime(comment.createdAt),
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

