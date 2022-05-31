import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants.dart';
import 'package:tiktok_clone/models/video.dart';
import 'package:video_compress/video_compress.dart';

class UploadVideoController extends GetxController {
  //Compress Video
  _compressVideo(String videoPath) async {
    final compressedVideo = await VideoCompress.compressVideo(videoPath,
        quality: VideoQuality.MediumQuality);
    return compressedVideo!.file;
  }

  //Upload Video to Storage
  Future<String> _uploadVideoToStorage(String id, String videoPath) async {
    Reference videoRef = firebaseStorage.ref().child('videos').child(id);
    UploadTask uploadTask = videoRef.putFile(await _compressVideo(videoPath));
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }
  //Generate Thumbnails

  _getThumbnail(String videoPath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videoPath);
    return thumbnail;
  }

  Future<String> _uploadImageToStorage(String id, String videoPath) async {
    Reference thumbnailRef =
        firebaseStorage.ref().child('thumbnails').child(id);
    UploadTask uploadTask =
        thumbnailRef.putFile(await _getThumbnail(videoPath));
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  //Upload Video Function
  uploadVideo(String videoPath, String songName, String caption) async {
    try {
      String uid = firebaseAuth.currentUser!.uid;
      DocumentSnapshot userDocument =
          await firestore.collection('users').doc(uid).get();
      QuerySnapshot allDocs = await firestore.collection('videos').get();
      int len = allDocs.docs.length;
      print("username: " +
          (userDocument.data()! as Map<String, dynamic>)['name']);
      print("uid: $uid");
      print("id: Video: $len");
      print("profile: " +
          (userDocument.data()! as Map<String, dynamic>)['profilePicture']);
      String videoUrl = await _uploadVideoToStorage("Video: $len", videoPath);
      String thumbnail = await _uploadImageToStorage("Video: $len", videoPath);

      Video video = Video(
          username: (userDocument.data()! as Map<String, dynamic>)['name'],
          uid: uid,
          id: "Video: $len",
          likes: [],
          commentCount: 0,
          shareCount: 0,
          songName: songName,
          caption: caption,
          videoUrl: videoUrl,
          thumbnail: thumbnail,
          profilePhoto:
              (userDocument.data()! as Map<String, dynamic>)['profilePicture']);

      await firestore
          .collection('videos')
          .doc("Video: $len")
          .set(video.toJson());
      Get.back();
    } catch (e) {
      Get.snackbar("Error uploading your video", e.toString());
    }
  }
}
