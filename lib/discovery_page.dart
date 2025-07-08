import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/map_service.dart';
import 'dart:async';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({Key? key}) : super(key: key);

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.discovery),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.coffeeTypes),
            Tab(text: l10n.brewingMethods),
            Tab(text: l10n.beanOrigins),
            Tab(text: l10n.coffeeshopMap),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCoffeeTypesTab(context, l10n),
          _buildBrewingMethodsTab(context, l10n),
          _buildBeanOriginsTab(context, l10n),
          _buildCoffeeshopMapTab(context, l10n),
        ],
      ),
    );
  }

  Widget _buildCoffeeTypesTab(BuildContext context, AppLocalizations l10n) {
    // 咖啡类型数据
    final coffeeTypes = [
      {
        'name': 'Espresso',
        'image': 'images/coffee_types/espresso.jpg',
        'description': l10n.espressoDescription,
      },
      {
        'name': 'Americano',
        'image': 'images/coffee_types/americano.jpg',
        'description': l10n.americanoDescription,
      },
      {
        'name': 'Latte',
        'image': 'images/coffee_types/latte.jpg',
        'description': l10n.latteDescription,
      },
      {
        'name': 'Cappuccino',
        'image': 'images/coffee_types/cappuccino.jpg',
        'description': l10n.cappuccinoDescription,
      },
      {
        'name': 'Mocha',
        'image': 'images/coffee_types/mocha.jpg',
        'description': l10n.mochaDescription,
      },
      {
        'name': 'Macchiato',
        'image': 'images/coffee_types/macchiato.jpg',
        'description': l10n.macchiatoDescription,
      },
    ];

    return ListView.builder(
      itemCount: coffeeTypes.length,
      itemBuilder: (context, index) {
        final coffeeType = coffeeTypes[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                coffeeType['image'] as String,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.brown[100],
                    child: const Icon(Icons.coffee, color: Colors.brown),
                  );
                },
              ),
            ),
            title: Text(
              coffeeType['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(coffeeType['description'] as String),
            ),
            onTap: () {
              // 打开详情页面，目前仅显示简单提示
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${l10n.detailsFor} ${coffeeType['name']}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBrewingMethodsTab(BuildContext context, AppLocalizations l10n) {
    // 咖啡冲泡方法数据
    final brewingMethods = [
      {
        'name': 'Pour Over',
        'image': 'images/brewing_methods/pour_over.jpg',
        'description': l10n.pourOverDescription,
      },
      {
        'name': 'French Press',
        'image': 'images/brewing_methods/french_press.jpg',
        'description': l10n.frenchPressDescription,
      },
      {
        'name': 'AeroPress',
        'image': 'images/brewing_methods/aeropress.jpg',
        'description': l10n.aeroPressDescription,
      },
      {
        'name': 'Cold Brew',
        'image': 'images/brewing_methods/cold_brew.jpg',
        'description': l10n.coldBrewDescription,
      },
    ];

    return ListView.builder(
      itemCount: brewingMethods.length,
      itemBuilder: (context, index) {
        final method = brewingMethods[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                method['image'] as String,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.brown[100],
                    child: const Icon(Icons.coffee_maker, color: Colors.brown),
                  );
                },
              ),
            ),
            title: Text(method['name'] as String),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(method['description'] as String),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBeanOriginsTab(BuildContext context, AppLocalizations l10n) {
    // 咖啡豆产地数据
    final beanOrigins = [
      {
        'name': 'Ethiopia',
        'image': 'images/bean_origins/ethiopia.jpg',
        'description': l10n.ethiopiaDescription,
      },
      {
        'name': 'Colombia',
        'image': 'images/bean_origins/colombia.jpg',
        'description': l10n.colombiaDescription,
      },
      {
        'name': 'Brazil',
        'image': 'images/bean_origins/brazil.jpg',
        'description': l10n.brazilDescription,
      },
      {
        'name': 'Guatemala',
        'image': 'images/bean_origins/guatemala.jpg',
        'description': l10n.guatemalaDescription,
      },
      {
        'name': 'Jamaica',
        'image': 'images/bean_origins/jamaica.jpg',
        'description': l10n.jamaicaDescription,
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: beanOrigins.length,
      itemBuilder: (context, index) {
        final origin = beanOrigins[index];
        return Card(
          elevation: 2,
          child: InkWell(
            onTap: () {
              // 打开详情页面，目前仅显示简单提示
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${l10n.detailsFor} ${origin['name']}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                    child: Image.asset(
                      origin['image'] as String,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.brown[100],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: Colors.brown,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        origin['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        origin['description'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCoffeeshopMapTab(BuildContext context, AppLocalizations l10n) {
    return CoffeeshopListView(l10n: l10n);
  }
}

class CoffeeshopListView extends StatefulWidget {
  final AppLocalizations l10n;

  const CoffeeshopListView({Key? key, required this.l10n}) : super(key: key);

  @override
  State<CoffeeshopListView> createState() => _CoffeeshopListViewState();
}

class _CoffeeshopListViewState extends State<CoffeeshopListView> {
  bool _isLoading = true;
  bool _hasLocationPermission = false;
  List<CoffeeShop> _coffeeShops = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissionAndLoadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 初始化
      await MapService.init();
      print('MapService初始化成功');

      final hasPermission = await MapService.checkLocationPermission();
      print('位置权限检查结果: $hasPermission');

      setState(() {
        _hasLocationPermission = hasPermission;
      });

      if (hasPermission) {
        await _loadCoffeeShops();
      } else {
        setState(() {
          _isLoading = false;
        });
        // 显示权限被拒绝的提示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('无法获取位置权限，请在系统设置中授权'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('初始化失败: $e');
      // 记录详细错误信息
      if (e is Exception) {
        print('错误详情: ${e.toString()}');
      }

      setState(() {
        _isLoading = false;
      });

      // 向用户显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('初始化地图服务失败: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadCoffeeShops({String keyword = '咖啡'}) async {
    try {
      final shops = await MapService.getNearbyShops(keyword: keyword);

      if (mounted) {
        setState(() {
          _coffeeShops = shops;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('加载咖啡店失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showShopDetails(CoffeeShop shop) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                shop.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (shop.address != null) Text(shop.address!),
              if (shop.vicinity.isNotEmpty && shop.address == null)
                Text(shop.vicinity),
              const SizedBox(height: 12),
              if (shop.tel != null && shop.tel!.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.blue, size: 18),
                    TextButton(
                      onPressed: () {
                        _launchPhoneCall(shop.tel!);
                      },
                      child: Text(shop.tel!),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              if (shop.distance != null)
                Text(
                  '${widget.l10n.distance}: ${_formatDistance(shop.distance!)}',
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _launchNavigationApp(shop);
                },
                icon: const Icon(Icons.directions),
                label: Text(widget.l10n.directions),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDistance(int distance) {
    if (distance < 1000) {
      return '$distance ${widget.l10n.meters}';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} ${widget.l10n.kilometers}';
    }
  }

  Future<void> _launchNavigationApp(CoffeeShop shop) async {
    try {
      // 先检查高德地图是否已安装
      final isMapAppInstalled = await MapService.isAMapInstalled();

      final mapUrl = MapService.getDirectionsUrl(shop.lat, shop.lng, shop.name);

      if (isMapAppInstalled && await canLaunchUrl(Uri.parse(mapUrl))) {
        // 如果已安装高德地图，直接打开
        await launchUrl(Uri.parse(mapUrl));
      } else {
        // 如果未安装或无法打开，使用网页版导航
        final webUrl = MapService.getWebDirectionsUrl(
          shop.lat,
          shop.lng,
          shop.name,
        );

        if (await canLaunchUrl(Uri.parse(webUrl))) {
          await launchUrl(
            Uri.parse(webUrl),
            mode: LaunchMode.externalApplication,
          );
        } else {
          // 如果连网页版都无法打开，显示错误提示
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.l10n.unableToOpenMap),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('启动导航失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.l10n.navigationError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchPhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasLocationPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.l10n.locationPermissionDenied),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _checkPermissionAndLoadData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
              ),
              child: Text(widget.l10n.requestLocationPermission),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: widget.l10n.searchNearby,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _loadCoffeeShops();
                },
              ),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _isLoading = true;
                });
                _loadCoffeeShops(keyword: value);
              }
            },
          ),
        ),
        Expanded(
          child:
              _isLoading
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Colors.brown),
                        const SizedBox(height: 16),
                        Text(widget.l10n.loadingCoffeeshops),
                      ],
                    ),
                  )
                  : _coffeeShops.isEmpty
                  ? Center(
                    child: Text(
                      widget.l10n.noCoffeeshopsFound,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _coffeeShops.length,
                    itemBuilder: (context, index) {
                      final shop = _coffeeShops[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.brown[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.local_cafe,
                              color: Colors.brown,
                              size: 30,
                            ),
                          ),
                          title: Text(
                            shop.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(shop.vicinity),
                              const SizedBox(height: 4),
                              if (shop.distance != null)
                                Text(
                                  _formatDistance(shop.distance!),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.directions),
                            color: Colors.blue,
                            onPressed: () {
                              _launchNavigationApp(shop);
                            },
                          ),
                          onTap: () {
                            _showShopDetails(shop);
                          },
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
