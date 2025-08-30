class GeoHashHelper {
  static const String _base32 = "0123456789bcdefghjkmnpqrstuvwxyz";

  static String encode(double latitude, double longitude, {int precision = 9}) {
    final latInterval = [-90.0, 90.0];
    final lonInterval = [-180.0, 180.0];

    var geohash = StringBuffer();
    var isEven = true;
    int bit = 0;
    int ch = 0;

    while (geohash.length < precision) {
      double mid;
      if (isEven) {
        mid = (lonInterval[0] + lonInterval[1]) / 2;
        if (longitude > mid) {
          ch |= 1 << (4 - bit);
          lonInterval[0] = mid;
        } else {
          lonInterval[1] = mid;
        }
      } else {
        mid = (latInterval[0] + latInterval[1]) / 2;
        if (latitude > mid) {
          ch |= 1 << (4 - bit);
          latInterval[0] = mid;
        } else {
          latInterval[1] = mid;
        }
      }

      isEven = !isEven;
      if (bit < 4) {
        bit++;
      } else {
        geohash.write(_base32[ch]);
        bit = 0;
        ch = 0;
      }
    }

    return geohash.toString();
  }
}
