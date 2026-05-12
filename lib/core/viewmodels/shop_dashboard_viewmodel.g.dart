// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_dashboard_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dailySummary)
final dailySummaryProvider = DailySummaryFamily._();

final class DailySummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<DailySummary>,
          DailySummary,
          FutureOr<DailySummary>
        >
    with $FutureModifier<DailySummary>, $FutureProvider<DailySummary> {
  DailySummaryProvider._({
    required DailySummaryFamily super.from,
    required (String, DateRange) super.argument,
  }) : super(
         retry: null,
         name: r'dailySummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dailySummaryHash();

  @override
  String toString() {
    return r'dailySummaryProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<DailySummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DailySummary> create(Ref ref) {
    final argument = this.argument as (String, DateRange);
    return dailySummary(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is DailySummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dailySummaryHash() => r'a98128c7d43e8df91614c2870543f37571de00da';

final class DailySummaryFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<DailySummary>, (String, DateRange)> {
  DailySummaryFamily._()
    : super(
        retry: null,
        name: r'dailySummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DailySummaryProvider call(String shopId, DateRange range) =>
      DailySummaryProvider._(argument: (shopId, range), from: this);

  @override
  String toString() => r'dailySummaryProvider';
}
