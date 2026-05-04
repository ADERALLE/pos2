// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Order {

 String get id;@JsonKey(name: 'shop_id') String get shopId;@JsonKey(name: 'shift_id') String? get shiftId;@JsonKey(name: 'cashier_id') String get cashierId;@JsonKey(name: 'cashier_name') String? get cashierName; OrderStatus get status;@JsonKey(name: 'table_label') String? get tableLabel; double get total; String? get note;/// 'cash' | 'card' | 'split'  – kept for legacy reads; prefer cashAmount/cardAmount.
@JsonKey(name: 'payment_method') String get paymentMethod; double get tip;/// Amount paid in cash (may be partial for split payments).
@JsonKey(name: 'cash_amount') double get cashAmount;/// Amount paid by card (may be partial for split payments).
@JsonKey(name: 'card_amount') double get cardAmount;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;@JsonKey(name: 'order_items') List<OrderItem> get orderItems;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.shiftId, shiftId) || other.shiftId == shiftId)&&(identical(other.cashierId, cashierId) || other.cashierId == cashierId)&&(identical(other.cashierName, cashierName) || other.cashierName == cashierName)&&(identical(other.status, status) || other.status == status)&&(identical(other.tableLabel, tableLabel) || other.tableLabel == tableLabel)&&(identical(other.total, total) || other.total == total)&&(identical(other.note, note) || other.note == note)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.tip, tip) || other.tip == tip)&&(identical(other.cashAmount, cashAmount) || other.cashAmount == cashAmount)&&(identical(other.cardAmount, cardAmount) || other.cardAmount == cardAmount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.orderItems, orderItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,shiftId,cashierId,cashierName,status,tableLabel,total,note,paymentMethod,tip,cashAmount,cardAmount,createdAt,updatedAt,const DeepCollectionEquality().hash(orderItems));

