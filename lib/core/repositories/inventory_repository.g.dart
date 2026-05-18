// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(inventoryRepository)
final inventoryRepositoryProvider = InventoryRepositoryProvider._();

final class InventoryRepositoryProvider
    extends
        $FunctionalProvider<
          InventoryRepository,
          InventoryRepository,
          InventoryRepository
        >
    with $Provider<InventoryRepository> {
  InventoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<InventoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InventoryRepository create(Ref ref) {
    return inventoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InventoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InventoryRepository>(value),
    );
  }
}

String _$inventoryRepositoryHash() =>
    r'dfa227bf473735c359e3a26c154b05c958d7696f';
