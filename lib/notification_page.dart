import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _enableNotifications = false;
  bool _dailyReminder = false;
  bool _weeklyReport = false;
  bool _caffeineAlert = false;
  bool _budgetAlert = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enableNotifications = prefs.getBool('enableNotifications') ?? false;
      _dailyReminder = prefs.getBool('dailyReminder') ?? false;
      _weeklyReport = prefs.getBool('weeklyReport') ?? false;
      _caffeineAlert = prefs.getBool('caffeineAlert') ?? false;
      _budgetAlert = prefs.getBool('budgetAlert') ?? false;

      final hour = prefs.getInt('reminderTimeHour') ?? 20;
      final minute = prefs.getInt('reminderTimeMinute') ?? 0;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableNotifications', _enableNotifications);
    await prefs.setBool('dailyReminder', _dailyReminder);
    await prefs.setBool('weeklyReport', _weeklyReport);
    await prefs.setBool('caffeineAlert', _caffeineAlert);
    await prefs.setBool('budgetAlert', _budgetAlert);
    await prefs.setInt('reminderTimeHour', _reminderTime.hour);
    await prefs.setInt('reminderTimeMinute', _reminderTime.minute);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationSettings)),
      body: ListView(
        children: [
          // 主开关
          SwitchListTile(
            title: Text(l10n.enableNotifications),
            value: _enableNotifications,
            onChanged: (bool value) {
              setState(() {
                _enableNotifications = value;
                if (!value) {
                  _dailyReminder = false;
                  _weeklyReport = false;
                  _caffeineAlert = false;
                  _budgetAlert = false;
                }
              });
              _saveSettings();
            },
          ),

          const Divider(),

          // 每日提醒
          SwitchListTile(
            title: Text(l10n.dailyReminder),
            subtitle: Text(l10n.dailyReminderDesc),
            value: _dailyReminder && _enableNotifications,
            onChanged:
                _enableNotifications
                    ? (bool value) {
                      setState(() {
                        _dailyReminder = value;
                      });
                    }
                    : null,
          ),
          if (_dailyReminder && _enableNotifications)
            ListTile(
              title: Text(l10n.dailyReminderTime),
              trailing: Text(_reminderTime.format(context)),
              onTap: () async {
                final TimeOfDay? newTime = await showTimePicker(
                  context: context,
                  initialTime: _reminderTime,
                );
                if (newTime != null) {
                  setState(() {
                    _reminderTime = newTime;
                  });
                  await _saveSettings();
                }
              },
            ),

          // 周报告
          SwitchListTile(
            title: Text(l10n.weeklyReport),
            subtitle: Text(l10n.weeklyReportDesc),
            value: _weeklyReport && _enableNotifications,
            onChanged:
                _enableNotifications
                    ? (bool value) {
                      setState(() {
                        _weeklyReport = value;
                      });
                    }
                    : null,
          ),

          // 咖啡因提醒
          SwitchListTile(
            title: Text(l10n.caffeineAlert),
            subtitle: Text(l10n.caffeineAlertDesc),
            value: _caffeineAlert && _enableNotifications,
            onChanged:
                _enableNotifications
                    ? (bool value) {
                      setState(() {
                        _caffeineAlert = value;
                      });
                    }
                    : null,
          ),

          // 预算提醒
          SwitchListTile(
            title: Text(l10n.budgetAlert),
            subtitle: Text(l10n.budgetAlertDesc),
            value: _budgetAlert && _enableNotifications,
            onChanged:
                _enableNotifications
                    ? (bool value) {
                      setState(() {
                        _budgetAlert = value;
                      });
                    }
                    : null,
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.notificationPermissionNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
