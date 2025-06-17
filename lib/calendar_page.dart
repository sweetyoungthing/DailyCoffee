import 'package:flutter/material.dart';
import 'add_coffee_page.dart';
import 'db/coffee_db.dart';
import 'db/coffee_record.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  Map<DateTime, List<CoffeeRecord>> _events = {};
  int _totalCups = 0;
  int _totalDays = 0;
  int _totalCost = 0;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await CoffeeDB().getRecordsByMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    final events = <DateTime, List<CoffeeRecord>>{};
    for (var r in records) {
      final day = DateTime(
        r.createdAt.year,
        r.createdAt.month,
        r.createdAt.day,
      );
      events.putIfAbsent(day, () => []).add(r);
    }
    setState(() {
      _events = events;
      _totalCups = records.length;
      _totalDays = events.length;
      _totalCost = records.fold(0, (sum, r) => sum + (r.price));
    });
  }

  void _onAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCoffeePage()),
    );
    if (result == true) {
      _loadRecords();
    }
  }

  void _onMonthChanged(DateTime focusedDay) {
    setState(() {
      _selectedMonth = DateTime(focusedDay.year, focusedDay.month);
    });
    _loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calendar),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
              ),
              onPressed: _onAdd,
              child: const Text('+ 添加'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar<CoffeeRecord>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _selectedMonth,
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            headerVisible: false,
            rowHeight: 52,
            eventLoader: (day) {
              final d = DateTime(day.year, day.month, day.day);
              return _events[d] ?? [];
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final events =
                    _events[DateTime(day.year, day.month, day.day)] ?? [];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${day.day}', style: const TextStyle(fontSize: 14)),
                    if (events.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.coffee,
                              size: 12,
                              color: Colors.brown,
                            ),
                            if (events.length > 1)
                              Text(
                                '×${events.length}',
                                style: const TextStyle(
                                  color: Colors.brown,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                );
              },
              todayBuilder: (context, day, focusedDay) {
                final events =
                    _events[DateTime(day.year, day.month, day.day)] ?? [];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.brown,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (events.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.coffee,
                              size: 12,
                              color: Colors.brown,
                            ),
                            if (events.length > 1)
                              Text(
                                '×${events.length}',
                                style: const TextStyle(
                                  color: Colors.brown,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                final events =
                    _events[DateTime(day.year, day.month, day.day)] ?? [];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.brown,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (events.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.coffee,
                              size: 12,
                              color: Colors.brown,
                            ),
                            if (events.length > 1)
                              Text(
                                '×${events.length}',
                                style: const TextStyle(
                                  color: Colors.brown,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
            onPageChanged: _onMonthChanged,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.brown,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.brown,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(color: Colors.transparent),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: l10n.totalCost,
                  value: '${l10n.unitCurrency}$_totalCost',
                ),
                _StatItem(
                  label: l10n.consumptionDays,
                  value: '${_totalDays}${l10n.unitDay}',
                ),
                _StatItem(
                  label: l10n.totalCups,
                  value: '${_totalCups}${l10n.unitCup}',
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        onPressed: _onAdd,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.brown,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
