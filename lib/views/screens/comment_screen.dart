import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants.dart';
import 'package:tiktok_clone/controllers/comment_controller.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentScreen extends StatelessWidget {
  final String id;
  CommentScreen({Key? key, required this.id}) : super(key: key);
  final TextEditingController _commentController = TextEditingController();
  CommentController commentController = Get.put(CommentController());

  var appBar = AppBar(
    title: Text('Comments'),
    backgroundColor: Colors.transparent,
  );

  @override
  Widget build(BuildContext context) {
    commentController.updatePostId(id);
    final size = MediaQuery.of(context).size;

    var _pageSize = MediaQuery.of(context).size.height;
    var _notifySize = MediaQuery.of(context).padding.top;
    var _appBarSize = appBar.preferredSize.height;
    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        child: SizedBox(
          width: size.width,
          height: _pageSize - (_appBarSize + _notifySize),
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  return ListView.builder(
                      itemCount: commentController.commentList.length,
                      itemBuilder: ((context, index) {
                        final comment = commentController.commentList[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: backgroundColor,
                            backgroundImage: NetworkImage(comment.profilePhoto),
                          ),
                          title: Row(
                            children: [
                              Text(comment.username + "  ",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w700)),
                              Text(comment.comment,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400)),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                  timeago
                                      .format(comment.datePublished.toDate()),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Text('${comment.likes.length} likes',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12))
                            ],
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              commentController.likeComment(comment.id);
                            },
                            icon: Icon(Icons.favorite,
                                size: 25,
                                color: comment.likes
                                        .contains(authController.user.uid)
                                    ? Colors.red
                                    : Colors.white),
                          ),
                        );
                      }));
                }),
              ),
              Divider(),
              ListTile(
                title: TextFormField(
                  controller: _commentController,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: "Comment",
                    labelStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyanAccent)),
                  ),
                ),
                trailing: TextButton(
                    onPressed: () {
                      commentController.postComment(_commentController.text);
                    },
                    child: Text(
                      'Send',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
