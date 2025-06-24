import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class CoffeeShop {
  final String id;
  final String name;
  final String vicinity;
  final double lat;
  final double lng;
  final double? rating;
  final int? userRatingsTotal;
  final bool? openNow;
  final List<String> types;
  final String? icon;
  final String? photoReference;
  final int? distance; // 单位：米

  CoffeeShop({
    required this.id,
    required this.name,
    required this.vicinity,
    required this.lat,
    required this.lng,
    this.rating,
    this.userRatingsTotal,
    this.openNow,
    required this.types,
    this.icon,
    this.photoReference,
    this.distance,
  });

  factory CoffeeShop.fromJson(
    Map<String, dynamic> json, {
    Position? userPosition,
  }) {
    final location = json['geometry']['location'];
    final lat = location['lat'] as double;
    final lng = location['lng'] as double;

    // 计算距离（如果提供了用户位置）
    int? distance;
    if (userPosition != null) {
      distance =
          Geolocator.distanceBetween(
            userPosition.latitude,
            userPosition.longitude,
            lat,
            lng,
          ).round();
    }

    // 解析营业状态
    bool? openNow;
    if (json['opening_hours'] != null) {
      openNow = json['opening_hours']['open_now'];
    }

    // 解析照片引用
    String? photoReference;
    if (json['photos'] != null && json['photos'].isNotEmpty) {
      photoReference = json['photos'][0]['photo_reference'];
    }

    return CoffeeShop(
      id: json['place_id'],
      name: json['name'],
      vicinity: json['vicinity'],
      lat: lat,
      lng: lng,
      rating: json['rating']?.toDouble(),
      userRatingsTotal: json['user_ratings_total'],
      openNow: openNow,
      types: List<String>.from(json['types']),
      icon: json['icon'],
      photoReference: photoReference,
      distance: distance,
    );
  }
}

class MapService {
  static const String _apiKey = ''; // 需要添加实际的Google Maps API KEY

  // 检查位置权限
  static Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // 获取当前位置
  static Future<Position?> getCurrentLocation() async {
    final hasPermission = await checkLocationPermission();
    if (!hasPermission) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  // 获取附近的咖啡店
  static Future<List<CoffeeShop>> getNearbyShops({
    double radius = 1500,
    String keyword = 'coffee',
  }) async {
    try {
      final position = await getCurrentLocation();
      if (position == null) {
        return [];
      }

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${position.latitude},${position.longitude}'
        '&radius=$radius'
        '&type=cafe'
        '&keyword=$keyword'
        '&key=$_apiKey',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return List<CoffeeShop>.from(
            data['results'].map(
              (place) => CoffeeShop.fromJson(place, userPosition: position),
            ),
          );
        }
      }
      return [];
    } catch (e) {
      print('Error fetching nearby coffee shops: $e');
      return [];
    }
  }

  // 获取咖啡店照片URL
  static String getPhotoUrl(String photoReference, {int maxWidth = 400}) {
    return 'https://maps.googleapis.com/maps/api/place/photo'
        '?maxwidth=$maxWidth'
        '&photo_reference=$photoReference'
        '&key=$_apiKey';
  }

  // 获取导航URL
  static String getDirectionsUrl(double destLat, double destLng) {
    return 'https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLng';
  }
}
