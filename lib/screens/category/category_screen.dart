import 'package:bts_wallpaperz/data/wallpaper_model.dart';
import 'package:bts_wallpaperz/screens/wallpaper/wallpaper_screen.dart';
import 'package:bts_wallpaperz/services/wallpaper_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryName, keyName;
  const CategoryScreen({super.key, required this.categoryName, required this.keyName});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {

  late Future<QuerySnapshot> fetchWallpapersByCategory;

  init() {
    fetchWallpapersByCategory = WallpaperService.fetchWallpapersByCategory(widget.keyName);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.categoryName} Wallpapers", style: const TextStyle(fontWeight: FontWeight.w500)),
        titleSpacing: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: fetchWallpapersByCategory,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) return Center(child: Text(snapshot.error.toString()));

            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final wallpapers = snapshot.data!.docs.map((document) {
              return Wallpaper.fromFirestore(document.data() as Map<String, dynamic>);
            }).toList();

            if(wallpapers.isEmpty) {
              return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error),
                  SizedBox(height: 5),
                  Text("No internet"),
                ],
              ),
            );
            }

            return AnimationLimiter(
              child: MasonryGridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                itemCount: wallpapers.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final Wallpaper wallpaper = wallpapers[index];
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    columnCount: 2,
                    child: SlideAnimation(
                      verticalOffset: 50,
                      child: FadeInAnimation(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => WallpaperScreen(fullResWallpaperUrl: wallpaper.full, isDownloaded: false)));
                            },
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            elevation: 0,
                            margin: const EdgeInsets.all(6),
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: CachedNetworkImage(
                              imageUrl: wallpaper.thumb,
                              fit: BoxFit.fill,
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
                      ),
                    ),
                  );
                },
              ),
            );
          }
        ),
      ),
    );
  }
}
