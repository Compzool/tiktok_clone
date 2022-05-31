import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants.dart';

class ProfileController extends GetxController {
  final Rx<Map<String, dynamic>> _profileData = Rx<Map<String, dynamic>>({});

  Map<String, dynamic> get profileData => _profileData.value;

  Rx<String> _uid = "".obs;

  updateUserId(String uid) {
    _uid.value = uid;
    getUserData();
  }

  getUserData() async {
    List<String> thumbnail = [];
    var myVideos = await firestore
        .collection('videos')
        .where('uid', isEqualTo: _uid.value)
        .get();

    for (int i = 0; i < myVideos.docs.length; i++) {
      thumbnail.add((myVideos.docs[i].data() as dynamic)['thumbnail']);
    }
    DocumentSnapshot userDocument =
        await firestore.collection('users').doc(_uid.value).get();
    final userData = userDocument.data()! as Map<String, dynamic>;
    String username = userData['name'];
    String profilePhoto = userData['profilePicture'];
    int likes = 0;
    int followers = 0;
    int following = 0;
    bool isFollowing = false;
    for (var item in myVideos.docs) {
      likes += (item.data()['likes'] as List).length;
    }

    var followerDocument = await firestore
        .collection('users')
        .doc(_uid.value)
        .collection('followers')
        .get();
    var followingDocument = await firestore
        .collection('users')
        .doc(_uid.value)
        .collection('following')
        .get();

    followers = followerDocument.docs.length;
    following = followingDocument.docs.length;

    firestore
        .collection('users')
        .doc(_uid.value)
        .collection('followers')
        .doc(authController.user.uid)
        .get()
        .then((value) {
      if (value.exists) {
        isFollowing = true;
      } else {
        isFollowing = false;
      }
    });

    _profileData.value = {
      'username': username,
      'profilePhoto': profilePhoto,
      'thumbnail': thumbnail,
      'likes': likes.toString(),
      'followers': followers.toString(),
      'following': following.toString(),
      'isFollowing': isFollowing
    };
    update();
  }

  followUser() async {
    var doc = await firestore
        .collection('users')
        .doc(_uid.value)
        .collection('followers')
        .doc(authController.user.uid)
        .get();

    if (!doc.exists) {
      await firestore
          .collection('users')
          .doc(_uid.value)
          .collection('followers')
          .doc(authController.user.uid)
          .set({});

      await firestore
          .collection('users')
          .doc(authController.user.uid)
          .collection('following')
          .doc(_uid.value)
          .set({});

      _profileData.value
          .update('followers', (value) => (int.parse(value) + 1).toString());
    } else {
      await firestore
          .collection('users')
          .doc(_uid.value)
          .collection('followers')
          .doc(authController.user.uid)
          .delete();

      await firestore
          .collection('users')
          .doc(authController.user.uid)
          .collection('following')
          .doc(_uid.value)
          .delete();

      _profileData.value
          .update('followers', (value) => (int.parse(value) - 1).toString());
    }
    _profileData.value.update('isFollowing', (value) => !value);
    update();
  }
}
