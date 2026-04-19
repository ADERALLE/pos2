// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(staffRepository)
final staffRepositoryProvider = StaffRepositoryProvider._();

final class StaffRepositoryProvider extends $FunctionalProvider<StaffRepository,
    StaffRepository, StaffRepository> with $Provider<StaffRepository> {
  StaffRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'staffRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$staffRepositoryHash();

  @$internal
  @override
  $ProviderElement<StaffRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StaffRepository create(Ref ref) {
    return staffRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StaffRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StaffRepository>(value),
    );
  }
}

String _$staffRepositoryHash() => r'e9eff0dfd40d5e5b01292432a83c14e9d9b98bd9';
