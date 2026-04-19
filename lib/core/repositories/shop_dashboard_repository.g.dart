// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_dashboard_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(shopDashboardRepository)
final shopDashboardRepositoryProvider = ShopDashboardRepositoryProvider._();

final class ShopDashboardRepositoryProvider extends $FunctionalProvider<
    ShopDashboardRepository,
    ShopDashboardRepository,
    ShopDashboardRepository> with $Provider<ShopDashboardRepository> {
  ShopDashboardRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'shopDashboardRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$shopDashboardRepositoryHash();

  @$internal
  @override
  $ProviderElement<ShopDashboardRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ShopDashboardRepository create(Ref ref) {
    return shopDashboardRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShopDashboardRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShopDashboardRepository>(value),
    );
  }
}

String _$shopDashboardRepositoryHash() =>
    r'3aeb19b4ac4025bb5d99806d6f9a60d920785005';
