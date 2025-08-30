import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  String? name;
  String? uid;
  String? image;
  String? email;
  String? youtube;
  String? facebook;
  String? twitter;
  String? instagram;
  List<String>? namePage;
  double? latitude;
  double? longitude;
  bool? visible;

  Usuario({
    this.name,
    this.uid,
    this.image,
    this.email,
    this.youtube,
    this.facebook,
    this.twitter,
    this.instagram,
    this.namePage, // ✅ Atualizado
    this.latitude,
    this.longitude,
    this.visible,
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
    "namePage": namePage, // ✅ Serialização como lista
    "latitude": latitude,
    "longitude": longitude,
    "visible": visible ?? false,
  };

  static Usuario fromSnap(DocumentSnapshot snapshot) {
    var dataSnapshot = snapshot.data() as Map<String, dynamic>;

    return Usuario(
      name: dataSnapshot["name"],
      uid: dataSnapshot["uid"],
      image: dataSnapshot["image"],
      email: dataSnapshot["email"],
      youtube: dataSnapshot["youtube"],
      facebook: dataSnapshot["facebook"],
      twitter: dataSnapshot["twitter"],
      instagram: dataSnapshot["instagram"],
      namePage: List<String>.from(dataSnapshot["namePage"] ?? []), // ✅ Conversão segura
      latitude: (dataSnapshot["latitude"] ?? 0).toDouble(),
      longitude: (dataSnapshot["longitude"] ?? 0).toDouble(),
      visible: dataSnapshot["visible"] ?? false,
    );
  }
}
