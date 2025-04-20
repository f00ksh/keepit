// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:keepit/core/theme/app_theme.dart';

// class ImageCacheManager {
//   static final ImageCacheManager _instance = ImageCacheManager._internal();
//   factory ImageCacheManager() => _instance;
//   ImageCacheManager._internal();

//   final Set<String> _cachedImagePaths = {};
//   bool _hasPreloaded = false;

//   // Configure the cache size - increase these values based on your app's needs
//   void configureCache() {
//     // Set the maximum size for the image cache to store more images
//     PaintingBinding.instance.imageCache.maximumSize = 200;
//     // Set maximum bytes (100 MB is a reasonable size for wallpaper images)
//     PaintingBinding.instance.imageCache.maximumSizeBytes = 100 * 1024 * 1024;
//   }

//   // Preload all wallpaper images for both themes
//   Future<void> preloadAllWallpapers(BuildContext context) async {
//     if (_hasPreloaded) return;

//     configureCache();

//     final lightAssets = AppTheme.lightWallpaperAssets;
//     final darkAssets = AppTheme.darkWallpaperAssets;

//     final assetsToCacheLight =
//         lightAssets.where((asset) => asset != null).cast<String>().toList();
//     final assetsToCacheDark =
//         darkAssets.where((asset) => asset != null).cast<String>().toList();

//     // Combine all assets to preload
//     final allAssets = [...assetsToCacheLight, ...assetsToCacheDark];

//     for (final asset in allAssets) {
//       await _cacheImage(asset, context);
//     }

//     _hasPreloaded = true;
//   }

//   // Helper method to cache a single image
//   Future<void> _cacheImage(String imagePath, BuildContext context) async {
//     if (_cachedImagePaths.contains(imagePath)) return;

//     try {
//       // Create the image provider
//       final provider = AssetImage(imagePath);
//       // Load the image into memory
//       await precacheImage(provider, context);
//       // Mark as cached
//       _cachedImagePaths.add(imagePath);
//       // Force the image to be cached and retained
//       _retainImage(provider);
//     } catch (e) {
//       debugPrint('Failed to cache image $imagePath: $e');
//     }
//   }

//   // Force the image to be retained in memory
//   void _retainImage(ImageProvider provider) {
//     final imageStream = provider.resolve(const ImageConfiguration());
//     final imageStreamCompleter = imageStream.completer;
//     if (imageStreamCompleter != null) {
//       imageStreamCompleter.addListener(
//         ImageStreamListener((_, __) {}, onError: (_, __) {}),
//       );
//     }
//   }

//   // Get a cached image - ensures the image is already in memory
//   ImageProvider getImage(String? imagePath) {
//     if (imagePath == null) {
//       // Return a transparent image if path is null
//       return MemoryImage(Uint8List.fromList([0, 0, 0, 0]));
//     }

//     // Return the cached asset image
//     return AssetImage(imagePath);
//   }

//   // Cache a specific image when needed (for newly selected wallpapers)
//   Future<void> cacheImage(String? imagePath, BuildContext context) async {
//     if (imagePath == null) return;
//     await _cacheImage(imagePath, context);
//   }

//   // Clear specific images from cache if needed
//   void clearImage(String imagePath) {
//     PaintingBinding.instance.imageCache.evict(AssetImage(imagePath));
//     _cachedImagePaths.remove(imagePath);
//   }
// }
