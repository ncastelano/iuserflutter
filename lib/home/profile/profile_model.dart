class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String image;
  final String youtube;
  final String instagram;
  final String twitter;
  final String facebook;
  final int? totalStars;
  List? likesList;
  List? followList;
  List? followerList; // <-- Adicionado aqui

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
    required this.youtube,
    required this.instagram,
    required this.twitter,
    required this.facebook,
    this.totalStars,
    this.likesList,
    this.followList,
    this.followerList, // <-- Adicionado aqui
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map, String id) {
    return ProfileModel(
      id: id,
      name: map['name'] ?? 'Nome não disponível',
      email: map['email'] ?? 'Email não disponível',
      image: map['image'] ?? '',
      youtube: map['youtube'] ?? 'Não informado',
      instagram: map['instagram'] ?? 'Não informado',
      twitter: map['twitter'] ?? 'Não informado',
      facebook: map['facebook'] ?? 'Não informado',
      totalStars: map['totalStars'],
      likesList: map['likesList'],
      followList: map['followList'],
      followerList: map['followerList'], // <-- Adicionado aqui
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'image': image,
      'youtube': youtube,
      'instagram': instagram,
      'twitter': twitter,
      'facebook': facebook,
      'totalStars': totalStars,
      'likesList': likesList,
      'followList': followList,
      'followerList': followerList, // <-- Adicionado aqui
    };
  }
}
