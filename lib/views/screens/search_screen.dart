import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/controllers/search_controller.dart';
import 'package:tiktok_clone/models/user.dart';
import 'package:tiktok_clone/views/screens/profile_screen.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({Key? key}) : super(key: key);
  final SearchController searchController = Get.put(SearchController());
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
          appBar: AppBar(
            title: TextFormField(
              decoration: InputDecoration(
                  filled: false,
                  hintText: 'Search',
                  hintStyle: TextStyle(fontSize: 18, color: Colors.white)),
              onFieldSubmitted: (value) => searchController.searchUser(value),
            ),
            backgroundColor: Colors.red,
          ),
          body: searchController.searchedUsers.isEmpty
              ? Center(
                  child: Text(
                    'Search for users!',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  itemCount: searchController.searchedUsers.length,
                  itemBuilder: ((context, index) {
                    User foundUsers = searchController.searchedUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(foundUsers.profilePicture),
                      ),
                      title: Text(
                        foundUsers.name,
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () {
                        Get.to(()=>ProfileScreen(uid: foundUsers.uid));
                      },
                    );
                  })));
    });
  }
}
