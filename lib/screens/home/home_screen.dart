import 'dart:io';
import 'package:bts_wallpaperz/screens/home/tabs/downloads_tab.dart';
import 'package:bts_wallpaperz/screens/home/tabs/home_tab.dart';
import 'package:bts_wallpaperz/screens/home/tabs/settings_tab.dart';
import 'package:bts_wallpaperz/services/wallpaper_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _currentIndex = 0;
  late PageController _pageController;
  List<File> images = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
    _pageController = PageController();
  }

  Future<void> init() async {
    images = await WallpaperService.loadImages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void bottomTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  Future<bool> onWillPop() {
    if(_currentIndex != 0) {
      bottomTapped(0);
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Bangtan Wallpaperz", style: TextStyle(fontWeight: FontWeight.w500)),
          scrolledUnderElevation: 3,
          notificationPredicate: (ScrollNotification notification) {
            return notification.depth == 1;
          },
          shadowColor: Theme.of(context).colorScheme.shadow,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          actions:_currentIndex == 1 ? images.isNotEmpty ? [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                showDialog(context: context, builder: (context) => AlertDialog(
                  title: const Text("Delete All Wallpapers"),
                  content: const Text("Do you want to delete all wallpapers?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
                    TextButton(
                      child: const Text("Yes"),
                      onPressed: () {
                        WallpaperService.removeAllImages(context).then((value) {
                          Navigator.pop(context);
                          bottomTapped(0);
                        });
                      },
                    ),
                  ],
                ));
              },
            )
          ] : null : null,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => bottomTapped(index),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: "Home"),
            NavigationDestination(icon: Icon(Icons.download), label: "Downloads"),
            NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
          ],
        ),
        body: SizedBox.expand(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentIndex = index),
            children: const [
              HomeTab(),
              DownloadsTab(),
              SettingsTab(),
            ],
          ),
        ),
      ),
    );
  }
}
