// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_dashboard_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(staffList)
final staffListProvider = StaffListFamily._();

final class StaffListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          FutureOr<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  StaffListProvider._({
    required StaffListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'staffListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$staffListHash();

  @override
  String toString() {
    return r'staffListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    final argument = this.argument as String;
    return staffList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StaffListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$staffListHash() => r'7ddd3435746e8a9daabe943d93384eb372d0a44b';

final class StaffListFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Map<String, dynamic>>>,
          String
        > {
  StaffListFamily._()
    : super(
        retry: null,
        name: r'staffListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StaffListProvider call(String shopId) =>
      StaffListProvider._(argument: shopId, from: this);

  @override
  String toString() => r'staffListProvider';
}

/// All-time aggregated stats for a staff member.
/// Backed by the `get_staff_stats` SQL RPC — one DB round-trip, no client math.

@ProviderFor(staffStats)
final staffStatsProvider = StaffStatsFamily._();

/// All-time aggregated stats for a staff member.
/// Backed by the `get_staff_stats` SQL RPC — one DB round-trip, no client math.

final class StaffStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<StaffStats>,
          StaffStats,
          FutureOr<StaffStats>
        >
    with $FutureModifier<StaffStats>, $FutureProvider<StaffStats> {
  /// All-time aggregated stats for a staff member.
  /// Backed by the `get_staff_stats` SQL RPC — one DB round-trip, no client math.
  StaffStatsProvider._({
    required StaffStatsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'staffStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$staffStatsHash();

  @override
  String toString() {
    return r'staffStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<StaffStats> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<StaffStats> create(Ref ref) {
    final argument = this.argument as String;
    return staffStats(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StaffStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$staffStatsHash() => r'908e048b62e8def24854805d84acca18936a9638';

/// All-time aggregated stats for a staff member.
/// Backed by the `get_staff_stats` SQL RPC — one DB round-trip, no client math.

final class StaffStatsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<StaffStats>, String> {
  StaffStatsFamily._()
    : super(
        retry: null,
        name: r'staffStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// All-time aggregated stats for a staff member.
  /// Backed by the `get_staff_stats` SQL RPC — one DB round-trip, no client math.

  StaffStatsProvider call(String staffId) =>
      StaffStatsProvider._(argument: staffId, from: this);

  @override
  String toString() => r'staffStatsProvider';
}

/// Single most-recent shift. Powers the "Last Shift" tab.

@ProviderFor(staffLatestShift)
final staffLatestShiftProvider = StaffLatestShiftFamily._();

/// Single most-recent shift. Powers the "Last Shift" tab.

final class StaffLatestShiftProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>?>,
          Map<String, dynamic>?,
          FutureOr<Map<String, dynamic>?>
        >
    with
        $FutureModifier<Map<String, dynamic>?>,
        $FutureProvider<Map<String, dynamic>?> {
  /// Single most-recent shift. Powers the "Last Shift" tab.
  StaffLatestShiftProvider._({
    required StaffLatestShiftFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'staffLatestShiftProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$staffLatestShiftHash();

  @override
  String toString() {
    return r'staffLatestShiftProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>?> create(Ref ref) {
    final argument = this.argument as String;
    return staffLatestShift(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StaffLatestShiftProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$staffLatestShiftHash() => r'0fe345704d067ba8cf2b6b88dc8a1cbf820aa0d1';

/// Single most-recent shift. Powers the "Last Shift" tab.

final class StaffLatestShiftFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, dynamic>?>, String> {
  StaffLatestShiftFamily._()
    : super(
        retry: null,
        name: r'staffLatestShiftProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Single most-recent shift. Powers the "Last Shift" tab.

  StaffLatestShiftProvider call(String staffId) =>
      StaffLatestShiftProvider._(argument: staffId, from: this);

  @override
  String toString() => r'staffLatestShiftProvider';
}

@ProviderFor(StaffShifts)
final staffShiftsProvider = StaffShiftsFamily._();

final class StaffShiftsProvider
    extends $AsyncNotifierProvider<StaffShifts, List<Map<String, dynamic>>> {
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

String _$staffShiftsHash() => r'cc3fb11236f55e176285b52169cdd3935f799ed2';

final class StaffShiftsFamily extends $Family
    with
        $ClassFamilyOverride<
          StaffShifts,
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          FutureOr<List<Map<String, dynamic>>>,
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

abstract class _$StaffShifts
    extends $AsyncNotifier<List<Map<String, dynamic>>> {
  late final _$args = ref.$arg as String;
  String get staffId => _$args;

  FutureOr<List<Map<String, dynamic>>> build(String staffId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<Map<String, dynamic>>>,
              List<Map<String, dynamic>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<Map<String, dynamic>>>,
                List<Map<String, dynamic>>
              >,
              AsyncValue<List<Map<String, dynamic>>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
