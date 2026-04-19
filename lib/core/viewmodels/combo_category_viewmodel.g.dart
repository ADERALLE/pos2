// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combo_category_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ComboCategoryList)
final comboCategoryListProvider = ComboCategoryListFamily._();

final class ComboCategoryListProvider
    extends $AsyncNotifierProvider<ComboCategoryList, List<Category>> {
  ComboCategoryListProvider._(
      {required ComboCategoryListFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'comboCategoryListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$comboCategoryListHash();

  @override
  String toString() {
    return r'comboCategoryListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ComboCategoryList create() => ComboCategoryList();

  @override
  bool operator ==(Object other) {
    return other is ComboCategoryListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$comboCategoryListHash() =>
    r'combo_category_list_placeholder_hash_value';

final class ComboCategoryListFamily extends $Family
    with
        $ClassFamilyOverride<ComboCategoryList, AsyncValue<List<Category>>,
            List<Category>, FutureOr<List<Category>>, String> {
  ComboCategoryListFamily._()
      : super(
          retry: null,
          name: r'comboCategoryListProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  ComboCategoryListProvider call(
    String shopId,
  ) =>
      ComboCategoryListProvider._(argument: shopId, from: this);

  @override
  String toString() => r'comboCategoryListProvider';
}

abstract class _$ComboCategoryList extends $AsyncNotifier<List<Category>> {
  late final _$args = ref.$arg as String;
  String get shopId => _$args;

  FutureOr<List<Category>> build(
    String shopId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Category>>, List<Category>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Category>>, List<Category>>,
        AsyncValue<List<Category>>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
