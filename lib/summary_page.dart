import 'package:flutter/material.dart';
import 'db/coffee_db.dart';
import 'db/coffee_record.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({Key? key}) : super(key: key);

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  List<CoffeeRecord> _todayRecords = [];
  int _currentCaffeine = 0;
  int _totalCups = 0;
  int _totalCaffeine = 0;
  List<FlSpot> _caffeineTrend = [];
  List<String> _trendLabels = [];
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _loadTodayRecords();
  }

  Future<void> _loadTodayRecords() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final all = await CoffeeDB().getRecordsByMonth(now.year, now.month);
    final today =
        all
            .where(
              (r) => r.createdAt.isAfter(start) && r.createdAt.isBefore(end),
            )
            .toList();
    today.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    setState(() {
      _todayRecords = today;
      _totalCups = today.length;
      _totalCaffeine = today.fold(0, (sum, r) => sum + r.caffeine);
    });
    _calcCaffeineTrend();
  }

  void _calcCaffeineTrend() {
    // 以每小时为节点，计算每个时刻的剩余咖啡因
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 6); // 6:00 起
    final points = <FlSpot>[];
    final labels = <String>[];
    double lastCaffeine = 0;
    int recordIdx = 0;
    double currentCaffeine = 0;
    for (int h = 0; h <= 16; h++) {
      final t = start.add(Duration(hours: h));
      // 先衰减
      if (h > 0) {
        int hoursPassed = 1;
        lastCaffeine = lastCaffeine * pow(0.5, hoursPassed / 4).toDouble();
      }
      // 加上本时刻新摄入
      while (recordIdx < _todayRecords.length &&
          _todayRecords[recordIdx].createdAt.isBefore(
            t.add(const Duration(minutes: 1)),
          )) {
        lastCaffeine += _todayRecords[recordIdx].caffeine;
        recordIdx++;
      }
      points.add(FlSpot(h.toDouble(), lastCaffeine));
      labels.add(DateFormat('HH:mm').format(t));
      // 记录当前时刻的咖啡因含量
      if (now.isBefore(t.add(const Duration(hours: 1))) &&
          currentCaffeine == 0) {
        currentCaffeine = lastCaffeine;
      }
    }
    // 若当前时间晚于最后一个点
    if (currentCaffeine == 0 && points.isNotEmpty) {
      currentCaffeine = points.last.y;
    }
    setState(() {
      _caffeineTrend = points;
      _trendLabels = labels;
      _currentCaffeine = currentCaffeine.round();
      _touchedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayCaffeine =
        (_touchedIndex != null && _touchedIndex! < _caffeineTrend.length)
            ? _caffeineTrend[_touchedIndex!].y.round()
            : _currentCaffeine;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.track)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _StatCard(
                  title: '',
                  value: '$displayCaffeine ${l10n.unitMg}',
                  sub: l10n.currentCaffeine,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: '$_totalCups',
                  value: '',
                  sub: l10n.todayCups,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: '$_totalCaffeine ${l10n.unitMg}',
                  value: '',
                  sub: l10n.totalIntake,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Text(
              l10n.caffeineTrend,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: SizedBox(
              height: 180,
              child:
                  _caffeineTrend.isEmpty
                      ? const Center(child: Text('暂无数据'))
                      : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  if (value % 1 == 0 &&
                                      value >= 0 &&
                                      value < _trendLabels.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        _trendLabels[value.toInt()],
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
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
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: 16,
                          minY: 0,
                          lineBarsData: [
                            LineChartBarData(
                              spots: _caffeineTrend,
                              isCurved: true,
                              color: Colors.deepPurple,
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.deepPurple.withOpacity(0.1),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((
                                  LineBarSpot touchedSpot,
                                ) {
                                  return LineTooltipItem(
                                    '${touchedSpot.y.toStringAsFixed(1)} mg',
                                    const TextStyle(color: Colors.white),
                                  );
                                }).toList();
                              },
                            ),
                            touchCallback: (event, response) {
                              if (event is FlTapUpEvent ||
                                  event is FlLongPressEnd ||
                                  event is FlPanEndEvent) {
                                setState(() {
                                  _touchedIndex = null;
                                });
                              } else if (response != null &&
                                  response.lineBarSpots != null &&
                                  response.lineBarSpots!.isNotEmpty) {
                                setState(() {
                                  _touchedIndex =
                                      response.lineBarSpots!.first.x.toInt();
                                });
                              }
                            },
                          ),
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.todayRecords,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ..._todayRecords.map((r) => _CoffeeRecordCard(record: r)).toList(),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String sub;
  const _StatCard({
    required this.title,
    required this.value,
    required this.sub,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (title.isNotEmpty)
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (value.isNotEmpty)
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 4),
            Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _CoffeeRecordCard extends StatelessWidget {
  final CoffeeRecord record;
  const _CoffeeRecordCard({required this.record});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.coffee, color: Colors.brown, size: 32),
        title: Text(record.type),
        subtitle: Text(
          '${DateFormat('HH:mm').format(record.createdAt)} · ${record.caffeine}mg',
        ),
      ),
    );
  }
}
