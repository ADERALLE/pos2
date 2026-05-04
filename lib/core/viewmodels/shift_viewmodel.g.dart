// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActiveShift)
final activeShiftProvider = ActiveShiftFamily._();

final class ActiveShiftProvider
    extends $AsyncNotifierProvider<ActiveShift, Shift?> {
  ActiveShiftProvider._({
    required ActiveShiftFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activeShiftProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activeShiftHash();

  @override
  String toString() {
    return r'activeShiftProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ActiveShift create() => ActiveShift();

  @override
  bool operator ==(Object other) {
    return other is ActiveShiftProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activeShiftHash() => r'7355fd05a492e070b4a8486dfe51b6bfb9c931ca';

final class ActiveShiftFamily extends $Family
    with
        $ClassFamilyOverride<
          ActiveShift,
          AsyncValue<Shift?>,
          Shift?,
          FutureOr<Shift?>,
          String
        > {
  ActiveShiftFamily._()
    : super(
        retry: null,
        name: r'activeShiftProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ActiveShiftProvider call(String staffId) =>
      ActiveShiftProvider._(argument: staffId, from: this);

  @override
  String toString() => r'activeShiftProvider';
}

abstract class _$ActiveShift extends $AsyncNotifier<Shift?> {
  late final _$args = ref.$arg as String;
  String get staffId => _$args;

  FutureOr<Shift?> build(String staffId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Shift?>, Shift?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Shift?>, Shift?>,
              AsyncValue<Shift?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(ShopShifts)
final shopShiftsProvider = ShopShiftsFamily._();

final class ShopShiftsProvider
    extends $AsyncNotifierProvider<ShopShifts, List<Shift>> {
  ShopShiftsProvider._({
    required ShopShiftsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'shopShiftsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$shopShiftsHash();

  @override
  String toString() {
    return r'shopShiftsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ShopShifts create() => ShopShifts();

  @override
  bool operator ==(Object other) {
    return other is ShopShiftsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shopShiftsHash() => r'8956f63fa7fd10d27270f863c198b82b08308edb';

final class ShopShiftsFamily extends $Family
    with
        $ClassFamilyOverride<
          ShopShifts,
          AsyncValue<List<Shift>>,
          List<Shift>,
          FutureOr<List<Shift>>,
          String
        > {
  ShopShiftsFamily._()
    : super(
        retry: null,
        name: r'shopShiftsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ShopShiftsProvider call(String shopId) =>
      ShopShiftsProvider._(argument: shopId, from: this);

  @override
  String toString() => r'shopShiftsProvider';
}

abstract class _$ShopShifts extends $AsyncNotifier<List<Shift>> {
  late final _$args = ref.$arg as String;
  String get shopId => _$args;

  FutureOr<List<Shift>> build(String shopId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Shift>>, List<Shift>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Shift>>, List<Shift>>,
              AsyncValue<List<Shift>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(StaffShifts)
final staffShiftsProvider = StaffShiftsFamily._();

final class StaffShiftsProvider
    extends $AsyncNotifierProvider<StaffShifts, List<Shift>> {
  StaffShiftsProvider._({
    required StaffShiftsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'staffShiftsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$staffShiftsHash();

  @override
  String toString() {
    return r'staffShiftsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StaffShifts create() => StaffShifts();

  @override
  bool operator ==(Object other) {
    return other is StaffShiftsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$staffShiftsHash() => r'10ae5ae88d58d8ea956bd97cd54f0e923687f06a';

final class StaffShiftsFamily extends $Family
    with
        $ClassFamilyOverride<
          StaffShifts,
          AsyncValue<List<Shift>>,
          List<Shift>,
          FutureOr<List<Shift>>,
          String
        > {
  StaffShiftsFamily._()
    : super(
        retry: null,
        name: r'staffShiftsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StaffShiftsProvider call(String staffId) =>
      StaffShiftsProvider._(argument: staffId, from: this);

  @override
  String toString() => r'staffShiftsProvider';
}

abstract class _$StaffShifts extends $AsyncNotifier<List<Shift>> {
  late final _$args = ref.$arg as String;
  String get staffId => _$args;

  FutureOr<List<Shift>> build(String staffId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Shift>>, List<Shift>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Shift>>, List<Shift>>,
              AsyncValue<List<Shift>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
