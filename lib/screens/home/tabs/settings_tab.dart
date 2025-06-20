import 'dart:io';
import 'package:bts_wallpaperz/services/settings_service.dart';
import 'package:bts_wallpaperz/services/wallpaper_service.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  double imagesSize = 0, cacheSize = 0;
  List<File> images = [];

  void init() async {
    images = await WallpaperService.loadImages();
    imagesSize = await WallpaperService.getImagesSize();
    cacheSize = await WallpaperService.getCacheSize();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox.expand(
      child: SettingsList(
        lightTheme: SettingsThemeData(settingsListBackground: theme.scaffoldBackgroundColor),
        darkTheme: SettingsThemeData(settingsListBackground: theme.scaffoldBackgroundColor),
        sections: [
          SettingsSection(
            title: Text('Notifications', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
            tiles: <SettingsTile>[
              SettingsTile(
                onPressed: (context) => SettingsService.openNotifications(),
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Turn ON/OFF BTS related notifications'),
                value: const Text('Btw I rarely send these ~.~'),
              ),
            ],
          ),
          SettingsSection(
            title: Text('Appearance', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
            tiles: <SettingsTile>[
              SettingsTile(
                onPressed: (context) => SettingsService.openThemeDialog(context),
                leading: const Icon(Icons.color_lens_outlined),
                title: const Text('Set app theme'),
                value: const Text('Change the look and feel of the app'),
              ),
            ],
          ),
          SettingsSection(
            title: Text('Updates', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
            tiles: <SettingsTile>[
              SettingsTile(
                onPressed: (context) {},
                enabled: false,
                leading: const Icon(Icons.system_update),
                title: const Text('Check for updates'),
                value: const Text('Get new features and improvements'),
              ),
              SettingsTile(
                onPressed: (context) => SettingsService.openVersionNotes(context),
                leading: const Icon(Icons.notes),
                title: const Text('Version notes'),
                value: const Text('Check out upcoming features and previous version notes'),
              ),
            ],
          ),
          SettingsSection(
            title: Text('Storage', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
            tiles: <SettingsTile>[
              SettingsTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('Downloads usage'),
                value: imagesSize == 0 ? const Text("Your downloads is empty") : Text('${imagesSize.toStringAsFixed(2)} MB'),
              ),
              SettingsTile(
                onPressed: (context) => showDialog(context: context, builder: (context) => AlertDialog(
                  title: const Text("Clear App Cache"),
                  content: const Text("Do you want to clear the app cache? Your downloads will remain safe"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
                    TextButton(
                      child: const Text("Yes"),
                      onPressed: () => SettingsService.clearCache(context),
                    ),
                  ],
                )),
                enabled: imagesSize >= 100 ? true : false,
                leading: const Icon(Icons.cached),
                title: const Text('Clear cache'),
                value: Text('${cacheSize.toStringAsFixed(2)} MB. This does not include your downloads. You can clear cache once it exceeds 100 MB.'),
              ),
            ],
          ),
          SettingsSection(
            title: Text('Help', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
            tiles: <SettingsTile>[
              SettingsTile(
                onPressed: (context) {},
                leading: const Icon(Icons.question_mark),
                title: const Text('FAQ'),
                value: const Text('Got stuck somewhere? This might help you'),
              ),
              SettingsTile(
                onPressed: (context) => SettingsService.showFoundBugDialog(mainContext: context),
                leading: const Icon(Icons.bug_report_outlined),
                title: const Text('Found a bug? Suggestions?'),
                value: const Text('Feel free to give your inputs as it helps a lot!'),
              ),
            ],
          ),
          SettingsSection(
            title: Text('Miscellaneous', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
            tiles: <SettingsTile>[
              SettingsTile(
                onPressed: (context) => SettingsService.openBangtanLyricz(context),
                leading: const Icon(Icons.download_outlined),
                title: const Text('Bangtan Lyricz'),
                value: const Text("Get the song lyrics of BTS all in one place!"),
              ),
              SettingsTile(
                onPressed: (context) {},
                enabled: false,
                leading: const Icon(Icons.star_rate_outlined),
                title: const Text('Rate on Google Play'),
                value: const Text("Thankuuu in advance :')"),
              ),
              SettingsTile(
                onPressed: (context) {},
                enabled: false,
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                value: const Text('Share to other armys as well  >.<'),
              ),
              SettingsTile(
                onPressed: (context) {},
                enabled: false,
                leading: const Icon(Icons.code),
                title: const Text('Source code'),
                value: const Text('Get to see all the coding work here'),
              ),
              SettingsTile(
                onPressed: (context) {},
                leading: const Icon(Icons.apps),
                title: const Text('App info'),
                value: const Text('Some extra stuff'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
