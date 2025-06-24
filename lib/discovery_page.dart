import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
    return CoffeeshopMapView(l10n: l10n);
  }
}

class CoffeeshopMapView extends StatefulWidget {
  final AppLocalizations l10n;

  const CoffeeshopMapView({Key? key, required this.l10n}) : super(key: key);

  @override
  State<CoffeeshopMapView> createState() => _CoffeeshopMapViewState();
}

class _CoffeeshopMapViewState extends State<CoffeeshopMapView> {
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _hasLocationPermission = false;
  List<CoffeeShop> _coffeeShops = [];
  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(22.5431, 114.0579), // 深圳位置作为默认位置
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoadData();
  }

  Future<void> _checkPermissionAndLoadData() async {
    final hasPermission = await MapService.checkLocationPermission();

    setState(() {
      _hasLocationPermission = hasPermission;
      _isLoading = hasPermission; // 只有当有权限时才显示加载中
    });

    if (hasPermission) {
      _loadCoffeeShops();
      _updateCurrentLocation();
    }
  }

  Future<void> _loadCoffeeShops() async {
    final shops = await MapService.getNearbyShops();

    // 一系列咖啡店标记
    Set<Marker> markers = {};
    for (var shop in shops) {
      markers.add(
        Marker(
          markerId: MarkerId(shop.id),
          position: LatLng(shop.lat, shop.lng),
          infoWindow: InfoWindow(title: shop.name, snippet: shop.vicinity),
          onTap: () {
            _showShopDetails(shop);
          },
        ),
      );
    }

    setState(() {
      _coffeeShops = shops;
      _markers.addAll(markers);
      _isLoading = false;
    });
  }

  Future<void> _updateCurrentLocation() async {
    final position = await MapService.getCurrentLocation();
    if (position != null && mounted) {
      setState(() {
        _initialCameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14,
        );
      });

      _controller?.animateCamera(
        CameraUpdate.newCameraPosition(_initialCameraPosition),
      );
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
              Text(shop.vicinity),
              const SizedBox(height: 12),
              if (shop.rating != null)
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    Text(' ${shop.rating} (${shop.userRatingsTotal ?? 0})'),
                  ],
                ),
              const SizedBox(height: 8),
              if (shop.distance != null)
                Text(
                  '${widget.l10n.distance}: ${_formatDistance(shop.distance!)}',
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    shop.openNow == true
                        ? Icons.check_circle
                        : Icons.access_time,
                    color: shop.openNow == true ? Colors.green : Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    shop.openNow == true
                        ? widget.l10n.openNow
                        : (shop.openNow == false
                            ? widget.l10n.closed
                            : widget.l10n.unknown),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _launchMapsUrl(shop.lat, shop.lng);
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

  Future<void> _launchMapsUrl(double lat, double lng) async {
    final url = MapService.getDirectionsUrl(lat, lng);
    final uri = Uri.parse(url);
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

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _initialCameraPosition,
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          onMapCreated: (controller) {
            _controller = controller;
          },
        ),
        if (_isLoading)
          Container(
            color: Colors.white.withOpacity(0.7),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.brown),
                  const SizedBox(height: 16),
                  Text(widget.l10n.loadingCoffeeshops),
                ],
              ),
            ),
          ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Card(
            elevation: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              height: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.l10n.nearbyTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLoading
                        ? widget.l10n.loadingCoffeeshops
                        : _coffeeShops.isEmpty
                        ? widget.l10n.noCoffeeshopsFound
                        : '${_coffeeShops.length} ${widget.l10n.coffeeTypes}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const Spacer(),
                  TextField(
                    decoration: InputDecoration(
                      hintText: widget.l10n.searchNearby,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      isDense: true,
                    ),
                    onSubmitted: (value) {
                      // 实现搜索功能
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
