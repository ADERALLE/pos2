// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_notifications_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(allNotificationsRepository)
final allNotificationsRepositoryProvider =
    AllNotificationsRepositoryProvider._();

final class AllNotificationsRepositoryProvider
    extends
        $FunctionalProvider<
          AllNotificationsRepository,
          AllNotificationsRepository,
          AllNotificationsRepository
        >
    with $Provider<AllNotificationsRepository> {
  AllNotificationsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allNotificationsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allNotificationsRepositoryHash();

  @$internal
  @override
  $ProviderElement<AllNotificationsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AllNotificationsRepository create(Ref ref) {
    return allNotificationsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AllNotificationsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AllNotificationsRepository>(value),
    );
  }
}

String _$allNotificationsRepositoryHash() =>
    r'84afc8e843c1c9fef6f701537d55bff2da53e792';
