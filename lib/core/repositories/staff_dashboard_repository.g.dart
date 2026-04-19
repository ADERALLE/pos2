// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_dashboard_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(staffDashboardRepository)
final staffDashboardRepositoryProvider = StaffDashboardRepositoryProvider._();

final class StaffDashboardRepositoryProvider extends $FunctionalProvider<
    StaffDashboardRepository,
    StaffDashboardRepository,
    StaffDashboardRepository> with $Provider<StaffDashboardRepository> {
  StaffDashboardRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'staffDashboardRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$staffDashboardRepositoryHash();

  @$internal
  @override
  $ProviderElement<StaffDashboardRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StaffDashboardRepository create(Ref ref) {
    return staffDashboardRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StaffDashboardRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StaffDashboardRepository>(value),
    );
  }
}

String _$staffDashboardRepositoryHash() =>
    r'c7da0bed33b18b1b772d819b12e54cb9d13904e7';
