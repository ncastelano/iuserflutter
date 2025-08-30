import 'package:cloud_firestore/cloud_firestore.dart';

class Publication {
  // -----------------------------
  // Campos obrigatórios principais
  // -----------------------------
  GeoPoint position;        // posição nativa do Firebase (latitude/longitude)
  String geohash;           // geohash para buscas geográficas rápidas
  double ranking;           // ranking/score da publicação
  String publicationType;   // tipo principal: "video", "image", "pdf", "song", etc.
  String ownerType;         // dono da publicação: "user", "store", "product"
  String userID;            // id do usuário que postou
  DateTime createdDateTime; // data de criação do registro
  DateTime? publishedDateTime; // data de publicação
  DateTime? updatedAt;      // data de última atualização
  DateTime? expiresAt;      // data de expiração (opcional)

  // -----------------------------
  // Campos booleanos opcionais
  // -----------------------------
  bool? free;               // se é gratuito
  bool? active;             // se está ativo
  bool? visibleOnMap;       // se aparece no mapa
  bool? deleted;            // se foi deletado

  // -----------------------------
  // Informações do usuário
  // -----------------------------
  String? userProfileImage; // imagem do perfil do dono
  String? namePage;         // nome da página ou título da publicação

  // -----------------------------
  // Informações de loja/produto
  // -----------------------------
  String? storeID;          // id da loja
  String? storePage;        // nome da página da loja
  String? productID;        // id do produto

  // -----------------------------
  // Links de mídia
  // -----------------------------
  String? imageID;          // id da imagem
  String? imageUrl;         // url da imagem
  String? videoID;          // id do vídeo
  String? videoUrl;         // url do vídeo
  int? videoDuration;       // duração do vídeo em segundos
  String? pdfID;            // id do PDF
  String? pdfUrl;           // url do PDF
  String? songID;           // id da música
  String? songUrl;          // url da música
  int? songDuration;        // duração da música em segundos

  // -----------------------------
  // Preço e moeda (se for produto/loja)
  // -----------------------------
  int? priceInCents;        // preço em centavos
  String? currency;         // moeda, ex: "BRL"

  // -----------------------------
  // Hashtags e categorias
  // -----------------------------
  List<String>? hashtags;   // lista de hashtags/categorias
  String? categorie;        // categoria principal: "Música", "Podcast", "Audiobook", etc.

  // -----------------------------
  // Interações sociais
  // -----------------------------
  int? likes;               // total de likes
  int? totalComments;       // total de comentários
  int? shares;              // total de compartilhamentos
  int? views;               // total de visualizações

  // -----------------------------
  // Construtor
  // -----------------------------
  Publication({
    required this.position,
    required this.geohash,
    required this.ranking,
    required this.publicationType,
    required this.ownerType,
    required this.userID,
    required this.createdDateTime, // obrigatório
    this.free,
    this.active,
    this.visibleOnMap,
    this.deleted,
    this.publishedDateTime,
    this.updatedAt,
    this.expiresAt,
    this.userProfileImage,
    this.namePage,
    this.storeID,
    this.storePage,
    this.productID,
    this.imageID,
    this.imageUrl,
    this.videoID,
    this.videoUrl,
    this.videoDuration,
    this.pdfID,
    this.pdfUrl,
    this.songID,
    this.songUrl,
    this.songDuration,
    this.priceInCents,
    this.currency,
    this.hashtags,
    this.categorie,
    this.likes,
    this.totalComments,
    this.shares,
    this.views,
  });

  // -----------------------------
  // Serialização para Firestore
  // -----------------------------
  Map<String, dynamic> toJson() {
    return {
      "position": position,
      "geohash": geohash,
      "ranking": ranking,
      "publicationType": publicationType,
      "ownerType": ownerType,
      "userID": userID,
      "createdDateTime": createdDateTime.toIso8601String(), // obrigatório
      "free": free,
      "active": active,
      "visibleOnMap": visibleOnMap,
      "deleted": deleted,
      "publishedDateTime": publishedDateTime?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "expiresAt": expiresAt?.toIso8601String(),
      "userProfileImage": userProfileImage,
      "namePage": namePage,
      "storeID": storeID,
      "storePage": storePage,
      "productID": productID,
      "imageID": imageID,
      "imageUrl": imageUrl,
      "videoID": videoID,
      "videoUrl": videoUrl,
      "videoDuration": videoDuration,
      "pdfID": pdfID,
      "pdfUrl": pdfUrl,
      "songID": songID,
      "songUrl": songUrl,
      "songDuration": songDuration,
      "priceInCents": priceInCents,
      "currency": currency,
      "hashtags": hashtags,
      "categorie": categorie,
      "likes": likes,
      "totalComments": totalComments,
      "shares": shares,
      "views": views,
    };
  }

  // -----------------------------
  // Desserialização do Firestore
  // -----------------------------
  factory Publication.fromJson(Map<String, dynamic> json) {
    return Publication(
      position: json["position"],
      geohash: json["geohash"],
      ranking: (json["ranking"] ?? 0).toDouble(),
      publicationType: json["publicationType"],
      ownerType: json["ownerType"],
      userID: json["userID"],
      createdDateTime: DateTime.parse(json["createdDateTime"]), // obrigatório
      free: json["free"],
      active: json["active"],
      visibleOnMap: json["visibleOnMap"],
      deleted: json["deleted"],
      publishedDateTime: json["publishedDateTime"] != null
          ? DateTime.parse(json["publishedDateTime"])
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.parse(json["updatedAt"])
          : null,
      expiresAt: json["expiresAt"] != null
          ? DateTime.parse(json["expiresAt"])
          : null,
      userProfileImage: json["userProfileImage"],
      namePage: json["namePage"],
      storeID: json["storeID"],
      storePage: json["storePage"],
      productID: json["productID"],
      imageID: json["imageID"],
      imageUrl: json["imageUrl"],
      videoID: json["videoID"],
      videoUrl: json["videoUrl"],
      videoDuration: json["videoDuration"],
      pdfID: json["pdfID"],
      pdfUrl: json["pdfUrl"],
      songID: json["songID"],
      songUrl: json["songUrl"],
      songDuration: json["songDuration"],
      priceInCents: json["priceInCents"] != null
          ? (json["priceInCents"]).toInt()
          : null,
      currency: json["currency"],
      hashtags: json["hashtags"] != null
          ? List<String>.from(json["hashtags"])
          : null,
      categorie: json["categorie"],
      likes: json["likes"],
      totalComments: json["totalComments"],
      shares: json["shares"],
      views: json["views"],
    );
  }

  // -----------------------------
  // Métodos para subcoleção de compras
  // -----------------------------
  Future<void> addPurchase({
    required String publicationID,
    required String userID,
    required int priceInCents,
    required String currency,
  }) async {
    final purchaseRef = FirebaseFirestore.instance
        .collection('publications')
        .doc(publicationID)
        .collection('purchases')
        .doc(); // id automático

    await purchaseRef.set({
      'userID': userID,
      'priceInCents': priceInCents,
      'currency': currency,
      'purchasedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<String>> getPurchasers(String publicationID) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('publications')
        .doc(publicationID)
        .collection('purchases')
        .get();

    return snapshot.docs.map((doc) => doc['userID'] as String).toList();
  }

  Future<bool> hasPurchased(String publicationID, String userID) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('publications')
        .doc(publicationID)
        .collection('purchases')
        .where('userID', isEqualTo: userID)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }
}
