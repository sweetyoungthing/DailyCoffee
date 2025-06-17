import 'package:flutter/material.dart';
import 'db/coffee_db.dart';
import 'db/coffee_record.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  int _touchedIndex = -1;
  Map<String, int> _brandStats = {};
  Map<String, int> _typeStats = {};

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final all = await CoffeeDB().getRecordsByMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    final lastMonth =
        _selectedMonth.month == 1
            ? DateTime(_selectedMonth.year - 1, 12)
            : DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    final lastAll = await CoffeeDB().getRecordsByMonth(
      lastMonth.year,
      lastMonth.month,
    );

    // 计算品牌和类型统计
    final brandStats = <String, int>{};
    final typeStats = <String, int>{};
    for (final record in all) {
      brandStats[record.brand] = (brandStats[record.brand] ?? 0) + record.price;
      typeStats[record.type] = (typeStats[record.type] ?? 0) + record.price;
    }

    setState(() {
      _records = all;
      _totalCost = all.fold(0, (sum, r) => sum + r.price);
      _lastMonthCost = lastAll.fold(0, (sum, r) => sum + r.price);
      _touchedIndex = -1;
      _brandStats = brandStats;
      _typeStats = typeStats;
    });
  }

  // 获取品牌消费占比数据
  List<PieChartSectionData> _getBrandSections() {
    final sortedBrands =
        _brandStats.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    // 如果没有数据，返回一个默认的灰色部分
    if (sortedBrands.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey.shade300,
          value: 100,
          title: '',
          radius: 100.0,
          titleStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ];
    }

    final colors = [
      const Color(0xFF8D6E63), // 棕色
      const Color(0xFFFF9800), // 橙色
      const Color(0xFF9C27B0), // 紫色
      const Color(0xFF2196F3), // 蓝色
      const Color(0xFF4CAF50), // 绿色
      const Color(0xFFE91E63), // 粉色
      const Color(0xFF3F51B5), // 靛蓝色
    ];

    int i = 0;
    return sortedBrands.map((e) {
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 105.0 : 100.0;
      final color = colors[i % colors.length];
      final percent = (e.value / _totalCost * 100).toStringAsFixed(1);
      i++;
      return PieChartSectionData(
        color: color,
        value: e.value.toDouble(),
        title: '$percent%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
      );
    }).toList();
  }

  // 获取咖啡品类占比数据
  List<PieChartSectionData> _getTypeSections() {
    final sortedTypes =
        _typeStats.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    if (sortedTypes.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey.shade300,
          value: 100,
          title: '',
          radius: 100.0,
          titleStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ];
    }

    final colors = [
      const Color(0xFF795548), // 深棕色
      const Color(0xFFA1887F), // 浅棕色
      const Color(0xFF8D6E63), // 中棕色
      const Color(0xFF6D4C41), // 暗棕色
      const Color(0xFF5D4037), // 深暗棕色
    ];

    int i = 0;
    return sortedTypes.map((e) {
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 105.0 : 100.0;
      final color = colors[i % colors.length];
      final percent = (e.value / _totalCost * 100).toStringAsFixed(1);
      i++;
      return PieChartSectionData(
        color: color,
        value: e.value.toDouble(),
        title: '$percent%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
      );
    }).toList();
  }

  // 获取每日消费趋势数据
  List<FlSpot> _getDailyTrend() {
    final dailyStats = <int, int>{};
    for (final record in _records) {
      final day = record.createdAt.day;
      dailyStats[day] = (dailyStats[day] ?? 0) + record.price;
    }

    // 确保每天都有数据点，没有数据的日期显示为0
    final spots = <FlSpot>[];
    int maxDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;

    for (int day = 1; day <= maxDay; day++) {
      spots.add(FlSpot(day.toDouble(), (dailyStats[day] ?? 0).toDouble()));
    }

    return spots;
  }

  Future<void> _pickMonth() async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(now.year - 3, 1),
      lastDate: DateTime(now.year + 1, 12),
      helpText: l10n.selectMonth,
      fieldLabelText: l10n.month,
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
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _exporting = true;
    });
    final buffer = StringBuffer();
    buffer.writeln(
      '${l10n.brand},${l10n.type},${l10n.size},${l10n.price},${l10n.caffeine},${l10n.time}',
    );
    for (final r in _records) {
      buffer.writeln(
        '${r.brand},${r.type},${r.size},${r.price},${r.caffeine},${DateFormat('yyyy-MM-dd HH:mm').format(r.createdAt)}',
      );
    }
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/coffee_bill_${_selectedMonth.year}_${_selectedMonth.month}.csv',
    );
    await file.writeAsString(buffer.toString(), flush: true);
    setState(() {
      _exporting = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.exportSuccess(file.path))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bills),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _pickMonth,
          ),
          IconButton(
            icon:
                _exporting
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.download),
            onPressed: _exporting ? null : _exportCSV,
          ),
        ],
      ),
      body:
          _records.isEmpty
              ? Center(child: Text(l10n.noRecords))
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              l10n.monthlyConsumption,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            Text(
                              '${l10n.unitCurrency}$_totalCost',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.brown,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_selectedMonth.month != 1 ||
                            _selectedMonth.year != DateTime.now().year) ...[
                          _buildCompareWidget(),
                        ],
                      ],
                    ),
                  ),

                  // 品牌消费占比饼图
                  Container(
                    height: 350,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.brandConsumption,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Center(
                            child:
                                _brandStats.isEmpty
                                    ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.pie_chart_outline,
                                          size: 64,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          '',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    )
                                    : AspectRatio(
                                      aspectRatio: 1,
                                      child: PieChart(
                                        PieChartData(
                                          pieTouchData: PieTouchData(
                                            touchCallback: (
                                              FlTouchEvent event,
                                              pieTouchResponse,
                                            ) {
                                              setState(() {
                                                if (!event
                                                        .isInterestedForInteractions ||
                                                    pieTouchResponse == null ||
                                                    pieTouchResponse
                                                            .touchedSection ==
                                                        null) {
                                                  _touchedIndex = -1;
                                                  return;
                                                }
                                                _touchedIndex =
                                                    pieTouchResponse
                                                        .touchedSection!
                                                        .touchedSectionIndex;
                                              });
                                            },
                                          ),
                                          borderData: FlBorderData(show: false),
                                          sectionsSpace: 2,
                                          centerSpaceRadius: 40,
                                          sections: _getBrandSections(),
                                        ),
                                      ),
                                    ),
                          ),
                        ),
                        if (_touchedIndex != -1 &&
                            _getBrandSections().length > _touchedIndex) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.brown.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child:
                                (() {
                                  final sections = _getBrandSections();
                                  if (_touchedIndex < 0 ||
                                      _touchedIndex >= sections.length)
                                    return const Text('');
                                  final index = _touchedIndex;
                                  final sortedBrands =
                                      _brandStats.entries.toList()..sort(
                                        (a, b) => b.value.compareTo(a.value),
                                      );
                                  if (index >= sortedBrands.length)
                                    return const Text('');
                                  final entry = sortedBrands[index];
                                  final percent = (entry.value /
                                          _totalCost *
                                          100)
                                      .toStringAsFixed(1);
                                  return Text(
                                    '${entry.key}: ${l10n.unitCurrency}${entry.value} (${percent}%)',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                })(),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 每日消费趋势折线图
                  Container(
                    height: 300,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.dailyTrend,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: true,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey.withOpacity(0.2),
                                    strokeWidth: 1,
                                  );
                                },
                                getDrawingVerticalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey.withOpacity(0.2),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        '${l10n.unitCurrency}${value.toInt()}',
                                        style: const TextStyle(
                                          color: Color(0xFF606060),
                                          fontSize: 10,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 24,
                                    getTitlesWidget: (value, meta) {
                                      if (value.toInt() % 5 == 0 ||
                                          value.toInt() == 1) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ),
                                          child: Text(
                                            '${value.toInt()}${l10n.day}',
                                            style: const TextStyle(
                                              color: Color(0xFF606060),
                                              fontSize: 10,
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                  ),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.withOpacity(0.2),
                                  ),
                                  left: BorderSide(
                                    color: Colors.grey.withOpacity(0.2),
                                  ),
                                ),
                              ),
                              minX: 1,
                              maxX:
                                  DateTime(
                                    _selectedMonth.year,
                                    _selectedMonth.month + 1,
                                    0,
                                  ).day.toDouble(),
                              minY: 0,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _getDailyTrend(),
                                  isCurved: true,
                                  color: Colors.brown,
                                  barWidth: 3,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (
                                      spot,
                                      percent,
                                      barData,
                                      index,
                                    ) {
                                      return FlDotCirclePainter(
                                        radius: 4,
                                        color: Colors.brown,
                                        strokeWidth: 2,
                                        strokeColor: Colors.white,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.brown.withOpacity(0.3),
                                        Colors.brown.withOpacity(0.05),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  tooltipBgColor: Colors.brown.withOpacity(0.8),
                                  tooltipRoundedRadius: 8,
                                  getTooltipItems: (
                                    List<LineBarSpot> touchedBarSpots,
                                  ) {
                                    return touchedBarSpots.map((barSpot) {
                                      final day = barSpot.x.toInt();
                                      final amount = barSpot.y.toInt();
                                      return LineTooltipItem(
                                        '${day}${l10n.day}: ${l10n.unitCurrency}$amount',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                                handleBuiltInTouches: true,
                                getTouchedSpotIndicator: (
                                  LineChartBarData barData,
                                  List<int> spotIndexes,
                                ) {
                                  return spotIndexes.map((spotIndex) {
                                    return TouchedSpotIndicatorData(
                                      FlLine(
                                        color: Colors.brown,
                                        strokeWidth: 2,
                                      ),
                                      FlDotData(
                                        getDotPainter: (
                                          spot,
                                          percent,
                                          barData,
                                          index,
                                        ) {
                                          return FlDotCirclePainter(
                                            radius: 6,
                                            color: Colors.brown,
                                            strokeWidth: 2,
                                            strokeColor: Colors.white,
                                          );
                                        },
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 咖啡品类占比饼图
                  Container(
                    height: 350,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.typeConsumption,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Center(
                            child:
                                _typeStats.isEmpty
                                    ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.pie_chart_outline,
                                          size: 64,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          '',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    )
                                    : AspectRatio(
                                      aspectRatio: 1,
                                      child: PieChart(
                                        PieChartData(
                                          pieTouchData: PieTouchData(
                                            touchCallback: (
                                              FlTouchEvent event,
                                              pieTouchResponse,
                                            ) {
                                              setState(() {
                                                if (!event
                                                        .isInterestedForInteractions ||
                                                    pieTouchResponse == null ||
                                                    pieTouchResponse
                                                            .touchedSection ==
                                                        null) {
                                                  _touchedIndex = -1;
                                                  return;
                                                }
                                                _touchedIndex =
                                                    pieTouchResponse
                                                        .touchedSection!
                                                        .touchedSectionIndex;
                                              });
                                            },
                                          ),
                                          borderData: FlBorderData(show: false),
                                          sectionsSpace: 2,
                                          centerSpaceRadius: 40,
                                          sections: _getTypeSections(),
                                        ),
                                      ),
                                    ),
                          ),
                        ),
                        if (_touchedIndex != -1 &&
                            _getTypeSections().length > _touchedIndex) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.brown.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child:
                                (() {
                                  final sections = _getTypeSections();
                                  if (_touchedIndex < 0 ||
                                      _touchedIndex >= sections.length)
                                    return const Text('');
                                  final index = _touchedIndex;
                                  final sortedTypes =
                                      _typeStats.entries.toList()..sort(
                                        (a, b) => b.value.compareTo(a.value),
                                      );
                                  if (index >= sortedTypes.length)
                                    return const Text('');
                                  final entry = sortedTypes[index];
                                  final percent = (entry.value /
                                          _totalCost *
                                          100)
                                      .toStringAsFixed(1);
                                  return Text(
                                    '${entry.key}: ${l10n.unitCurrency}${entry.value} (${percent}%)',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                })(),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 消费记录列表
                  Text(
                    l10n.consumptionRecords,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_records.length, (i) {
                    final r = _records[i];
                    return ListTile(
                      leading: const Icon(Icons.coffee, color: Colors.brown),
                      title: Text('${r.brand} ${r.type}'),
                      subtitle: Text(
                        '${r.size} ${DateFormat('MM-dd HH:mm').format(r.createdAt)}',
                      ),
                      trailing: Text(
                        '${l10n.unitCurrency}${r.price}',
                        style: const TextStyle(
                          color: Colors.brown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ],
              ),
    );
  }

  Widget _buildCompareWidget() {
    final l10n = AppLocalizations.of(context)!;
    final diff = _totalCost - _lastMonthCost;
    if (_lastMonthCost == 0) {
      return Text(
        l10n.noLastMonthData,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      );
    } else if (diff == 0) {
      return Text(
        l10n.noChange,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      );
    } else {
      return Text(
        l10n.comparedToLastMonth(diff.abs(), diff > 0 ? 'true' : 'false'),
        style: TextStyle(
          color: diff > 0 ? Colors.red : Colors.green,
          fontSize: 14,
        ),
      );
    }
  }
}
