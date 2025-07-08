import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
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
    try {
      // 安全地提取location字段
      String locationStr = '';
      double lat = 0.0;
      double lng = 0.0;

      if (json['location'] != null) {
        locationStr = json['location'].toString();
        final locationParts = locationStr.split(',');
        if (locationParts.length == 2) {
          lng = double.tryParse(locationParts[0].trim()) ?? 0;
          lat = double.tryParse(locationParts[1].trim()) ?? 0;
        } else {
          print('位置数据格式错误: $locationStr');
        }
      }

      // 提取距离
      int? distance;
      if (json['distance'] != null) {
        // 处理可能是字符串或数字的情况
        if (json['distance'] is String) {
          distance = int.tryParse(json['distance'] as String);
        } else if (json['distance'] is int) {
          distance = json['distance'] as int;
        } else if (json['distance'] is double) {
          distance = (json['distance'] as double).round();
        }
      }

      // 提取电话
      String? tel;
      if (json['tel'] != null) {
        // 处理可能是字符串或列表的情况
        if (json['tel'] is String) {
          tel = json['tel'] as String;
        } else if (json['tel'] is List && (json['tel'] as List).isNotEmpty) {
          tel = (json['tel'] as List).first.toString();
        }
      }

      return CoffeeShop(
        id: json['id']?.toString() ?? "",
        name: json['name']?.toString() ?? "未命名咖啡店",
        vicinity: json['address']?.toString() ?? "无地址信息",
        lat: lat,
        lng: lng,
        distance: distance,
        tel: tel,
        address: json['address']?.toString(),
        rating:
            json['rating'] != null
                ? double.tryParse(json['rating'].toString())
                : null,
      );
    } catch (e) {
      print('解析咖啡店数据时出错: $e, 原始数据: $json');
      // 返回一个默认的对象，避免抛出异常
      return CoffeeShop(
        id: "error",
        name: "解析错误",
        vicinity: "无地址信息",
        lat: 0,
        lng: 0,
      );
    }
  }
}

class MapService {
  // 替换成你的高德地图Web服务API密钥
  static const String _webApiKey = '560792430a6d46fd93b5a92d8d239c72';

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

    // 根据平台不同使用不同的权限检查方法
    if (Platform.isIOS || Platform.isAndroid) {
      // 在iOS和Android上使用permission_handler
      var status = await Permission.location.request();
      return status.isGranted;
    } else if (Platform.isMacOS) {
      // 在macOS上直接使用Geolocator的权限API
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // 位置服务未启用，尝试打开
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

      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } else {
      // 其他平台暂不支持
      return false;
    }
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
        print('无法获取当前位置');
        return [];
      }

      if (_webApiKey.isEmpty || _webApiKey == '替换为您的高德地图Web服务API密钥') {
        print('警告：未配置高德地图API密钥，无法获取咖啡店数据');
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

      print('请求URL: $url');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print('API响应: ${response.body}');
        final data = json.decode(response.body);

        if (data['status'] == '1') {
          if (data['pois'] != null && data['pois'] is List) {
            final List pois = data['pois'];

            // 调试输出第一个POI的结构
            if (pois.isNotEmpty) {
              print('第一个POI数据结构: ${pois.first}');
            }

            final List<CoffeeShop> shops = [];
            for (var poi in pois) {
              try {
                shops.add(CoffeeShop.fromJson(poi));
              } catch (e) {
                print('解析POI数据错误: $e, 数据: $poi');
              }
            }
            return shops;
          } else {
            print('API未返回POI数据或格式错误: ${data['pois']}');
          }
        } else {
          print('API请求失败，状态码: ${data['status']}, 错误信息: ${data['info']}');
        }
      } else {
        print('HTTP请求失败，状态码: ${response.statusCode}');
      }

      return [];
    } catch (e) {
      print('搜索咖啡店失败: $e');
      return [];
    }
  }

  // 获取导航URL，根据平台返回不同的导航URL
  static String getDirectionsUrl(
    double destLat,
    double destLng,
    String destName,
  ) {
    // 根据平台返回不同的导航URL
    if (Platform.isIOS) {
      return getIOSDirectionsUrl(destLat, destLng, destName);
    } else if (Platform.isAndroid) {
      return getAndroidDirectionsUrl(destLat, destLng, destName);
    } else {
      // 如果是其他平台，返回Web导航URL
      return getWebDirectionsUrl(destLat, destLng, destName);
    }
  }

  // 获取Android导航URL (高德地图)
  static String getAndroidDirectionsUrl(
    double destLat,
    double destLng,
    String destName,
  ) {
    // Android高德地图URL Scheme
    return 'androidamap://route?sourceApplication=daily_coffee&dlat=$destLat&dlon=$destLng&dname=${Uri.encodeComponent(destName)}&dev=0&t=0';
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

  // 获取Web导航URL (高德地图)
  static String getWebDirectionsUrl(
    double destLat,
    double destLng,
    String destName,
  ) {
    // 网页版高德地图导航链接
    return 'https://uri.amap.com/navigation?to=$destLng,$destLat,${Uri.encodeComponent(destName)}&mode=car&policy=1&src=myapp&coordinate=gaode&callnative=0';
  }

  // 检查是否安装了高德地图应用
  static Future<bool> isAMapInstalled() async {
    String urlScheme;
    if (Platform.isIOS) {
      urlScheme = 'iosamap://';
    } else if (Platform.isAndroid) {
      urlScheme = 'androidamap://';
    } else {
      return false;
    }

    try {
      return await canLaunchUrl(Uri.parse(urlScheme));
    } catch (e) {
      print('检查高德地图安装失败: $e');
      return false;
    }
  }
}
