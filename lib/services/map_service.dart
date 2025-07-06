import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class CoffeeShop {
  final String id;
  final String name;
  final String vicinity;
  final double lat;
  final double lng;
  final double? rating;
  final int? distance; // 单位：米
  final bool? isOpen;
  final String? tel;
  final String? address;

  CoffeeShop({
    required this.id,
    required this.name,
    required this.vicinity,
    required this.lat,
    required this.lng,
    this.rating,
    this.distance,
    this.isOpen,
    this.tel,
    this.address,
  });

  // 从高德POI数据创建咖啡店对象
  factory CoffeeShop.fromJson(Map<String, dynamic> json) {
    return CoffeeShop(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      vicinity: json['address'] ?? "",
      lat: double.tryParse(json['location']?.split(',')[1] ?? "0") ?? 0,
      lng: double.tryParse(json['location']?.split(',')[0] ?? "0") ?? 0,
      distance:
          json['distance'] != null ? int.tryParse(json['distance']) : null,
      tel: json['tel'],
      address: json['address'],
    );
  }
}

class MapService {
  static const String _webApiKey = ''; // 需要添加实际的高德地图 Web服务 Key

  static bool _isInitialized = false;

  // 初始化
  static Future<void> init() async {
    if (!_isInitialized) {
      _isInitialized = true;
    }
  }

  // 检查位置权限
  static Future<bool> checkLocationPermission() async {
    if (!_isInitialized) {
      await init();
    }

    // 检查定位权限
    var status = await Permission.location.request();
    return status.isGranted;
  }

  // 获取当前位置
  static Future<Position?> getCurrentLocation() async {
    final hasPermission = await checkLocationPermission();
    if (!hasPermission) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print('获取位置失败: $e');
      return null;
    }
  }

  // 获取附近的咖啡店（使用高德地图Web API）
  static Future<List<CoffeeShop>> getNearbyShops({
    double radius = 1000,
    String keyword = '咖啡',
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final position = await getCurrentLocation();
      if (position == null) {
        return [];
      }

      // 使用高德地图Web服务API进行搜索
      final url = Uri.parse(
        'https://restapi.amap.com/v3/place/around?'
        'key=$_webApiKey'
        '&location=${position.longitude},${position.latitude}'
        '&keywords=$keyword'
        '&types=餐饮服务|咖啡厅'
        '&radius=$radius'
        '&offset=$pageSize'
        '&page=$page'
        '&extensions=all',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == '1' && data['pois'] != null) {
          final List pois = data['pois'];
          return pois.map((poi) => CoffeeShop.fromJson(poi)).toList();
        }
      }

      return [];
    } catch (e) {
      print('搜索咖啡店失败: $e');
      return [];
    }
  }

  // 获取导航URL (高德地图)
  static String getDirectionsUrl(
    double destLat,
    double destLng,
    String destName,
  ) {
    // 高德地图 URL Scheme
    return 'androidamap://route?sourceApplication=daily_coffee&dlat=$destLat&dlon=$destLng&dname=$destName&dev=0&t=0';
  }

  // 获取iOS导航URL (高德地图)
  static String getIOSDirectionsUrl(
    double destLat,
    double destLng,
    String destName,
  ) {
    // 使用编码后的目的地名称
    final encodedName = Uri.encodeComponent(destName);
    return 'iosamap://route?sourceApplication=daily_coffee&dlat=$destLat&dlon=$destLng&dname=$encodedName&dev=0&t=0';
  }

  // 检查是否安装了高德地图应用
  static Future<bool> isAMapInstalled() async {
    // 这里仅为占位，实际实现需要使用 url_launcher 的 canLaunchUrl 方法
    return true;
  }
}
