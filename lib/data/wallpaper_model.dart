class Wallpaper {
  final String full, thumb;

  Wallpaper({
    required this.full,
    required this.thumb,
  });

  factory Wallpaper.fromFirestore(Map<dynamic, dynamic> json) {
    return Wallpaper(
      full: json['full'],
      thumb: json['thumb'],
    );
  }

  Map<String, dynamic> toJson() => {
    "full": full,
    "thumb": thumb,
  };
}