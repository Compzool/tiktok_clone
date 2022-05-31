import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants.dart';
import 'package:tiktok_clone/models/user.dart';
class SearchController extends GetxController{
  final Rx<List<User>> _searchedUsers = Rx<List<User>>([]);
  List<User> get searchedUsers => _searchedUsers.value;

  //search for the user

  searchUser(String typedUser) async{
    _searchedUsers.bindStream(firestore.collection('users').where('name', isEqualTo: typedUser).snapshots().map((QuerySnapshot snapshot) {
      List<User> users = [];
      /*snapshot.docs.forEach((doc) {
        //users.add(User.fromSnap((doc.data()! as dynamic)['user']));
        users.add(User.fromSnap(doc));
      });*/

      //OR
      for(var doc in snapshot.docs){
        users.add(User.fromSnap(doc));
      }
      
      return users;
    })
    );
  }
}