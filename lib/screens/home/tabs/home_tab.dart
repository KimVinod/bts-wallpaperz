import 'dart:ui';
import 'package:bts_wallpaperz/data/wallpaper_model.dart';
import 'package:bts_wallpaperz/screens/category/category_screen.dart';
import 'package:bts_wallpaperz/screens/wallpaper/wallpaper_screen.dart';
import 'package:bts_wallpaperz/services/wallpaper_service.dart';
import 'package:bts_wallpaperz/utils/ui_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  //Stream<QuerySnapshot> fetchAllWapapers() => FirebaseFirestore.instance.collectionGroup('wallpapers').snapshots();
  late Future<QuerySnapshot> fetchTrendingWallpapers;

  init() {
    fetchTrendingWallpapers = WallpaperService.fetchTrendingWallpapers();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SearchBar(
              shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              hintText: "Search wallpapers...",
              trailing: const [Icon(Icons.search)],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Trending right now", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Theme.of(context).colorScheme.outline)
                  ),
                  child: const Text("Show all"),),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 284.44,
            child: FutureBuilder<QuerySnapshot>(
              future: fetchTrendingWallpapers,
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text(snapshot.error.toString()));

                if (!snapshot.hasData) {
                  return AnimationLimiter(
                    child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          horizontalOffset: 50,
                          child: FadeInAnimation(
                            child: Card(
                              elevation: 0,
                              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              child: const SizedBox(width: 160),
                            ),
                          ),
                        ),
                      );
                      },
                    ),
                  );
                }

                /*final docs = snapshot.data?.docs;

                for(var data in docs!) {
                  print(data.data());
                }

                final wallpapers = snapshot.data!.docs.map((document) {
                  return Wallpaper.fromFirestore(document.data() as Map<String, dynamic>);
                }).toList();*/

                /*final wallpapers = snapshot.data!.docs.map((document) {
                  final data = document.data() as Map<String, dynamic>;
                  if (data.containsKey('full') && data['full'] is String && data['full'].isNotEmpty) {
                    return Wallpaper.fromFirestore(data);
                  } else {
                    return null;
                  }
                }).where((wallpaper) => wallpaper != null).toList();*/

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
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: wallpapers.length,
                    itemBuilder: (context, index) {
                      final wallpaper = wallpapers[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          horizontalOffset: 50,
                          child: FadeInAnimation(
                            child: GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WallpaperScreen(fullResWallpaperUrl: wallpaper.full, isDownloaded: false))),
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                elevation: 0,
                                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                color: Theme.of(context).colorScheme.surfaceVariant,
                                child: SizedBox(
                                  width: 160,
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
                        ),
                      );
                    },
                  ),
                );
              }
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("Categories", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
          ),
          const SizedBox(height: 8),
          AnimationLimiter(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              primary: false,
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1 / 0.55),
              itemCount: category.length,
              itemBuilder: (context, index) {
                final name = category[index]["name"]!;
                final image = category[index]["image"]!;
                final key = category[index]["key"]!;
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 500),
                  columnCount: 2,
                  child: SlideAnimation(
                    verticalOffset: 50,
                    child: FadeInAnimation(
                      child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryScreen(categoryName: name, keyName: key))),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: 0,
                        margin: const EdgeInsets.all(6),
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              child: ImageFiltered(
                                imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                                child: ColorFiltered(
                                  colorFilter: const ColorFilter.mode(Colors.black26, BlendMode.srcOver),
                                  child: Image.asset(image, fit: BoxFit.cover)),
                              ),
                            ),
                            Center(child: Text(name, style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),))
                          ],
                        ),
                      ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;
}