@override
String toString() {
  return 'Order(id: $id, shopId: $shopId, shiftId: $shiftId, cashierId: $cashierId, cashierName: $cashierName, status: $status, tableLabel: $tableLabel, total: $total, note: $note, paymentMethod: $paymentMethod, tip: $tip, cashAmount: $cashAmount, cardAmount: $cardAmount, createdAt: $createdAt, updatedAt: $updatedAt, orderItems: $orderItems)';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'shop_id') String shopId,@JsonKey(name: 'shift_id') String? shiftId,@JsonKey(name: 'cashier_id') String cashierId,@JsonKey(name: 'cashier_name') String? cashierName, OrderStatus status,@JsonKey(name: 'table_label') String? tableLabel, double total, String? note,@JsonKey(name: 'payment_method') String paymentMethod, double tip,@JsonKey(name: 'cash_amount') double cashAmount,@JsonKey(name: 'card_amount') double cardAmount,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'order_items') List<OrderItem> orderItems
});




}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shopId = null,Object? shiftId = freezed,Object? cashierId = null,Object? cashierName = freezed,Object? status = null,Object? tableLabel = freezed,Object? total = null,Object? note = freezed,Object? paymentMethod = null,Object? tip = null,Object? cashAmount = null,Object? cardAmount = null,Object? createdAt = null,Object? updatedAt = null,Object? orderItems = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,shiftId: freezed == shiftId ? _self.shiftId : shiftId // ignore: cast_nullable_to_non_nullable
as String?,cashierId: null == cashierId ? _self.cashierId : cashierId // ignore: cast_nullable_to_non_nullable
as String,cashierName: freezed == cashierName ? _self.cashierName : cashierName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,tableLabel: freezed == tableLabel ? _self.tableLabel : tableLabel // ignore: cast_nullable_to_non_nullable
as String?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,tip: null == tip ? _self.tip : tip // ignore: cast_nullable_to_non_nullable
as double,cashAmount: null == cashAmount ? _self.cashAmount : cashAmount // ignore: cast_nullable_to_non_nullable
as double,cardAmount: null == cardAmount ? _self.cardAmount : cardAmount // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,orderItems: null == orderItems ? _self.orderItems : orderItems // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_id')  String shopId, @JsonKey(name: 'shift_id')  String? shiftId, @JsonKey(name: 'cashier_id')  String cashierId, @JsonKey(name: 'cashier_name')  String? cashierName,  OrderStatus status, @JsonKey(name: 'table_label')  String? tableLabel,  double total,  String? note, @JsonKey(name: 'payment_method')  String paymentMethod,  double tip, @JsonKey(name: 'cash_amount')  double cashAmount, @JsonKey(name: 'card_amount')  double cardAmount, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'order_items')  List<OrderItem> orderItems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.shopId,_that.shiftId,_that.cashierId,_that.cashierName,_that.status,_that.tableLabel,_that.total,_that.note,_that.paymentMethod,_that.tip,_that.cashAmount,_that.cardAmount,_that.createdAt,_that.updatedAt,_that.orderItems);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_id')  String shopId, @JsonKey(name: 'shift_id')  String? shiftId, @JsonKey(name: 'cashier_id')  String cashierId, @JsonKey(name: 'cashier_name')  String? cashierName,  OrderStatus status, @JsonKey(name: 'table_label')  String? tableLabel,  double total,  String? note, @JsonKey(name: 'payment_method')  String paymentMethod,  double tip, @JsonKey(name: 'cash_amount')  double cashAmount, @JsonKey(name: 'card_amount')  double cardAmount, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'order_items')  List<OrderItem> orderItems)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.shopId,_that.shiftId,_that.cashierId,_that.cashierName,_that.status,_that.tableLabel,_that.total,_that.note,_that.paymentMethod,_that.tip,_that.cashAmount,_that.cardAmount,_that.createdAt,_that.updatedAt,_that.orderItems);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'shop_id')  String shopId, @JsonKey(name: 'shift_id')  String? shiftId, @JsonKey(name: 'cashier_id')  String cashierId, @JsonKey(name: 'cashier_name')  String? cashierName,  OrderStatus status, @JsonKey(name: 'table_label')  String? tableLabel,  double total,  String? note, @JsonKey(name: 'payment_method')  String paymentMethod,  double tip, @JsonKey(name: 'cash_amount')  double cashAmount, @JsonKey(name: 'card_amount')  double cardAmount, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'order_items')  List<OrderItem> orderItems)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.shopId,_that.shiftId,_that.cashierId,_that.cashierName,_that.status,_that.tableLabel,_that.total,_that.note,_that.paymentMethod,_that.tip,_that.cashAmount,_that.cardAmount,_that.createdAt,_that.updatedAt,_that.orderItems);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Order implements Order {
  const _Order({required this.id, @JsonKey(name: 'shop_id') required this.shopId, @JsonKey(name: 'shift_id') this.shiftId, @JsonKey(name: 'cashier_id') required this.cashierId, @JsonKey(name: 'cashier_name') this.cashierName, required this.status, @JsonKey(name: 'table_label') this.tableLabel, required this.total, this.note, @JsonKey(name: 'payment_method') this.paymentMethod = 'cash', this.tip = 0.0, @JsonKey(name: 'cash_amount') this.cashAmount = 0.0, @JsonKey(name: 'card_amount') this.cardAmount = 0.0, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'order_items') final  List<OrderItem> orderItems = const []}): _orderItems = orderItems;
  factory _Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

