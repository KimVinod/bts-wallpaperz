import 'dart:io';
import 'package:bts_wallpaperz/screens/wallpaper/wallpaper_screen.dart';
import 'package:bts_wallpaperz/services/wallpaper_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class DownloadsTab extends StatefulWidget {
  const DownloadsTab({super.key});

  @override
  State<DownloadsTab> createState() => _DownloadsTabState();
}

class _DownloadsTabState extends State<DownloadsTab> {
  List<File> images = [];

  init() async {
      images = await WallpaperService.loadImages();
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
    return SizedBox.expand(
      child: images.isNotEmpty
          ? AnimationLimiter(
            child: MasonryGridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                    itemCount: images.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) => AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      columnCount: 2,
                      child: SlideAnimation(
                        verticalOffset: 50,
                        child: FadeInAnimation(
                          child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => WallpaperScreen(fullResWallpaperUrl: images[index].path, isDownloaded: true)));
                                      },
                                      child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          elevation: 0,
                                          margin: const EdgeInsets.all(6),
                                          color: Theme.of(context).colorScheme.surfaceVariant,
                                          child: Image.file(images[index], fit: BoxFit.fill)
                                      ),
                          ),
                        ),
                      ),
                    ),
                  ),
          )
          : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("You'll find your downloads here"),
              ],
            ),
    );
  }
}
