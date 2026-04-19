// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_notifications_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AllNotifications)
final allNotificationsProvider = AllNotificationsFamily._();

final class AllNotificationsProvider
    extends $AsyncNotifierProvider<AllNotifications, List<AppNotification>> {
  AllNotificationsProvider._(
      {required AllNotificationsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'allNotificationsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$allNotificationsHash();

  @override
  String toString() {
    return r'allNotificationsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AllNotifications create() => AllNotifications();

  @override
  bool operator ==(Object other) {
    return other is AllNotificationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$allNotificationsHash() => r'badd9ab4f29d89ceef88ca5ae09aa2a44792afc0';

final class AllNotificationsFamily extends $Family
    with
        $ClassFamilyOverride<
            AllNotifications,
            AsyncValue<List<AppNotification>>,
            List<AppNotification>,
            FutureOr<List<AppNotification>>,
            String> {
  AllNotificationsFamily._()
      : super(
          retry: null,
          name: r'allNotificationsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  AllNotificationsProvider call(
    String shopId,
  ) =>
      AllNotificationsProvider._(argument: shopId, from: this);

  @override
  String toString() => r'allNotificationsProvider';
}

abstract class _$AllNotifications
    extends $AsyncNotifier<List<AppNotification>> {
  late final _$args = ref.$arg as String;
  String get shopId => _$args;

  FutureOr<List<AppNotification>> build(
    String shopId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<List<AppNotification>>, List<AppNotification>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<AppNotification>>, List<AppNotification>>,
        AsyncValue<List<AppNotification>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
