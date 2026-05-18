// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InventoryItemList)
final inventoryItemListProvider = InventoryItemListFamily._();

final class InventoryItemListProvider
    extends $AsyncNotifierProvider<InventoryItemList, List<InventoryItem>> {
  InventoryItemListProvider._({
    required InventoryItemListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'inventoryItemListProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$inventoryItemListHash();

  @override
  String toString() {
    return r'inventoryItemListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  InventoryItemList create() => InventoryItemList();

  @override
  bool operator ==(Object other) {
    return other is InventoryItemListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$inventoryItemListHash() => r'5f84f2cfcf1464397dd4d912044b54a28e1edcb7';

final class InventoryItemListFamily extends $Family
    with
        $ClassFamilyOverride<
          InventoryItemList,
          AsyncValue<List<InventoryItem>>,
          List<InventoryItem>,
          FutureOr<List<InventoryItem>>,
          String
        > {
  InventoryItemListFamily._()
    : super(
        retry: null,
        name: r'inventoryItemListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  InventoryItemListProvider call(String shopId) =>
      InventoryItemListProvider._(argument: shopId, from: this);

  @override
  String toString() => r'inventoryItemListProvider';
}

abstract class _$InventoryItemList extends $AsyncNotifier<List<InventoryItem>> {
  late final _$args = ref.$arg as String;
  String get shopId => _$args;

  FutureOr<List<InventoryItem>> build(String shopId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<InventoryItem>>, List<InventoryItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<InventoryItem>>, List<InventoryItem>>,
              AsyncValue<List<InventoryItem>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(InventoryRecipeList)
final inventoryRecipeListProvider = InventoryRecipeListFamily._();

final class InventoryRecipeListProvider
    extends $AsyncNotifierProvider<InventoryRecipeList, List<InventoryRecipe>> {
  InventoryRecipeListProvider._({
    required InventoryRecipeListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'inventoryRecipeListProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$inventoryRecipeListHash();

  @override
  String toString() {
    return r'inventoryRecipeListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  InventoryRecipeList create() => InventoryRecipeList();

  @override
  bool operator ==(Object other) {
    return other is InventoryRecipeListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$inventoryRecipeListHash() =>
    r'fdf75d3740a9d578d1a971a61df8b30cace2eb70';

final class InventoryRecipeListFamily extends $Family
    with
        $ClassFamilyOverride<
          InventoryRecipeList,
          AsyncValue<List<InventoryRecipe>>,
          List<InventoryRecipe>,
          FutureOr<List<InventoryRecipe>>,
          String
        > {
  InventoryRecipeListFamily._()
    : super(
        retry: null,
        name: r'inventoryRecipeListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  InventoryRecipeListProvider call(String shopId) =>
      InventoryRecipeListProvider._(argument: shopId, from: this);

  @override
  String toString() => r'inventoryRecipeListProvider';
}

abstract class _$InventoryRecipeList
    extends $AsyncNotifier<List<InventoryRecipe>> {
  late final _$args = ref.$arg as String;
  String get shopId => _$args;

  FutureOr<List<InventoryRecipe>> build(String shopId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<InventoryRecipe>>, List<InventoryRecipe>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<InventoryRecipe>>,
                List<InventoryRecipe>
              >,
              AsyncValue<List<InventoryRecipe>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(outOfStockMenuItemIds)
final outOfStockMenuItemIdsProvider = OutOfStockMenuItemIdsFamily._();

final class OutOfStockMenuItemIdsProvider
    extends $FunctionalProvider<Set<String>, Set<String>, Set<String>>
    with $Provider<Set<String>> {
  OutOfStockMenuItemIdsProvider._({
    required OutOfStockMenuItemIdsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'outOfStockMenuItemIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$outOfStockMenuItemIdsHash();

  @override
  String toString() {
    return r'outOfStockMenuItemIdsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Set<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Set<String> create(Ref ref) {
    final argument = this.argument as String;
    return outOfStockMenuItemIds(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OutOfStockMenuItemIdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$outOfStockMenuItemIdsHash() =>
    r'e5378e90884e43f69cfbdce0fb11aa38148c01e9';

final class OutOfStockMenuItemIdsFamily extends $Family
    with $FunctionalFamilyOverride<Set<String>, String> {
  OutOfStockMenuItemIdsFamily._()
    : super(
        retry: null,
        name: r'outOfStockMenuItemIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OutOfStockMenuItemIdsProvider call(String shopId) =>
      OutOfStockMenuItemIdsProvider._(argument: shopId, from: this);

  @override
  String toString() => r'outOfStockMenuItemIdsProvider';
}

@ProviderFor(shiftStockUsage)
final shiftStockUsageProvider = ShiftStockUsageFamily._();

final class ShiftStockUsageProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          FutureOr<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  ShiftStockUsageProvider._({
    required ShiftStockUsageFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'shiftStockUsageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$shiftStockUsageHash();

  @override
  String toString() {
    return r'shiftStockUsageProvider'
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
    return shiftStockUsage(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ShiftStockUsageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shiftStockUsageHash() => r'6f708b54e42bf3405840f9694b54967802629736';

final class ShiftStockUsageFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Map<String, dynamic>>>,
          String
        > {
  ShiftStockUsageFamily._()
    : super(
        retry: null,
        name: r'shiftStockUsageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ShiftStockUsageProvider call(String shiftId) =>
      ShiftStockUsageProvider._(argument: shiftId, from: this);

  @override
  String toString() => r'shiftStockUsageProvider';
}
