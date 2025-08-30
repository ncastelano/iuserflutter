class ItemData {
  final String id;
  final String image;
  final String? name;
  final double? latitude;
  final double? longitude;
  final String? isUser;
  final String? isFlash;
  final String? isProduct;
  final String? isPlace;
  final String? isStore;

  ItemData({
    required this.id,
    required this.image,
    this.name,
    this.latitude,
    this.longitude,
    this.isUser,
    this.isFlash,
    this.isProduct,
    this.isPlace,
    this.isStore,
  });
}