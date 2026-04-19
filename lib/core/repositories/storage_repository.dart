import 'dart:io';
import 'package:pos_v1/core/services/supabase_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'storage_repository.g.dart';

@riverpod
StorageRepository storageRepository(Ref ref) {
  return StorageRepository(ref.watch(supabaseClientProvider));
}

class StorageRepository {
  StorageRepository(this._client);
  final SupabaseClient _client;

  Future<String> uploadMenuImage({
    required File file,
    required String shopId,
  }) async {
    final fileName = '${shopId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'shops/$shopId/$fileName';

    await _client.storage.from('menu-images').upload(
      path,
      file,
      fileOptions: const FileOptions(upsert: true),
    );

    return _client.storage.from('menu-images').getPublicUrl(path);
  }

  Future<void> deleteMenuImage(String imageUrl) async {
    final uri = Uri.parse(imageUrl);
    final path = uri.pathSegments
        .skipWhile((s) => s != 'menu-images')
        .skip(1)
        .join('/');
    await _client.storage.from('menu-images').remove([path]);
  }
}