import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tiktok_clone/constants.dart';
import 'package:tiktok_clone/models/user.dart' as model;
import 'package:tiktok_clone/views/screens/auth/login_screen.dart';
import 'package:tiktok_clone/views/screens/home_screen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<File?> _pickedImage;
  late Rx<User?> _user;

  @override
  void onReady() {
    _user = Rx<User?>(firebaseAuth.currentUser);
    _user.bindStream(firebaseAuth.authStateChanges());
    ever(_user, _setInitialScreen);
    super.onReady();
  }

  //set initial screen
  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => LoginScreen());
    } else {
      Get.offAll(() => HomeScreen());
    }
  }

  //Image Getter
  File? get pickedImage => _pickedImage.value;

  //User Getter
  User get user => _user.value!;

  //Pick an image from gallery
  void pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      Get.snackbar("Profile Picture",
          "You have successfully selected a profile picture");
      _pickedImage = Rx<File?>(File(pickedImage.path));
      // or _pickedImage.value = File(pickedImage.path);
    }
  }

  //upload to firebase Storage
  Future<String> _uploadToStorage(File image) async {
    Reference ref = firebaseStorage
        .ref()
        .child('profilePictures')
        .child(firebaseAuth.currentUser!.uid);
    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  //register user
  void registerUser(
      String username, String email, String password, File? image) async {
    try {
      if (username.isNotEmpty &&
          email.isNotEmpty & password.isNotEmpty &&
          image != null) {
        //save user to firebase
        UserCredential credential = await firebaseAuth
            .createUserWithEmailAndPassword(email: email, password: password);

        String downloadUrl = await _uploadToStorage(image);
        model.User user = model.User(
            name: username,
            email: email,
            uid: credential.user!.uid,
            profilePicture: downloadUrl);

        await firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(user.toJson());
      } else {
        Get.snackbar("Error Creating Account", "Please enter all fields");
      }
    } catch (e) {
      Get.snackbar('Error Creating Account', e.toString(),
          duration: Duration(seconds: 3));
      print(e);
    }
  }

  //login user

  void loginUser(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential credential = await firebaseAuth
            .signInWithEmailAndPassword(email: email, password: password);
        print("User logged in");
      } else {
        Get.snackbar('Error Logging In', 'Please enter all fields',
            duration: Duration(seconds: 3));
      }
    } catch (e) {
      Get.snackbar('Error Logging in', e.toString());
    }
  }

  //logout user
  void logoutUser() async {
    await firebaseAuth.signOut();
    //Get.offAll(() => LoginScreen());
  }
}
