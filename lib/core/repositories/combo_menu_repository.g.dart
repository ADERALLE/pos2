// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combo_menu_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(comboMenuRepository)
final comboMenuRepositoryProvider = ComboMenuRepositoryProvider._();

final class ComboMenuRepositoryProvider
    extends
        $FunctionalProvider<
          ComboMenuRepository,
          ComboMenuRepository,
          ComboMenuRepository
        >
    with $Provider<ComboMenuRepository> {
  ComboMenuRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'comboMenuRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$comboMenuRepositoryHash();

  @$internal
  @override
  $ProviderElement<ComboMenuRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ComboMenuRepository create(Ref ref) {
    return comboMenuRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ComboMenuRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ComboMenuRepository>(value),
    );
  }
}

String _$comboMenuRepositoryHash() =>
    r'029cee6062badf86a359fbcfa38075d6eb6f7ebf';
