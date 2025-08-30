import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String? userID;
  String? userName;
  String? userProfileImage;
  String? postID;       // id geral do post (pode ser loja ou produto)
  String? storeID;      // id da loja a que o produto pertence (null se for loja)
  String? productID;    // id único do produto (pode ser igual ao postID para produtos, null para loja)
  int? totalComments;

  List? likesList;
  List? visaList;
  String? title;
  String? descriptionTags;
  String? videoUrl;
  String? thumbnailUrl;
  DateTime? publishedDateTime;
  double? latitude;
  double? longitude;

  bool? isStore;
  bool? isFlash;
  bool? isProduct;
  bool? isPlace;

  Post({
    this.userID,
    this.userName,
    this.userProfileImage,
    this.postID,
    this.storeID,
    this.productID,
    this.totalComments,
    this.likesList,
    this.visaList,
    this.title,
    this.descriptionTags,
    this.videoUrl,
    this.thumbnailUrl,
    this.publishedDateTime,
    this.latitude,
    this.longitude,
    this.isStore,
    this.isFlash,
    this.isProduct,
    this.isPlace,
  });

  Map<String, dynamic> toJson() => {
    "userID": userID,
    "userName": userName,
    "userProfileImage": userProfileImage,
    "postID": postID,
    "storeID": storeID,
    "productID": productID,
    "totalComments": totalComments,
    "likesList": likesList,
    "visaList": visaList,
    "artistSongName": title,
    "descriptionTags": descriptionTags,
    "videoUrl": videoUrl,
    "thumbnailUrl": thumbnailUrl,
    "publishedDateTime": publishedDateTime?.millisecondsSinceEpoch,
    "latitude": latitude,
    "longitude": longitude,
    "isStore": isStore,
    "isFlash": isFlash,
    "isProduct": isProduct,
    "isPlace": isPlace,
  };

  static Post fromDocumentSnapshot(DocumentSnapshot snapshot) {
    var docSnapshot = snapshot.data() as Map<String, dynamic>;

    return Post(
      userID: docSnapshot["userID"],
      userName: docSnapshot["userName"],
      userProfileImage: docSnapshot["userProfileImage"],
      postID: docSnapshot["postID"],
      storeID: docSnapshot["storeID"],
      productID: docSnapshot["productID"],
      totalComments: docSnapshot["totalComments"],
      likesList: docSnapshot["likesList"],
      visaList: docSnapshot["visaList"],
      title: docSnapshot["artistSongName"],
      descriptionTags: docSnapshot["descriptionTags"],
      videoUrl: docSnapshot["videoUrl"],
      thumbnailUrl: docSnapshot["thumbnailUrl"],
      publishedDateTime: docSnapshot["publishedDateTime"] != null
          ? DateTime.fromMillisecondsSinceEpoch(docSnapshot["publishedDateTime"])
          : null,
      latitude: docSnapshot["latitude"]?.toDouble(),
      longitude: docSnapshot["longitude"]?.toDouble(),
      isStore: docSnapshot["isStore"] ?? false,
      isFlash: docSnapshot["isFlash"] ?? false,
      isProduct: docSnapshot["isProduct"] ?? false,
      isPlace: docSnapshot["isPlace"] ?? false,
    );
  }
}
