// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Notifications)
final notificationsProvider = NotificationsFamily._();

final class NotificationsProvider
    extends $AsyncNotifierProvider<Notifications, List<AppNotification>> {
  NotificationsProvider._({
    required NotificationsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'notificationsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$notificationsHash();

  @override
  String toString() {
    return r'notificationsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Notifications create() => Notifications();

  @override
  bool operator ==(Object other) {
    return other is NotificationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$notificationsHash() => r'3736cee8ccbf5cea5ff9ed6cda4db2f966e4f86e';

final class NotificationsFamily extends $Family
    with
        $ClassFamilyOverride<
          Notifications,
          AsyncValue<List<AppNotification>>,
          List<AppNotification>,
          FutureOr<List<AppNotification>>,
          String
        > {
  NotificationsFamily._()
    : super(
        retry: null,
        name: r'notificationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  NotificationsProvider call(String shopId) =>
      NotificationsProvider._(argument: shopId, from: this);

  @override
  String toString() => r'notificationsProvider';
}

abstract class _$Notifications extends $AsyncNotifier<List<AppNotification>> {
  late final _$args = ref.$arg as String;
  String get shopId => _$args;

  FutureOr<List<AppNotification>> build(String shopId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<AppNotification>>, List<AppNotification>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<AppNotification>>,
                List<AppNotification>
              >,
              AsyncValue<List<AppNotification>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