@override final  String id;
@override@JsonKey(name: 'shop_id') final  String shopId;
@override@JsonKey(name: 'shift_id') final  String? shiftId;
@override@JsonKey(name: 'cashier_id') final  String cashierId;
@override@JsonKey(name: 'cashier_name') final  String? cashierName;
@override final  OrderStatus status;
@override@JsonKey(name: 'table_label') final  String? tableLabel;
@override final  double total;
@override final  String? note;
/// 'cash' | 'card' | 'split'  – kept for legacy reads; prefer cashAmount/cardAmount.
@override@JsonKey(name: 'payment_method') final  String paymentMethod;
@override@JsonKey() final  double tip;
/// Amount paid in cash (may be partial for split payments).
@override@JsonKey(name: 'cash_amount') final  double cashAmount;
/// Amount paid by card (may be partial for split payments).
@override@JsonKey(name: 'card_amount') final  double cardAmount;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
 final  List<OrderItem> _orderItems;
@override@JsonKey(name: 'order_items') List<OrderItem> get orderItems {
  if (_orderItems is EqualUnmodifiableListView) return _orderItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_orderItems);
}


/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.shiftId, shiftId) || other.shiftId == shiftId)&&(identical(other.cashierId, cashierId) || other.cashierId == cashierId)&&(identical(other.cashierName, cashierName) || other.cashierName == cashierName)&&(identical(other.status, status) || other.status == status)&&(identical(other.tableLabel, tableLabel) || other.tableLabel == tableLabel)&&(identical(other.total, total) || other.total == total)&&(identical(other.note, note) || other.note == note)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.tip, tip) || other.tip == tip)&&(identical(other.cashAmount, cashAmount) || other.cashAmount == cashAmount)&&(identical(other.cardAmount, cardAmount) || other.cardAmount == cardAmount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._orderItems, _orderItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,shiftId,cashierId,cashierName,status,tableLabel,total,note,paymentMethod,tip,cashAmount,cardAmount,createdAt,updatedAt,const DeepCollectionEquality().hash(_orderItems));

@override
String toString() {
  return 'Order(id: $id, shopId: $shopId, shiftId: $shiftId, cashierId: $cashierId, cashierName: $cashierName, status: $status, tableLabel: $tableLabel, total: $total, note: $note, paymentMethod: $paymentMethod, tip: $tip, cashAmount: $cashAmount, cardAmount: $cardAmount, createdAt: $createdAt, updatedAt: $updatedAt, orderItems: $orderItems)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'shop_id') String shopId,@JsonKey(name: 'shift_id') String? shiftId,@JsonKey(name: 'cashier_id') String cashierId,@JsonKey(name: 'cashier_name') String? cashierName, OrderStatus status,@JsonKey(name: 'table_label') String? tableLabel, double total, String? note,@JsonKey(name: 'payment_method') String paymentMethod, double tip,@JsonKey(name: 'cash_amount') double cashAmount,@JsonKey(name: 'card_amount') double cardAmount,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'order_items') List<OrderItem> orderItems
});




}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shopId = null,Object? shiftId = freezed,Object? cashierId = null,Object? cashierName = freezed,Object? status = null,Object? tableLabel = freezed,Object? total = null,Object? note = freezed,Object? paymentMethod = null,Object? tip = null,Object? cashAmount = null,Object? cardAmount = null,Object? createdAt = null,Object? updatedAt = null,Object? orderItems = null,}) {
  return _then(_Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,shiftId: freezed == shiftId ? _self.shiftId : shiftId // ignore: cast_nullable_to_non_nullable
as String?,cashierId: null == cashierId ? _self.cashierId : cashierId // ignore: cast_nullable_to_non_nullable
as String,cashierName: freezed == cashierName ? _self.cashierName : cashierName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,tableLabel: freezed == tableLabel ? _self.tableLabel : tableLabel // ignore: cast_nullable_to_non_nullable
as String?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,tip: null == tip ? _self.tip : tip // ignore: cast_nullable_to_non_nullable
as double,cashAmount: null == cashAmount ? _self.cashAmount : cashAmount // ignore: cast_nullable_to_non_nullable
as double,cardAmount: null == cardAmount ? _self.cardAmount : cardAmount // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,orderItems: null == orderItems ? _self._orderItems : orderItems // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,
  ));
}


}

// dart format on
