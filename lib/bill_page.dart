import 'package:flutter/material.dart';
import 'db/coffee_db.dart';
import 'db/coffee_record.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class BillPage extends StatefulWidget {
  const BillPage({Key? key}) : super(key: key);

  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  List<CoffeeRecord> _records = [];
  int _totalCost = 0;
  int _lastMonthCost = 0;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final all = await CoffeeDB().getRecordsByMonth(_selectedMonth.year, _selectedMonth.month);
    final lastMonth = _selectedMonth.month == 1
        ? DateTime(_selectedMonth.year - 1, 12)
        : DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    final lastAll = await CoffeeDB().getRecordsByMonth(lastMonth.year, lastMonth.month);
    setState(() {
      _records = all;
      _totalCost = all.fold(0, (sum, r) => sum + r.price);
      _lastMonthCost = lastAll.fold(0, (sum, r) => sum + r.price);
    });
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(now.year - 3, 1),
      lastDate: DateTime(now.year + 1, 12),
      helpText: '选择月份',
      fieldLabelText: '月份',
      fieldHintText: 'yyyy-MM',
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      selectableDayPredicate: (date) => date.day == 1,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
      _loadRecords();
    }
  }

  Future<void> _exportCSV() async {
    setState(() { _exporting = true; });
    final buffer = StringBuffer();
    buffer.writeln('品牌,品类,杯型,价格,咖啡因,时间');
    for (final r in _records) {
      buffer.writeln('${r.brand},${r.type},${r.size},${r.price},${r.caffeine},${DateFormat('yyyy-MM-dd HH:mm').format(r.createdAt)}');
    }
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/coffee_bill_${_selectedMonth.year}_${_selectedMonth.month}.csv');
    await file.writeAsString(buffer.toString(), flush: true);
    setState(() { _exporting = false; });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已导出到: ${file.path}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_selectedMonth.year}年${_selectedMonth.month}月账单'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: '选择月份',
            onPressed: _pickMonth,
          ),
          IconButton(
            icon: _exporting ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.download),
            tooltip: '导出CSV',
            onPressed: _exporting ? null : _exportCSV,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('${_selectedMonth.year}年${_selectedMonth.month}月总消费', style: TextStyle(color: Colors.grey[700])),
                    Text('¥$_totalCost', style: const TextStyle(fontSize: 20, color: Colors.brown, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                if (_selectedMonth.month != 1 || _selectedMonth.year != DateTime.now().year) ...[
                  _buildCompareWidget(),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _records.isEmpty
                ? const Center(child: Text('暂无消费记录'))
                : ListView.separated(
                    itemCount: _records.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final r = _records[i];
                      return ListTile(
                        leading: const Icon(Icons.coffee, color: Colors.brown),
                        title: Text('${r.brand} ${r.type}'),
                        subtitle: Text('${r.size} ${DateFormat('MM-dd HH:mm').format(r.createdAt)}'),
                        trailing: Text('¥${r.price}', style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompareWidget() {
    final diff = _totalCost - _lastMonthCost;
    final percent = _lastMonthCost == 0 ? null : (diff / _lastMonthCost * 100);
    String text;
    Color color;
    if (_lastMonthCost == 0) {
      text = '无上月数据';
      color = Colors.grey;
    } else if (diff == 0) {
      text = '与上月持平';
      color = Colors.grey;
    } else if (diff > 0) {
      text = '比上月多支出 ¥$diff (${percent!.toStringAsFixed(1)}%)';
      color = Colors.red;
    } else {
      text = '比上月少支出 ¥${-diff} (${percent!.abs().toStringAsFixed(1)}%)';
      color = Colors.green;
    }
    return Text(text, style: TextStyle(color: color, fontSize: 14));
  }
} 