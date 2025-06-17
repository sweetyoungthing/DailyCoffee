import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'notification_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _caffeineLimit = 400;
  int _budgetLimit = 1000;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _caffeineLimit = prefs.getInt('caffeineLimit') ?? 400;
      _budgetLimit = prefs.getInt('budgetLimit') ?? 1000;
    });
  }

  Future<void> _setCaffeineLimit() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _caffeineLimit.toString());
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.caffeineDailyLimit),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: l10n.enterCaffeineLimit,
                suffixText: l10n.unitMg,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: Text(l10n.save),
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
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _budgetLimit.toString());
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.monthlyBudget),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: l10n.enterBudgetAmount,
                suffixText: l10n.unitCurrency,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: Text(l10n.save),
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
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = Provider.of<AppSettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          // 显示设置
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.display,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ListTile(
                  title: Text(l10n.darkMode),
                  trailing: Switch(
                    value: settingsProvider.isDarkMode,
                    onChanged: (bool value) {
                      settingsProvider.toggleDarkMode();
                    },
                  ),
                  subtitle: Text(
                    settingsProvider.isDarkMode
                        ? l10n.darkModeEnabled
                        : l10n.darkModeDisabled,
                  ),
                ),
                ListTile(
                  title: Text(l10n.language),
                  trailing: DropdownButton<String>(
                    value:
                        settingsProvider.locale.languageCode == 'en'
                            ? 'en'
                            : 'zh',
                    items: [
                      DropdownMenuItem(
                        value: 'zh',
                        child: Text(l10n.simplified_chinese),
                      ),
                      DropdownMenuItem(value: 'en', child: Text(l10n.english)),
                    ],
                    onChanged: (String? value) {
                      if (value != null) {
                        settingsProvider.setLocale(Locale(value));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // 个性化设置
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.personalization,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ListTile(
                  title: Text(l10n.caffeineDailyLimit),
                  subtitle: Text('$_caffeineLimit ${l10n.unitMg}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _setCaffeineLimit,
                ),
                ListTile(
                  title: Text(l10n.monthlyBudget),
                  subtitle: Text('${l10n.unitCurrency}$_budgetLimit'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _setBudgetLimit,
                ),
              ],
            ),
          ),

          // 数据管理
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.dataManagement,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ListTile(
                  title: Text(l10n.backupData),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.backupInProgress)),
                    );
                  },
                ),
                ListTile(
                  title: Text(l10n.restoreData),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.restoreInProgress)),
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
