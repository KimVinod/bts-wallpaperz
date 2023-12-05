import 'dart:io';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:path/path.dart';
import 'package:bts_wallpaperz/utils/ui_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

class WallpaperService {
  static Future<List<File>> loadImages() async {
    try {
      final Directory documentsDir = await getApplicationDocumentsDirectory();
      List<FileSystemEntity> files = documentsDir.listSync();

      List<File> images = files
          .where((file) => file is File && (file.path.endsWith('.jpg') || file.path.endsWith('.png') || file.path.endsWith('.jpeg')))
          .map((file) => File(file.path))
          .toList();

      return images;

    } catch (e, s) {
      debugPrint('$e');
      debugPrint('$s');
      return [];
    }
  }

  static bool _areImagesIdentical(File imageFile1, File imageFile2) {
    var bytes1 = imageFile1.readAsBytesSync();
    var bytes2 = imageFile2.readAsBytesSync();

    return bytes1.length == bytes2.length &&
        Iterable<int>.generate(bytes1.length)
            .every((i) => bytes1[i] == bytes2[i]);
  }

  static Future<double> getImagesSize() async {
    List<File> images = await loadImages();
    double imagesSize = 0;
    for (var image in images) {
      imagesSize += image.lengthSync();
    }
    return imagesSize / (1024*1024);
  }

  static Future<void> removeAllImages(BuildContext context) async {
    List<File> images = await loadImages();
    try {
      for(final image in images) {
        image.deleteSync();
      }
    } catch (e) {
      if(context.mounted) UIComponents.showSnackBar(context, "Error occurred");
    }
  }

  static Future<QuerySnapshot> fetchTrendingWallpapers() {
    return FirebaseFirestore.instance.collectionGroup("wallpapers").where('full', isNotEqualTo: "").limit(4).get();
  }

  static Future<double> getCacheSize() async {
    final Directory cacheDir = await getTemporaryDirectory();
    double cacheSize = await _getDirectorySize(cacheDir);
    return cacheSize / (1024 * 1024);

  }

  static Future<double> _getDirectorySize(Directory dir) async {
    double size = 0;
    await for (FileSystemEntity entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        size += await entity.length();
      }
    }
    return size;
  }

  static Future<QuerySnapshot> fetchWallpapersByCategory(String category) {
    return FirebaseFirestore.instance
        .collection("wallpapers")
        .doc(category)
        .collection("wallpapers")
        .where('full', isNotEqualTo: "")
        .get();
  }

  static Future<File?> _findFile({required bool isDownloaded,required String imageUrl}) async {
    if(isDownloaded) {
      return File(imageUrl);
    } else {
      final cache = DefaultCacheManager();
      final file = await cache.getFileFromCache(imageUrl);
      return file?.file;
    }
  }

  static Future<File> _checkIdenticalBeforeSaving(File file) async {
    final images = await loadImages();
    for(final image in images) {
      if(_areImagesIdentical(file, image)) {
        debugPrint('matched');
        image.deleteSync();
        return file;
      }
    }
    return file;
  }

  static Future<void> saveWallpaper({required BuildContext context, required bool isDownloaded,required String imageUrl}) async {
    File? file = await _findFile(isDownloaded: isDownloaded, imageUrl: imageUrl);
    if(file != null) {
      try{
        file = await _checkIdenticalBeforeSaving(file);
        debugPrint(file.path);
        final Directory dir = await getApplicationDocumentsDirectory();
        File newFile = await file.copy("${dir.path}/${basename(file.path)}");
        debugPrint("hehe ${newFile.path}");
        if(context.mounted) {
          UIComponents.showSnackBar(context, "Wallpaper added!");
          Navigator.pop(context);
        }
      } catch (e) {
        debugPrint('$e');
      }
    } else {
      if(context.mounted) UIComponents.showSnackBar(context, "No internet");
    }
  }

  static Future<void> setWallpaper({required BuildContext context, required bool isDownloaded,required String imageUrl, required int wallpaperType}) async {
    File? file = await _findFile(isDownloaded: isDownloaded, imageUrl: imageUrl);
    if(file != null) {
      bool result = await WallpaperManager.setWallpaperFromFile(file.path, wallpaperType);
      if(result) {
        if(context.mounted) {
          Navigator.pop(context);
          UIComponents.showSnackBar(context, "Wallpaper has been set!");
        }
      }
    } else {
      if(context.mounted) UIComponents.showSnackBar(context, "Error occurred");
    }
  }
}