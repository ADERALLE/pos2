// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Watches connectivity and auto-syncs the offline queue when back online.
/// Instantiate once at app startup via ref.watch(syncServiceProvider).

@ProviderFor(SyncService)
final syncServiceProvider = SyncServiceProvider._();

/// Watches connectivity and auto-syncs the offline queue when back online.
/// Instantiate once at app startup via ref.watch(syncServiceProvider).
final class SyncServiceProvider
    extends $AsyncNotifierProvider<SyncService, void> {
  /// Watches connectivity and auto-syncs the offline queue when back online.
  /// Instantiate once at app startup via ref.watch(syncServiceProvider).
  SyncServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncServiceHash();

  @$internal
  @override
  SyncService create() => SyncService();
}

String _$syncServiceHash() => r'f88bf9aa082b74ec018afea56c06d1474126782b';

/// Watches connectivity and auto-syncs the offline queue when back online.
/// Instantiate once at app startup via ref.watch(syncServiceProvider).

abstract class _$SyncService extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// How many operations are waiting to sync (used by the banner badge).

@ProviderFor(pendingOpsCount)
final pendingOpsCountProvider = PendingOpsCountProvider._();

/// How many operations are waiting to sync (used by the banner badge).

final class PendingOpsCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// How many operations are waiting to sync (used by the banner badge).
  PendingOpsCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingOpsCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingOpsCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return pendingOpsCount(ref);
  }
}

String _$pendingOpsCountHash() => r'216c656427e65d1549920527d2fcbfc8226b271b';
