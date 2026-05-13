// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combo_menu_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ComboMenuList)
final comboMenuListProvider = ComboMenuListFamily._();

final class ComboMenuListProvider
    extends $AsyncNotifierProvider<ComboMenuList, List<ComboMenu>> {
  ComboMenuListProvider._({
    required ComboMenuListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'comboMenuListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$comboMenuListHash();

  @override
  String toString() {
    return r'comboMenuListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ComboMenuList create() => ComboMenuList();

  @override
  bool operator ==(Object other) {
    return other is ComboMenuListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$comboMenuListHash() => r'c84decf3b8fe708cb0dccedd50853430159779fc';

final class ComboMenuListFamily extends $Family
    with
        $ClassFamilyOverride<
          ComboMenuList,
          AsyncValue<List<ComboMenu>>,
          List<ComboMenu>,
          FutureOr<List<ComboMenu>>,
          String
        > {
  ComboMenuListFamily._()
    : super(
        retry: null,
        name: r'comboMenuListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ComboMenuListProvider call(String shopId) =>
      ComboMenuListProvider._(argument: shopId, from: this);

  @override
  String toString() => r'comboMenuListProvider';
}

abstract class _$ComboMenuList extends $AsyncNotifier<List<ComboMenu>> {
  late final _$args = ref.$arg as String;
  String get shopId => _$args;

  FutureOr<List<ComboMenu>> build(String shopId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<ComboMenu>>, List<ComboMenu>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ComboMenu>>, List<ComboMenu>>,
              AsyncValue<List<ComboMenu>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
