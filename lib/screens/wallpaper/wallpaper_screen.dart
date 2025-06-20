import 'dart:io';
import 'package:bts_wallpaperz/screens/home/home_screen.dart';
import 'package:bts_wallpaperz/services/wallpaper_service.dart';
import 'package:bts_wallpaperz/utils/ui_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';

class WallpaperScreen extends StatefulWidget {
  final String fullResWallpaperUrl;
  final bool isDownloaded;
  const WallpaperScreen({super.key, required this.fullResWallpaperUrl, required this.isDownloaded});

  @override
  State<WallpaperScreen> createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends State<WallpaperScreen> {

  final key = GlobalKey<CircularMenuState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      body: CircularMenu(
        key: key,
        items: [
          CircularMenuItem(
            icon: Icons.arrow_back,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          CircularMenuItem(
            icon: Icons.add_to_home_screen,
            onTap: () {
              key.currentState?.reverseAnimation();
              bool isClicked = false;
              showDialog(barrierDismissible: !isClicked, context: context, builder: (context) => PopScope(
                canPop: !isClicked,
                child: StatefulBuilder(
                  builder: (context, innerSetState) {
                    void clicked() {
                      innerSetState(() => isClicked = true);
                    }
                    return AlertDialog(
                      title: Text(isClicked ? "Setting Wallpaper\nPlease wait...": "Set Wallpaper"),
                      contentPadding: const EdgeInsets.only(top: 16, bottom: 24),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: ListTile.divideTiles(
                            context: context,
                            tiles: [
                              if(isClicked)...[
                                const ListTile(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 24),
                                  title: Center(child: CircularProgressIndicator()),
                                ),
                              ] else... [
                                ListTile(
                                  title: const Text("Home screen"),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                                  onTap: () async {
                                    clicked();
                                    WallpaperService.setWallpaper(context: context, isDownloaded: widget.isDownloaded, imageUrl: widget.fullResWallpaperUrl, wallpaperType: WallpaperManagerPlus.homeScreen);
                                  },
                                ),
                                ListTile(
                                  title: const Text("Lock screen"),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                                  onTap: () async {
                                    clicked();
                                    WallpaperService.setWallpaper(context: context, isDownloaded: widget.isDownloaded, imageUrl: widget.fullResWallpaperUrl, wallpaperType: WallpaperManagerPlus.lockScreen);
                                  },
                                ),
                                ListTile(
                                  title: const Text("Both screens"),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                                  onTap: () async {
                                    clicked();
                                    WallpaperService.setWallpaper(context: context, isDownloaded: widget.isDownloaded, imageUrl: widget.fullResWallpaperUrl, wallpaperType: WallpaperManagerPlus.bothScreens);
                                  },
                                ),
                              ],
                            ]).toList(),
                      ),
                    );
                  }
                ),
              )).whenComplete(() => setState(() {}));
            },
          ),
          if(widget.isDownloaded)...[
            CircularMenuItem(
              icon: Icons.delete,
              onTap: () {
                key.currentState?.reverseAnimation();
                showDialog(context: context, builder: (context) => AlertDialog(
                  title: const Text("Delete Wallpaper"),
                  content: const Text("Do you want to delete this wallpaper?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
                    TextButton(
                      child: const Text("Yes"),
                      onPressed: () {
                        try{
                          File(widget.fullResWallpaperUrl).deleteSync();
                          UIComponents.showSnackBar(context, "Wallpaper deleted!");
                        } catch(e) {
                          UIComponents.showSnackBar(context, "Error occurred");
                        } finally {
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
                        }
                      },
                    ),
                  ],
                ));
              },
            ),
          ] else...[
            CircularMenuItem(
              icon: Icons.download,
              onTap: () {
                key.currentState?.reverseAnimation();
                showDialog(context: context, builder: (context) => AlertDialog(
                  title: const Text("Add to Downloads"),
                  content: const Text("Do you want to add this wallpaper to your downloads?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
                    TextButton(
                      child: const Text("Yes"),
                      onPressed: () async {
                        WallpaperService.saveWallpaper(context: context, isDownloaded: widget.isDownloaded, imageUrl: widget.fullResWallpaperUrl);
                      },
                    ),
                  ],
                ));
              },
            ),
          ],

        ],
        backgroundWidget: SizedBox.expand(
          child: widget.isDownloaded
              ? Image.file(File(widget.fullResWallpaperUrl), fit: BoxFit.cover)
              : CachedNetworkImage(
            imageUrl: widget.fullResWallpaperUrl,
            fit: BoxFit.cover,
            progressIndicatorBuilder: (_, __, ___) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          value: ___.progress,
                        ),
                        const SizedBox(height: 20),
                        const Text("Downloading full HD"),
                        const SizedBox(height: 10),
                        if(___.totalSize != null) Text("${(___.downloaded / (1024 * 1024)).toStringAsFixed(2)} MB / ${(___.totalSize! / (1024 * 1024)).toStringAsFixed(2)} MB"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            errorWidget: (_, __, ___) => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error),
                  SizedBox(height: 5),
                  Text("No internet"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
