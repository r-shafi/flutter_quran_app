import 'package:flutter/material.dart';

/// Cached image widget that loads images efficiently
/// 
/// Features:
/// - Automatic caching
/// - Fade-in animation on load
/// - Memory-efficient loading
/// - Error placeholder
class CachedImage extends StatelessWidget {
  const CachedImage({
    super.key,
    required this.assetPath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholderColor,
  });

  final String assetPath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Color? placeholderColor;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: fit,
      width: width,
      height: height,
      cacheWidth: (width ?? 200).toInt(),
      cacheHeight: (height ?? 200).toInt(),
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: placeholderColor ?? Colors.grey[300],
          child: Icon(Icons.error, color: Colors.grey[600]),
        );
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
    );
  }
}

/// Lazy loading image list for prayer times
class PrayerTimeImageList extends StatelessWidget {
  const PrayerTimeImageList({super.key});

  @override
  Widget build(BuildContext context) {
    final images = [
      {'name': 'Fajr', 'path': 'assets/images/Fajr.jpg'},
      {'name': 'Sunrise', 'path': 'assets/images/Sunrise.jpg'},
      {'name': 'Dhuhr', 'path': 'assets/images/Dhuhr.jpg'},
      {'name': 'Asr', 'path': 'assets/images/Asr.jpg'},
      {'name': 'Maghrib', 'path': 'assets/images/Maghrib.jpg'},
      {'name': 'Isha', 'path': 'assets/images/Isha.jpg'},
    ];

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return SizedBox(
          width: 200,
          child: CachedImage(
            assetPath: image['path']!,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
