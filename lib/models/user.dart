import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String? name;
  String? uid;
  String? image;
  String? email;
  String? youtube;
  String? facebook;
  String? twitter;
  String? instagram;
  String? namePage;
  List? likesList;
  double? latitude;
  double? longitude;
  bool? visible; // ✅ Novo campo

  User({
    this.name,
    this.uid,
    this.image,
    this.email,
    this.youtube,
    this.facebook,
    this.twitter,
    this.instagram,
    this.namePage,
    this.likesList,
    this.latitude,
    this.longitude,
    this.visible, // ✅ no construtor
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "uid": uid,
    "image": image,
    "email": email,
    "youtube": youtube,
    "facebook": facebook,
    "twitter": twitter,
    "instagram": instagram,
    "namePage": namePage,
    "likesList": likesList,
    "latitude": latitude,
    "longitude": longitude,
    "visible": visible ?? false, // ✅ serialização
  };

  static User fromSnap(DocumentSnapshot snapshot) {
    var dataSnapshot = snapshot.data() as Map<String, dynamic>;

    return User(
      name: dataSnapshot["name"],
      uid: dataSnapshot["uid"],
      image: dataSnapshot["image"],
      email: dataSnapshot["email"],
      youtube: dataSnapshot["youtube"],
      facebook: dataSnapshot["facebook"],
      twitter: dataSnapshot["twitter"],
      instagram: dataSnapshot["instagram"],
      namePage: dataSnapshot["namePage"],
      likesList: dataSnapshot["likesList"],
      latitude: (dataSnapshot["latitude"] ?? 0).toDouble(),
      longitude: (dataSnapshot["longitude"] ?? 0).toDouble(),
      visible: dataSnapshot["visible"] ?? false, // ✅ leitura
    );
  }
}
