import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Caches the full menu (categories + items as JSON) and pre-downloads
/// image files to the local filesystem so they are available offline.
///
/// Place in lib/core/services/menu_cache_service.dart
class MenuCacheService {
  static const _menuKey = 'cached_menu_items';
  static const _catsKey = 'cached_menu_categories';

  // ── menu data ─────────────────────────────────────────────────────────────

  Future<void> saveMenuItems(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_menuKey, jsonEncode(items));
  }

  Future<List<Map<String, dynamic>>?> loadMenuItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_menuKey);
    if (raw == null) return null;
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  Future<void> saveCategories(List<Map<String, dynamic>> cats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_catsKey, jsonEncode(cats));
  }

  Future<List<Map<String, dynamic>>?> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_catsKey);
    if (raw == null) return null;
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  // ── image caching ─────────────────────────────────────────────────────────

  /// Returns the local filesystem path where a remote image is (or will be) cached.
  /// Uses a stable filename derived from the URL so it survives restarts.
  Future<String> localImagePath(String remoteUrl) async {
    final dir = await _imageCacheDir();
    final filename = _urlToFilename(remoteUrl);
    return '${dir.path}/$filename';
  }

  /// Downloads [remoteUrl] to disk if not already cached.
  /// Returns the local path on success, null on failure.
  Future<String?> ensureImageCached(String remoteUrl) async {
    try {
      final path = await localImagePath(remoteUrl);
      final file = File(path);
      if (await file.exists()) return path; // already cached

      final response = await http
          .get(Uri.parse(remoteUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return path;
      }
    } catch (_) {
      // Network failure — return null, caller shows placeholder
    }
    return null;
  }

  /// Returns the cached local path if the image was previously downloaded,
  /// or null if not cached (without trying to download).
  Future<String?> cachedImagePathIfExists(String remoteUrl) async {
    try {
      final path = await localImagePath(remoteUrl);
      if (await File(path).exists()) return path;
    } catch (_) {}
    return null;
  }

  /// Pre-cache all images for a list of remote URLs. Fire-and-forget.
  Future<void> preCacheImages(List<String> urls) async {
    await Future.wait(
      urls.map(ensureImageCached),
      eagerError: false,
    );
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  Future<Directory> _imageCacheDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/menu_image_cache');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  String _urlToFilename(String url) {
    // Stable, filesystem-safe filename from URL
    final bytes = utf8.encode(url);
    final hash = bytes.fold<int>(0, (h, b) => (h * 31 + b) & 0xFFFFFFFF);
    final ext = url.split('?').first.split('.').last.toLowerCase();
    final safeExt = ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext) ? ext : 'jpg';
    return '${hash.toRadixString(16)}.$safeExt';
  }
}