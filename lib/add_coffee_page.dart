import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db/coffee_db.dart';
import 'db/coffee_record.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'utils/coffee_display_helper.dart';
import 'services/notification_service.dart';

class AddCoffeePage extends StatefulWidget {
  const AddCoffeePage({super.key});

  @override
  State<AddCoffeePage> createState() => _AddCoffeePageState();
}

class _AddCoffeePageState extends State<AddCoffeePage> {
  // 品牌、品类、杯型数据
  late List<Map<String, dynamic>> brands;
  late List<String> types;
  late List<Map<String, dynamic>> sizes;

  int brandIndex = 0;
  int typeIndex = 0;
  int sizeIndex = 1;

  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _caffeineController = TextEditingController();
  final _notificationService = NotificationService();

  int get caffeine => _calcCaffeine();
  int get price => int.tryParse(_priceController.text) ?? 0;

  void _initializeData() {
    final l10n = AppLocalizations.of(context)!;

    // 使用本地化的品牌名称
    brands = [
      {'name': l10n.starbucks, 'icon': Icons.local_cafe, 'id': 'starbucks'},
      {'name': l10n.costa, 'icon': Icons.coffee, 'id': 'costa'},
      {'name': l10n.luckin, 'icon': Icons.coffee_outlined, 'id': 'luckin'},
    ];

    // 使用本地化的咖啡品类名称
    types = [l10n.americano, l10n.latte, l10n.cappuccino];

    // 使用本地化的杯型名称
    sizes = [
      {'name': l10n.small, 'ml': 240, 'id': 'small'},
      {'name': l10n.medium, 'ml': 360, 'id': 'medium'},
      {'name': l10n.large, 'ml': 480, 'id': 'large'},
    ];
  }

  int _calcCaffeine() {
    // 简单规则：美式咖啡 95mg/240ml，拿铁/卡布奇诺 80mg/240ml，按比例换算
    int base = 0;
    if (typeIndex == 0)
      base = 95;
    else
      base = 80;
    int ml = sizes[sizeIndex]['ml'];
    return (base * ml / 240).round();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeData();
    // 只在初始化时设置默认价格
    int price = 12;
    if (brandIndex == 0) price = 18; // 星巴克
    if (brandIndex == 1) price = 16; // Costa
    if (brandIndex == 2) price = 12; // 瑞幸
    _priceController.text = price.toString();
  }

  void _onConfirm() async {
    final record = CoffeeRecord(
      brand: brands[brandIndex]['id'],
      type: ['americano', 'latte', 'cappuccino'][typeIndex],
      size: ['small', 'medium', 'large'][sizeIndex],
      volume: sizes[sizeIndex]['ml'],
      caffeine: caffeine,
      createdAt: DateTime.now(),
      price: price,
    );
    await CoffeeDB().insertRecord(record);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addCoffee),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _onConfirm),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(l10n.selectBrand),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children:
                    brands.asMap().entries.map((entry) {
                      final index = entry.key;
                      final brand = entry.value;
                      return RadioListTile(
                        title: Text(brand['name']),
                        secondary: Icon(brand['icon'] as IconData),
                        value: index,
                        groupValue: brandIndex,
                        onChanged: (int? value) {
                          if (value != null) {
                            setState(() {
                              brandIndex = value;
                            });
                          }
                        },
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: 24),
            Text(l10n.selectType),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children:
                    types.asMap().entries.map((entry) {
                      final index = entry.key;
                      final type = entry.value;
                      return RadioListTile(
                        title: Text(type),
                        value: index,
                        groupValue: typeIndex,
                        onChanged: (int? value) {
                          if (value != null) {
                            setState(() {
                              typeIndex = value;
                            });
                          }
                        },
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: 24),
            Text(l10n.selectSize),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children:
                    sizes.asMap().entries.map((entry) {
                      final index = entry.key;
                      final size = entry.value;
                      return RadioListTile(
                        title: Text('${size['name']} (${size['ml']}ml)'),
                        value: index,
                        groupValue: sizeIndex,
                        onChanged: (int? value) {
                          if (value != null) {
                            setState(() {
                              sizeIndex = value;
                            });
                          }
                        },
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: 24),
            Text(l10n.estimatedCaffeine),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$caffeine ${l10n.unitMg}',
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.brown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(l10n.equivalentToAmericano),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(l10n.price),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: l10n.enterPrice,
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.brown),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(l10n.unitCurrency),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 246, 245, 244),
              ),
              onPressed: _onConfirm,
              child: Text(l10n.confirm),
            ),
          ],
        ),
      ),
    );
  }
}
