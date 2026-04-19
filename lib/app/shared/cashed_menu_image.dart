import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_v1/core/services/menu_cache_service.dart';

/// Drop-in image widget for menu items.
/// • Online & cached: shows local file (fast, no re-download)
/// • Online & not cached: shows network image, caches in background
/// • Offline & cached: shows local file
/// • Offline & not cached: shows placeholder icon
///
/// Usage:
///   CachedMenuImage(url: item.imageUrl, size: 80)
class CachedMenuImage extends ConsumerStatefulWidget {
  const CachedMenuImage({
    super.key,
    required this.url,
    this.size = 64,
    this.borderRadius = 12.0,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  final String? url;
  final double size;
  final double borderRadius;
  final BoxFit fit;
  final Widget? placeholder;

  @override
  ConsumerState<CachedMenuImage> createState() => _CachedMenuImageState();
}

class _CachedMenuImageState extends ConsumerState<CachedMenuImage> {
  String? _localPath;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(CachedMenuImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) {
      _checked = false;
      _localPath = null;
      _resolve();
    }
  }

  Future<void> _resolve() async {
    final url = widget.url;
    if (url == null || url.isEmpty) {
      setState(() => _checked = true);
      return;
    }
    final cache = MenuCacheService();
    // First check if already on disk (instant, works offline)
    final existing = await cache.cachedImagePathIfExists(url);
    if (existing != null) {
      if (mounted) setState(() { _localPath = existing; _checked = true; });
      return;
    }
    // Not on disk — try to download and cache
    final downloaded = await cache.ensureImageCached(url);
    if (mounted) setState(() { _localPath = downloaded; _checked = true; });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final defaultPlaceholder = widget.placeholder ??
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: Icon(
            Icons.fastfood_rounded,
            size: widget.size * 0.45,
            color: scheme.onSurfaceVariant.withOpacity(0.3),
          ),
        );

    if (!_checked) return defaultPlaceholder;

    // We have a local file
    if (_localPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Image.file(
          File(_localPath!),
          width: widget.size,
          height: widget.size,
          fit: widget.fit,
          errorBuilder: (_, __, ___) => defaultPlaceholder,
        ),
      );
    }

    // Online fallback: direct network image (no local cache yet — happens on
    // very first launch for images we couldn't download in the background)
    final url = widget.url;
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Image.network(
          url,
          width: widget.size,
          height: widget.size,
          fit: widget.fit,
          loadingBuilder: (_, child, progress) =>
          progress == null ? child : defaultPlaceholder,
          errorBuilder: (_, __, ___) => defaultPlaceholder,
        ),
      );
    }

    return defaultPlaceholder;
  }
}