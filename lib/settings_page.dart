import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_page.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  String _selectedLanguage = '简体中文';
  int _caffeineLimit = 400;
  int _budgetLimit = 1000;
  bool _enableNotification = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _selectedLanguage = prefs.getString('language') ?? '简体中文';
      _caffeineLimit = prefs.getInt('caffeineLimit') ?? 400;
      _budgetLimit = prefs.getInt('budgetLimit') ?? 1000;
      _enableNotification = prefs.getBool('enableNotification') ?? true;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      _isDarkMode = value;
    });

    // 更新全局主题
    final appState = MyApp.of(context);
    if (appState != null) {
      appState.updateTheme(value);
    }
  }

  Future<void> _toggleNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableNotification', value);
    setState(() {
      _enableNotification = value;
    });
  }

  Future<void> _goToNotificationSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationPage()),
    );
  }

  Future<void> _changeLanguage() async {
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => SimpleDialog(
            title: const Text('选择语言'),
            children: [
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, '简体中文'),
                child: const Text('简体中文'),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, 'English'),
                child: const Text('English'),
              ),
            ],
          ),
    );
    if (result != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', result);
      setState(() {
        _selectedLanguage = result;
      });

      // 更新全局语言设置
      final appState = MyApp.of(context);
      if (appState != null) {
        appState.updateLanguage(result);
      }
    }
  }

  Future<void> _setCaffeineLimit() async {
    final controller = TextEditingController(text: _caffeineLimit.toString());
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('设置咖啡因每日限制'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '请输入限制值（mg）',
                suffixText: 'mg',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('保存'),
              ),
            ],
          ),
    );
    if (result != null && result.trim().isNotEmpty) {
      final limit = int.tryParse(result.trim());
      if (limit != null && limit > 0) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('caffeineLimit', limit);
        setState(() {
          _caffeineLimit = limit;
        });
      }
    }
  }

  Future<void> _setBudgetLimit() async {
    final controller = TextEditingController(text: _budgetLimit.toString());
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('设置每月预算'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '请输入预算金额（元）',
                suffixText: '元',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('保存'),
              ),
            ],
          ),
    );
    if (result != null && result.trim().isNotEmpty) {
      final limit = int.tryParse(result.trim());
      if (limit != null && limit > 0) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('budgetLimit', limit);
        setState(() {
          _budgetLimit = limit;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String themeModeText = _isDarkMode ? '已开启' : '已关闭';

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '显示',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: Text('深色模式 ($themeModeText)'),
            value: _isDarkMode,
            onChanged: _toggleDarkMode,
          ),
          ListTile(
            title: const Text('语言'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedLanguage,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: _changeLanguage,
          ),

          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '通知',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('启用通知'),
            value: _enableNotification,
            onChanged: _toggleNotification,
          ),
          ListTile(
            title: const Text('通知设置'),
            trailing: const Icon(Icons.chevron_right),
            enabled: _enableNotification,
            onTap: _enableNotification ? _goToNotificationSettings : null,
          ),

          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '个性化',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text('咖啡因每日限制'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_caffeineLimit mg',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: _setCaffeineLimit,
          ),
          ListTile(
            title: const Text('每月预算'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '¥$_budgetLimit',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: _setBudgetLimit,
          ),
        ],
      ),
    );
  }
}
