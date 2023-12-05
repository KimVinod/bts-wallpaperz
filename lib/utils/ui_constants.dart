import 'package:flutter/material.dart';

class UIComponents {
  static void showSnackBar(BuildContext context, String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)), behavior: SnackBarBehavior.floating, backgroundColor: Theme.of(context).colorScheme.primaryContainer));
  static void showErrorToast(BuildContext context) => showSnackBar(context, "Error occurred. Your phone doesn't support opening links");
}

const String shareText = "Hey! Check this out. This app has full HD wallpapers of BTS.\n\nApp name: Bangtan Wallpaperz\n\nGoogle Play Store:\n$playStoreUrl";
const String versionNotesUrl = "https://sites.google.com/view/bts-wallpaperz-ver";
const String twitterUrl = "https://twitter.com/intent/user?user_id=3249582416";
const String bangtanLyriczPlayStoreUrl = "https://play.google.com/store/apps/details?id=com.kimvinod.bts_lyricz";
const String playStoreUrl = "https://play.google.com/store/apps/details?id=com.kimvinod.bts_wallpaperz";
const String githubUrl = "https://github.com/KimVinod/bts-wallpaperz";
const String email = "vinoddevendran34@gmail.com";

const List<Map<String, String>> category = [
  {
    "name":"BTS",
    "image":"images/category/btsHeader.jpg",
    "key":"bts",
  },
  {
    "name":"RM",
    "image":"images/category/namjoonHeader.jpg",
    "key":"namjoon",
  },
  {
    "name":"Jin",
    "image":"images/category/seokjinHeader.jpg",
    "key":"seokjin",
  },
  {
    "name":"SUGA / Agust D",
    "image":"images/category/yoongiHeader.jpg",
    "key":"yoongi",
  },
  {
    "name":"j-hope",
    "image":"images/category/hoseokHeader.jpg",
    "key":"hoseok",
  },
  {
    "name":"Jimin",
    "image":"images/category/jiminHeader.jpg",
    "key":"jimin",
  },
  {
    "name":"V",
    "image":"images/category/taehyungHeader.jpg",
    "key":"taehyung",
  },
  {
    "name":"Jungkook",
    "image":"images/category/jungkookHeader.jpg",
    "key":"jungkook",
  },
];