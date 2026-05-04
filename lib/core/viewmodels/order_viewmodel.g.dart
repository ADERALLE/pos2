// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActiveOrders)
final activeOrdersProvider = ActiveOrdersFamily._();

final class ActiveOrdersProvider
    extends $AsyncNotifierProvider<ActiveOrders, List<Order>> {
  ActiveOrdersProvider._({
    required ActiveOrdersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activeOrdersProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activeOrdersHash();

  @override
  String toString() {
    return r'activeOrdersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ActiveOrders create() => ActiveOrders();

  @override
  bool operator ==(Object other) {
    return other is ActiveOrdersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activeOrdersHash() => r'7cd05612fd4846a01a13f4b5d2074317bf4b5d30';

final class ActiveOrdersFamily extends $Family
    with
        $ClassFamilyOverride<
          ActiveOrders,
          AsyncValue<List<Order>>,
          List<Order>,
          FutureOr<List<Order>>,
          String
        > {
  ActiveOrdersFamily._()
    : super(
        retry: null,
        name: r'activeOrdersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ActiveOrdersProvider call(String shopId) =>
      ActiveOrdersProvider._(argument: shopId, from: this);

  @override
  String toString() => r'activeOrdersProvider';
}

abstract class _$ActiveOrders extends $AsyncNotifier<List<Order>> {
  late final _$args = ref.$arg as String;
  String get shopId => _$args;

  FutureOr<List<Order>> build(String shopId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Order>>, List<Order>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Order>>, List<Order>>,
              AsyncValue<List<Order>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(OrderHistory)
final orderHistoryProvider = OrderHistoryFamily._();

final class OrderHistoryProvider
    extends $AsyncNotifierProvider<OrderHistory, List<Order>> {
  OrderHistoryProvider._({
    required OrderHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'orderHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$orderHistoryHash();

  @override
  String toString() {
    return r'orderHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  OrderHistory create() => OrderHistory();

  @override
  bool operator ==(Object other) {
    return other is OrderHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderHistoryHash() => r'961faa2d667bf67bfd4f031100cbb36256e5c18b';

final class OrderHistoryFamily extends $Family
    with
        $ClassFamilyOverride<
          OrderHistory,
          AsyncValue<List<Order>>,
          List<Order>,
          FutureOr<List<Order>>,
          String
        > {
  OrderHistoryFamily._()
    : super(
        retry: null,
        name: r'orderHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OrderHistoryProvider call(String shopId) =>
      OrderHistoryProvider._(argument: shopId, from: this);

  @override
  String toString() => r'orderHistoryProvider';
}

abstract class _$OrderHistory extends $AsyncNotifier<List<Order>> {
  late final _$args = ref.$arg as String;
  String get shopId => _$args;

  FutureOr<List<Order>> build(String shopId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Order>>, List<Order>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Order>>, List<Order>>,
              AsyncValue<List<Order>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(MyOrderHistory)
final myOrderHistoryProvider = MyOrderHistoryFamily._();

final class MyOrderHistoryProvider
    extends $AsyncNotifierProvider<MyOrderHistory, List<Order>> {
  MyOrderHistoryProvider._({
    required MyOrderHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'myOrderHistoryProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myOrderHistoryHash();

  @override
  String toString() {
    return r'myOrderHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MyOrderHistory create() => MyOrderHistory();

  @override
  bool operator ==(Object other) {
    return other is MyOrderHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myOrderHistoryHash() => r'7642fccaa01cff472b285eb3304b8e7e0d15c4bc';

final class MyOrderHistoryFamily extends $Family
    with
        $ClassFamilyOverride<
          MyOrderHistory,
          AsyncValue<List<Order>>,
          List<Order>,
          FutureOr<List<Order>>,
          String
        > {
  MyOrderHistoryFamily._()
    : super(
        retry: null,
        name: r'myOrderHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  MyOrderHistoryProvider call(String cashierId) =>
      MyOrderHistoryProvider._(argument: cashierId, from: this);

  @override
  String toString() => r'myOrderHistoryProvider';
}

abstract class _$MyOrderHistory extends $AsyncNotifier<List<Order>> {
  late final _$args = ref.$arg as String;
  String get cashierId => _$args;

  FutureOr<List<Order>> build(String cashierId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Order>>, List<Order>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Order>>, List<Order>>,
              AsyncValue<List<Order>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(ShopOrderHistory)
final shopOrderHistoryProvider = ShopOrderHistoryFamily._();

final class ShopOrderHistoryProvider
    extends $AsyncNotifierProvider<ShopOrderHistory, List<Order>> {
  ShopOrderHistoryProvider._({
    required ShopOrderHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'shopOrderHistoryProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$shopOrderHistoryHash();

  @override
  String toString() {
    return r'shopOrderHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ShopOrderHistory create() => ShopOrderHistory();

  @override
  bool operator ==(Object other) {
    return other is ShopOrderHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shopOrderHistoryHash() => r'5cf855c30a1663b0be812673f2ce02a0123a3d05';

final class ShopOrderHistoryFamily extends $Family
    with
        $ClassFamilyOverride<
          ShopOrderHistory,
          AsyncValue<List<Order>>,
          List<Order>,
          FutureOr<List<Order>>,
          String
        > {
  ShopOrderHistoryFamily._()
    : super(
        retry: null,
        name: r'shopOrderHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ShopOrderHistoryProvider call(String shopId) =>
      ShopOrderHistoryProvider._(argument: shopId, from: this);

  @override
  String toString() => r'shopOrderHistoryProvider';
}

abstract class _$ShopOrderHistory extends $AsyncNotifier<List<Order>> {
  late final _$args = ref.$arg as String;
  String get shopId => _$args;

  FutureOr<List<Order>> build(String shopId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Order>>, List<Order>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Order>>, List<Order>>,
              AsyncValue<List<Order>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(MyActiveOrders)
final myActiveOrdersProvider = MyActiveOrdersFamily._();

final class MyActiveOrdersProvider
    extends $AsyncNotifierProvider<MyActiveOrders, List<Order>> {
  MyActiveOrdersProvider._({
    required MyActiveOrdersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'myActiveOrdersProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myActiveOrdersHash();

  @override
  String toString() {
    return r'myActiveOrdersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MyActiveOrders create() => MyActiveOrders();

  @override
  bool operator ==(Object other) {
    return other is MyActiveOrdersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myActiveOrdersHash() => r'522ea82bc926187d6c23ef667c2217a85932ddf8';

final class MyActiveOrdersFamily extends $Family
    with
        $ClassFamilyOverride<
          MyActiveOrders,
          AsyncValue<List<Order>>,
          List<Order>,
          FutureOr<List<Order>>,
          String
        > {
  MyActiveOrdersFamily._()
    : super(
        retry: null,
        name: r'myActiveOrdersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  MyActiveOrdersProvider call(String cashierId) =>
      MyActiveOrdersProvider._(argument: cashierId, from: this);

  @override
  String toString() => r'myActiveOrdersProvider';
}

abstract class _$MyActiveOrders extends $AsyncNotifier<List<Order>> {
  late final _$args = ref.$arg as String;
  String get cashierId => _$args;

  FutureOr<List<Order>> build(String cashierId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Order>>, List<Order>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Order>>, List<Order>>,
              AsyncValue<List<Order>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(ShiftOrders)
final shiftOrdersProvider = ShiftOrdersFamily._();

final class ShiftOrdersProvider
    extends $AsyncNotifierProvider<ShiftOrders, List<Order>> {
  ShiftOrdersProvider._({
    required ShiftOrdersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'shiftOrdersProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$shiftOrdersHash();

  @override
  String toString() {
    return r'shiftOrdersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ShiftOrders create() => ShiftOrders();

  @override
  bool operator ==(Object other) {
    return other is ShiftOrdersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shiftOrdersHash() => r'2179d33682fa3a9894291021581202d51a6a7a96';

final class ShiftOrdersFamily extends $Family
    with
        $ClassFamilyOverride<
          ShiftOrders,
          AsyncValue<List<Order>>,
          List<Order>,
          FutureOr<List<Order>>,
          String
        > {
  ShiftOrdersFamily._()
    : super(
        retry: null,
        name: r'shiftOrdersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ShiftOrdersProvider call(String shiftId) =>
      ShiftOrdersProvider._(argument: shiftId, from: this);

  @override
  String toString() => r'shiftOrdersProvider';
}

abstract class _$ShiftOrders extends $AsyncNotifier<List<Order>> {
  late final _$args = ref.$arg as String;
  String get shiftId => _$args;

  FutureOr<List<Order>> build(String shiftId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Order>>, List<Order>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Order>>, List<Order>>,
              AsyncValue<List<Order>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(Cart)
final cartProvider = CartProvider._();

final class CartProvider extends $NotifierProvider<Cart, List<CartItem>> {
  CartProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartHash();

  @$internal
  @override
  Cart create() => Cart();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CartItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CartItem>>(value),
    );
  }
}

String _$cartHash() => r'675fb1c8dcdcbfc9e35a7f560eb70343f0bb1256';

abstract class _$Cart extends $Notifier<List<CartItem>> {
  List<CartItem> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<CartItem>, List<CartItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<CartItem>, List<CartItem>>,
              List<CartItem>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(OrderSearch)
final orderSearchProvider = OrderSearchProvider._();

final class OrderSearchProvider
    extends $AsyncNotifierProvider<OrderSearch, List<Order>> {
  OrderSearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderSearchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderSearchHash();

  @$internal
  @override
  OrderSearch create() => OrderSearch();
}

String _$orderSearchHash() => r'281088516b532eaa2e04ecfd60d85c7c8528e624';

abstract class _$OrderSearch extends $AsyncNotifier<List<Order>> {
  FutureOr<List<Order>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Order>>, List<Order>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Order>>, List<Order>>,
              AsyncValue<List<Order>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
