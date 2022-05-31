import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String username;
  String comment;
  final datePublished;
  List likes;
  String profilePhoto;
  String id;
  String uid;

  Comment(
      {required this.username,
      required this.comment,
      required this.datePublished,
      required this.likes,
      required this.profilePhoto,
      required this.id,
      required this.uid});
      
      Map<String,dynamic> toJson() =>{
        'username':username,
        'comment':comment,
        'datePublished':datePublished,
        'likes':likes,
        'profilePhoto':profilePhoto,
        'id':id,
        'uid':uid,
      };
      
      static Comment fromSnap(DocumentSnapshot snaphot){
        var snap = snaphot.data() as Map<String,dynamic>;
        return Comment(
          username:snap['username'],
          comment:snap['comment'],
          datePublished:snap['datePublished'],
          likes:snap['likes'],
          profilePhoto:snap['profilePhoto'],
          id:snap['id'],
          uid:snap['uid'],
        );
        
      }
}
