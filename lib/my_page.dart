import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'notification_page.dart';
import 'settings_page.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String _nickname = '未设置昵称';
  String? _avatarUrl;
  bool _isDarkMode = false;
  int _caffeineLimit = 400; // 默认400mg
  int _budgetLimit = 1000; // 默认1000元
  bool _enableNotification = true;
  String _selectedLanguage = '简体中文';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nickname = prefs.getString('nickname') ?? '未设置昵称';
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _caffeineLimit = prefs.getInt('caffeineLimit') ?? 400;
      _budgetLimit = prefs.getInt('budgetLimit') ?? 1000;
      _enableNotification = prefs.getBool('enableNotification') ?? true;
      _selectedLanguage = prefs.getString('language') ?? '简体中文';
    });
  }

  void _editNickname() async {
    final controller = TextEditingController(
      text: _nickname == '未设置昵称' ? '' : _nickname,
    );
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('编辑昵称'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: '请输入昵称'),
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nickname', result.trim());
      setState(() {
        _nickname = result.trim();
      });
    }
  }

  void _pickAvatar() async {
    // 这里只做UI，实际可集成 image_picker
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('头像选择功能待实现')));
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
    } else {
      // 如果无法获取应用状态，重启应用也是一种选择
      // 实际项目中可以添加一个重启提示
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('主题设置已保存，重启应用后生效')));
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

  Future<void> _toggleNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableNotification', value);
    setState(() {
      _enableNotification = value;
    });
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
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('语言设置已保存，重启应用后生效')));
      }
    }
  }

  Future<void> _backupData() async {
    // TODO: 实现数据备份功能
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('数据备份功能开发中...')));
  }

  Future<void> _restoreData() async {
    // TODO: 实现数据恢复功能
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('数据恢复功能开发中...')));
  }

  @override
  Widget build(BuildContext context) {
    // 每次构建时同步当前系统主题状态
    final currentTheme = Theme.of(context).brightness == Brightness.dark;
    if (_isDarkMode != currentTheme) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isDarkMode = currentTheme;
        });
      });
    }

    final String themeModeText = _isDarkMode ? '已开启' : '已关闭';

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        children: [
          const SizedBox(height: 32),
          // 头像和昵称部分
          GestureDetector(
            onTap: _pickAvatar,
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.brown[100],
              backgroundImage:
                  _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
              child:
                  _avatarUrl == null
                      ? const Icon(Icons.person, size: 64, color: Colors.brown)
                      : null,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_nickname, style: const TextStyle(fontSize: 20)),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: _editNickname,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 设置项
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '基本设置',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('设置中心'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('通知提醒'),
            subtitle: Text(_enableNotification ? '已开启' : '已关闭'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('数据备份与恢复'),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder:
                    (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.backup),
                          title: const Text('备份数据'),
                          onTap: () {
                            Navigator.pop(context);
                            _backupData();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.restore),
                          title: const Text('恢复数据'),
                          onTap: () {
                            Navigator.pop(context);
                            _restoreData();
                          },
                        ),
                      ],
                    ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('关于 Daily Coffee'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Daily Coffee',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(
                  Icons.coffee,
                  size: 48,
                  color: Colors.brown,
                ),
                children: [
                  const Text('记录你的每一杯咖啡'),
                  const SizedBox(height: 8),
                  const Text('© 2024 Daily Coffee. All rights reserved.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
