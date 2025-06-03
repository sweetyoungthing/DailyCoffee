import 'package:flutter/material.dart';
import 'db/coffee_db.dart';
import 'db/coffee_record.dart';

class AddCoffeePage extends StatefulWidget {
  const AddCoffeePage({Key? key}) : super(key: key);

  @override
  State<AddCoffeePage> createState() => _AddCoffeePageState();
}

class _AddCoffeePageState extends State<AddCoffeePage> {
  // 品牌、品类、杯型数据
  final List<Map<String, dynamic>> brands = [
    {'name': '星巴克', 'icon': Icons.local_cafe},
    {'name': 'Costa', 'icon': Icons.coffee},
    {'name': '瑞幸', 'icon': Icons.coffee_outlined},
  ];
  final List<String> types = ['美式咖啡', '拿铁咖啡', '卡布奇诺'];
  final List<Map<String, dynamic>> sizes = [
    {'name': '小杯', 'ml': 240},
    {'name': '中杯', 'ml': 360},
    {'name': '大杯', 'ml': 480},
  ];

  int brandIndex = 0;
  int typeIndex = 0;
  int sizeIndex = 1;

  final TextEditingController _priceController = TextEditingController();

  int get caffeine => _calcCaffeine();
  int get price => int.tryParse(_priceController.text) ?? 0;

  int _calcCaffeine() {
    // 简单规则：美式咖啡 95mg/240ml，拿铁/卡布奇诺 80mg/240ml，按比例换算
    int base = 0;
    if (typeIndex == 0) base = 95;
    else base = 80;
    int ml = sizes[sizeIndex]['ml'];
    return (base * ml / 240).round();
  }

  @override
  void initState() {
    super.initState();
    // 只在初始化时设置默认价格
    int price = 12;
    if (brandIndex == 0) price = 18; // 星巴克
    if (brandIndex == 1) price = 16; // Costa
    if (brandIndex == 2) price = 12; // 瑞幸
    _priceController.text = price.toString();
  }

  void _onConfirm() async {
    final record = CoffeeRecord(
      brand: brands[brandIndex]['name'],
      type: types[typeIndex],
      size: sizes[sizeIndex]['name'],
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加咖啡'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _onConfirm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('选择品牌'),
            Row(
              children: List.generate(brands.length, (i) => GestureDetector(
                onTap: () {
                  setState(() {
                    brandIndex = i;
                  });
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: i == brandIndex ? Colors.brown : Colors.grey,
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Icon(brands[i]['icon'], size: 40, color: i == brandIndex ? Colors.brown : Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        brands[i]['name'],
                        style: TextStyle(
                          color: i == brandIndex ? Colors.brown : Colors.grey,
                          fontWeight: i == brandIndex ? FontWeight.bold : FontWeight.normal,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ),
            const SizedBox(height: 24),
            const Text('咖啡品类'),
            Row(
              children: List.generate(types.length, (i) => Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => typeIndex = i),
                  child: Card(
                    color: i == typeIndex ? Colors.brown[50] : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        children: [
                          Icon(Icons.coffee, color: i == typeIndex ? Colors.brown : Colors.grey),
                          const SizedBox(height: 4),
                          Text(types[i], style: TextStyle(color: i == typeIndex ? Colors.brown : Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
            ),
            const SizedBox(height: 24),
            const Text('杯型'),
            Row(
              children: List.generate(sizes.length, (i) => Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => sizeIndex = i),
                  child: Card(
                    shape: i == sizeIndex ? RoundedRectangleBorder(side: BorderSide(color: Colors.brown, width: 2)) : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        children: [
                          Icon(Icons.coffee, color: i == sizeIndex ? Colors.brown : Colors.grey),
                          const SizedBox(height: 4),
                          Text('${sizes[i]['name']}\n${sizes[i]['ml']}ml', textAlign: TextAlign.center, style: TextStyle(color: i == sizeIndex ? Colors.brown : Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
            ),
            const SizedBox(height: 24),
            const Text('预估咖啡因含量'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$caffeine mg', style: const TextStyle(fontSize: 32, color: Colors.brown, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('相当于一杯标准美式咖啡'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('价格'),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: '请输入价格',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.brown),
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('元'),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 246, 245, 244)),
              onPressed: _onConfirm,
              child: const Text('确认添加'),
            ),
          ],
        ),
      ),
    );
  }
} 