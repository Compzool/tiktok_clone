import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants.dart';
import 'package:tiktok_clone/models/comment.dart';

class CommentController extends GetxController {
  Rx<List<Comment>> _commentList = Rx<List<Comment>>([]);

  //Getter for the comment list
  List<Comment> get commentList => _commentList.value;

  //We need a post ID to get the comments
  String _postId = "";
  updatePostId(String id) {
    _postId = id;
    getComments();
  }

  //Get the comments from the server
  getComments() async {
    _commentList.bindStream(firestore
        .collection('videos')
        .doc(_postId)
        .collection('comments')
        .snapshots()
        .map((QuerySnapshot querySnapshot) {
      List<Comment> comments = [];
      for (var comment in querySnapshot.docs) {
        comments.add(Comment.fromSnap(comment));
      }
      return comments;
    }));
  }

  //Post comment
  postComment(String commentText) async {
    try {
      if (commentText.isNotEmpty) {
        DocumentSnapshot userDoc = await firestore
            .collection('users')
            .doc(authController.user.uid)
            .get();
        var allDocs = await firestore
            .collection('videos')
            .doc(_postId)
            .collection('comments')
            .get();
        int len = allDocs.docs.length;

        Comment comment = Comment(
          username: (userDoc.data()! as dynamic)['name'],
          comment: commentText.trim(),
          datePublished: DateTime.now(),
          likes: [],
          profilePhoto: (userDoc.data()! as dynamic)['profilePicture'],
          uid: authController.user.uid,
          id: 'Comment: $len',
        );
        await firestore
            .collection('videos')
            .doc(_postId)
            .collection('comments')
            .doc('Comment: $len')
            .set(
              comment.toJson(),
            );
        DocumentSnapshot snapshot =
            await firestore.collection('videos').doc(_postId).get();
        firestore.collection('videos').doc(_postId).update({
          'commentCount': (snapshot.data() as dynamic)['commentCount'] + 1,
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error While Commenting',
        e.toString(),
      );
    }
  }

  //Like comment
  likeComment(String id) async {
    var uid = authController.user.uid;
    DocumentSnapshot snapshot = await firestore
        .collection('videos')
        .doc(_postId)
        .collection('comments')
        .doc(id)
        .get();
    if ((snapshot.data()! as dynamic)['likes'].contains(uid)) {
      await firestore
          .collection('videos')
          .doc(_postId)
          .collection('comments')
          .doc(id)
          .update({
            'likes': FieldValue.arrayRemove([uid]),
          });
    }
    else{
      await firestore
          .collection('videos')
          .doc(_postId)
          .collection('comments')
          .doc(id)
          .update({
            'likes': FieldValue.arrayUnion([uid]),
          });
    }
  }
}
