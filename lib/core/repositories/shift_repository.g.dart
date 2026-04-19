// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(shiftRepository)
final shiftRepositoryProvider = ShiftRepositoryProvider._();

final class ShiftRepositoryProvider extends $FunctionalProvider<ShiftRepository,
    ShiftRepository, ShiftRepository> with $Provider<ShiftRepository> {
  ShiftRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'shiftRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$shiftRepositoryHash();

  @$internal
  @override
  $ProviderElement<ShiftRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ShiftRepository create(Ref ref) {
    return shiftRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShiftRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShiftRepository>(value),
    );
  }
}

String _$shiftRepositoryHash() => r'1f471908f3edadd624c2a1fa819ff78bb93c3f5e';
