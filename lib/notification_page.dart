import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _dailyReminder = true;
  bool _weeklyReport = true;
  bool _caffeineAlert = true;
  bool _budgetAlert = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyReminder = prefs.getBool('dailyReminder') ?? true;
      _weeklyReport = prefs.getBool('weeklyReport') ?? true;
      _caffeineAlert = prefs.getBool('caffeineAlert') ?? true;
      _budgetAlert = prefs.getBool('budgetAlert') ?? true;

      final hour = prefs.getInt('reminderTimeHour') ?? 9;
      final minute = prefs.getInt('reminderTimeMinute') ?? 0;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dailyReminder', _dailyReminder);
    await prefs.setBool('weeklyReport', _weeklyReport);
    await prefs.setBool('caffeineAlert', _caffeineAlert);
    await prefs.setBool('budgetAlert', _budgetAlert);
    await prefs.setInt('reminderTimeHour', _reminderTime.hour);
    await prefs.setInt('reminderTimeMinute', _reminderTime.minute);
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );

    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
      await _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('通知设置')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('每日提醒时间'),
            subtitle: Text('每天 ${_reminderTime.format(context)}'),
            trailing: const Icon(Icons.access_time),
            onTap: _selectReminderTime,
          ),
          const Divider(),

          SwitchListTile(
            title: const Text('每日记录提醒'),
            subtitle: const Text('提醒你记录当天的咖啡消费'),
            value: _dailyReminder,
            onChanged: (value) {
              setState(() {
                _dailyReminder = value;
              });
              _saveSettings();
            },
          ),

          SwitchListTile(
            title: const Text('周报告'),
            subtitle: const Text('每周发送消费统计和分析'),
            value: _weeklyReport,
            onChanged: (value) {
              setState(() {
                _weeklyReport = value;
              });
              _saveSettings();
            },
          ),

          SwitchListTile(
            title: const Text('咖啡因超额提醒'),
            subtitle: const Text('当接近每日咖啡因限制时提醒你'),
            value: _caffeineAlert,
            onChanged: (value) {
              setState(() {
                _caffeineAlert = value;
              });
              _saveSettings();
            },
          ),

          SwitchListTile(
            title: const Text('预算提醒'),
            subtitle: const Text('当接近月度预算限制时提醒你'),
            value: _budgetAlert,
            onChanged: (value) {
              setState(() {
                _budgetAlert = value;
              });
              _saveSettings();
            },
          ),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '注意：通知功能需要在系统设置中允许应用发送通知',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
