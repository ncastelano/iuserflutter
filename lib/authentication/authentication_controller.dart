import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iuser/login/login_screen.dart';
import 'package:iuser/registration/registration_screen.dart';
import 'package:iuser/global.dart';
import '../home/mapa/mapa.dart';
import '../models/user.dart' as userModel;

class AuthenticationController extends GetxController {
  static AuthenticationController instanceAuth = Get.find();
  late Rx<User?> _currentUser;

  late Rx<File?> _pickedFile = Rx<File?>(null);

  File? get profileImage => _pickedFile.value;

  void _showSnackBar(String title, String message) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black, // Fundo preto
        content: Text(
          "$title\n$message",
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        User? user = userCredential.user;

        if (user != null) {
          // Verifica se o usuário já existe no Firestore
          DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

          if (!userDoc.exists) {
            await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
              "uid": user.uid,
              "name": user.displayName ?? "",
              "email": user.email ?? "",
              "image": user.photoURL ?? "",
            });
          }
          _showSnackBar("Seja bem vindo", "você utilizou o e-mail do google!");
          // Get.snackbar("Login com Google", "Login bem-sucedido!");
        }
      }
    } catch (error) {
      _showSnackBar("Erro", "Falha ao fazer login com Google: $error");
      // Get.snackbar("Erro", "Falha ao fazer login com Google: $error");
      print("Erro ao fazer login com Google: $error");
    }
  }

  void chooseImageFromGallery() async {
    final pickedImageFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImageFile != null) {
      //_showSnackBar("Profile Image", "Você selecionou a imagem do perfil com sucesso.");
      _pickedFile.value = File(pickedImageFile.path);
    }
  }


  void captureImageWithCamera() async {
    final pickedImageFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedImageFile != null) {
      //_showSnackBar("Profile Image", "Você capturou a imagem do perfil com a câmera do telefone com sucesso.");
      _pickedFile.value = File(pickedImageFile.path);
    }
  }


  void createAccountForNewUser(File imageFile, String namePage, String userEmail, String userPassword) async {
    try {
      // 1. Cria usuário na autenticação do Firebase
      UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userEmail,
        password: userPassword,
      );

      // 2. Salva a imagem de perfil do usuário no Firebase Storage
      String imageDownloadUrl = await uploadImageToStorage(imageFile);

      // 3. Salva os dados do usuário no banco de dados Firestore
      userModel.User user = userModel.User(
        namePage: namePage,
        email: userEmail,
        image: imageDownloadUrl,
        uid: credential.user!.uid,
      );

      await FirebaseFirestore.instance.collection("users").doc(credential.user!.uid).set(user.toJson());
      _showSnackBar("Seja bem-vindo!", "Sua conta foi criada!");
      // Get.snackbar("Seja bem-vindo!", "Sua conta foi criada!");
      showProgressBar = false;
    } catch (error) {
      _showSnackBar("Erro ao criar conta!", "Algo deu errado, tente de novo!");
      // Get.snackbar("Erro ao criar conta!", "Algo deu errado, tente de novo!");
      showProgressBar = false;
      Get.to(LoginScreen());
    }
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    Reference reference = FirebaseStorage.instance.ref()
        .child("Profile Images")
        .child(FirebaseAuth.instance.currentUser!.uid);

    UploadTask uploadTask = reference.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;

    String downloadUrlOfUploadedImage = await taskSnapshot.ref.getDownloadURL();
    return downloadUrlOfUploadedImage;
  }

  void loginUserNow(String userEmail, String userPassword) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userEmail,
        password: userPassword,
      );

      //_showSnackBar("Bem-vindo!", "Você está no iUser!");
      // Get.snackbar("Bem-vindo!", "Você está no iUser!");
      showProgressBar = false;
    } catch (error) {
      _showSnackBar("Falha ao iniciar", "Erro na autenticação!");
      // Get.snackbar("Falha ao iniciar", "Erro na autenticação!");
      showProgressBar = false;
      Get.to(RegistrationScreen());
    }
  }

  void goToScreen(User? currentUser) {
    // Se o usuário não estiver logado, redireciona para LoginScreen
    if (currentUser == null) {
      Get.offAll(LoginScreen());
    }
    // Se o usuário estiver logado, redireciona para HomeScreen
    else {
      //Get.offAll(HomeScreen());
      Get.offAll(() => Mapa(), transition: Transition.fadeIn, duration: const Duration(milliseconds: 2000));

    }
  }

  @override
  void onReady() {
    super.onReady();

    _currentUser = Rx<User?>(FirebaseAuth.instance.currentUser);
    _currentUser.bindStream(FirebaseAuth.instance.authStateChanges());
    ever(_currentUser, goToScreen);
  }
}
