// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CategoryList)
final categoryListProvider = CategoryListFamily._();

final class CategoryListProvider
    extends $AsyncNotifierProvider<CategoryList, List<Category>> {
  CategoryListProvider._({
    required CategoryListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'categoryListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryListHash();

  @override
  String toString() {
    return r'categoryListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CategoryList create() => CategoryList();

  @override
  bool operator ==(Object other) {
    return other is CategoryListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryListHash() => r'24f1d15e27fe13b3f6bd8da8bdd8c9384acd9e8a';

final class CategoryListFamily extends $Family
    with
        $ClassFamilyOverride<
          CategoryList,
          AsyncValue<List<Category>>,
          List<Category>,
          FutureOr<List<Category>>,
          String
        > {
  CategoryListFamily._()
    : super(
        retry: null,
        name: r'categoryListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoryListProvider call(String shopId) =>
      CategoryListProvider._(argument: shopId, from: this);

  @override
  String toString() => r'categoryListProvider';
}

abstract class _$CategoryList extends $AsyncNotifier<List<Category>> {
  late final _$args = ref.$arg as String;
  String get shopId => _$args;

  FutureOr<List<Category>> build(String shopId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Category>>, List<Category>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Category>>, List<Category>>,
              AsyncValue<List<Category>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(ComboCategoryList)
final comboCategoryListProvider = ComboCategoryListFamily._();

final class ComboCategoryListProvider
    extends $AsyncNotifierProvider<ComboCategoryList, List<Category>> {
  ComboCategoryListProvider._({
    required ComboCategoryListFamily super.from,
    required String super.argument,
  }) : super(
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

String _$comboCategoryListHash() => r'222f62deadbe730e7773d7fe38cf4eb51533915f';

final class ComboCategoryListFamily extends $Family
    with
        $ClassFamilyOverride<
          ComboCategoryList,
          AsyncValue<List<Category>>,
          List<Category>,
          FutureOr<List<Category>>,
          String
        > {
  ComboCategoryListFamily._()
    : super(
        retry: null,
        name: r'comboCategoryListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ComboCategoryListProvider call(String shopId) =>
      ComboCategoryListProvider._(argument: shopId, from: this);

  @override
  String toString() => r'comboCategoryListProvider';
}

abstract class _$ComboCategoryList extends $AsyncNotifier<List<Category>> {
  late final _$args = ref.$arg as String;
  String get shopId => _$args;

  FutureOr<List<Category>> build(String shopId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Category>>, List<Category>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Category>>, List<Category>>,
              AsyncValue<List<Category>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(MenuItemList)
final menuItemListProvider = MenuItemListFamily._();

final class MenuItemListProvider
    extends $AsyncNotifierProvider<MenuItemList, List<MenuItem>> {
  MenuItemListProvider._({
    required MenuItemListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'menuItemListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$menuItemListHash();

  @override
  String toString() {
    return r'menuItemListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MenuItemList create() => MenuItemList();

  @override
  bool operator ==(Object other) {
    return other is MenuItemListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$menuItemListHash() => r'9069ee940d92fdf1edf5c3612d05a1dbc8f4d34a';

final class MenuItemListFamily extends $Family
    with
        $ClassFamilyOverride<
          MenuItemList,
          AsyncValue<List<MenuItem>>,
          List<MenuItem>,
          FutureOr<List<MenuItem>>,
          String
        > {
  MenuItemListFamily._()
    : super(
        retry: null,
        name: r'menuItemListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MenuItemListProvider call(String shopId) =>
      MenuItemListProvider._(argument: shopId, from: this);

  @override
  String toString() => r'menuItemListProvider';
}

abstract class _$MenuItemList extends $AsyncNotifier<List<MenuItem>> {
  late final _$args = ref.$arg as String;
  String get shopId => _$args;

  FutureOr<List<MenuItem>> build(String shopId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<MenuItem>>, List<MenuItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<MenuItem>>, List<MenuItem>>,
              AsyncValue<List<MenuItem>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
