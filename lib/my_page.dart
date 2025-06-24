import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'notification_page.dart';
import 'settings_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = Provider.of<AppSettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.mine)),
      body: ListView(
        children: [
          // 用户信息卡片
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<String>(
                    future: SharedPreferences.getInstance().then(
                      (prefs) => prefs.getString('nickname') ?? '',
                    ),
                    builder: (context, snapshot) {
                      final nickname = snapshot.data ?? '';
                      return Text(
                        nickname.isEmpty ? l10n.nicknameNotSet : nickname,
                        style: Theme.of(context).textTheme.titleLarge,
                      );
                    },
                  ),
                  TextButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final currentNickname = prefs.getString('nickname') ?? '';

                      final controller = TextEditingController(
                        text: currentNickname,
                      );
                      final result = await showDialog<String>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text(l10n.nickname),
                              content: TextField(
                                controller: controller,
                                decoration: InputDecoration(
                                  hintText: l10n.enterNickname,
                                ),
                                autofocus: true,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(l10n.cancel),
                                ),
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(
                                        context,
                                        controller.text,
                                      ),
                                  child: Text(l10n.save),
                                ),
                              ],
                            ),
                      );

                      if (result != null) {
                        await prefs.setString('nickname', result.trim());
                        // 强制重建页面以更新昵称显示
                        if (context.mounted) {
                          setState(() {});
                        }
                      }
                    },
                    child: Text(l10n.edit),
                  ),
                ],
              ),
            ),
          ),

          // 设置列表
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(l10n.settings),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(l10n.notifications),
                  trailing: const Icon(Icons.chevron_right),
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
                  leading: const Icon(Icons.info),
                  title: Text(l10n.about),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: l10n.appName,
                      applicationVersion: '1.0.0',
                      children: [
                        Text(l10n.slogan),
                        const SizedBox(height: 16),
                        Text(l10n.copyright),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
