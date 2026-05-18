// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InventoryItem {

 String get id;@JsonKey(name: 'shop_id') String get shopId; String get label;@JsonKey(name: 'unit_type') String get unitType;@JsonKey(name: 'current_stock') double get currentStock;@JsonKey(name: 'stop_orders_on_empty') bool get stopOrdersOnEmpty;@JsonKey(name: 'low_stock_threshold') double? get lowStockThreshold;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of InventoryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryItemCopyWith<InventoryItem> get copyWith => _$InventoryItemCopyWithImpl<InventoryItem>(this as InventoryItem, _$identity);

  /// Serializes this InventoryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.label, label) || other.label == label)&&(identical(other.unitType, unitType) || other.unitType == unitType)&&(identical(other.currentStock, currentStock) || other.currentStock == currentStock)&&(identical(other.stopOrdersOnEmpty, stopOrdersOnEmpty) || other.stopOrdersOnEmpty == stopOrdersOnEmpty)&&(identical(other.lowStockThreshold, lowStockThreshold) || other.lowStockThreshold == lowStockThreshold)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,label,unitType,currentStock,stopOrdersOnEmpty,lowStockThreshold,createdAt);

@override
String toString() {
  return 'InventoryItem(id: $id, shopId: $shopId, label: $label, unitType: $unitType, currentStock: $currentStock, stopOrdersOnEmpty: $stopOrdersOnEmpty, lowStockThreshold: $lowStockThreshold, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $InventoryItemCopyWith<$Res>  {
  factory $InventoryItemCopyWith(InventoryItem value, $Res Function(InventoryItem) _then) = _$InventoryItemCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'shop_id') String shopId, String label,@JsonKey(name: 'unit_type') String unitType,@JsonKey(name: 'current_stock') double currentStock,@JsonKey(name: 'stop_orders_on_empty') bool stopOrdersOnEmpty,@JsonKey(name: 'low_stock_threshold') double? lowStockThreshold,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$InventoryItemCopyWithImpl<$Res>
    implements $InventoryItemCopyWith<$Res> {
  _$InventoryItemCopyWithImpl(this._self, this._then);

  final InventoryItem _self;
  final $Res Function(InventoryItem) _then;

/// Create a copy of InventoryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shopId = null,Object? label = null,Object? unitType = null,Object? currentStock = null,Object? stopOrdersOnEmpty = null,Object? lowStockThreshold = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,unitType: null == unitType ? _self.unitType : unitType // ignore: cast_nullable_to_non_nullable
as String,currentStock: null == currentStock ? _self.currentStock : currentStock // ignore: cast_nullable_to_non_nullable
as double,stopOrdersOnEmpty: null == stopOrdersOnEmpty ? _self.stopOrdersOnEmpty : stopOrdersOnEmpty // ignore: cast_nullable_to_non_nullable
as bool,lowStockThreshold: freezed == lowStockThreshold ? _self.lowStockThreshold : lowStockThreshold // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryItem].
extension InventoryItemPatterns on InventoryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryItem value)  $default,){
final _that = this;
switch (_that) {
case _InventoryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryItem value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_id')  String shopId,  String label, @JsonKey(name: 'unit_type')  String unitType, @JsonKey(name: 'current_stock')  double currentStock, @JsonKey(name: 'stop_orders_on_empty')  bool stopOrdersOnEmpty, @JsonKey(name: 'low_stock_threshold')  double? lowStockThreshold, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryItem() when $default != null:
return $default(_that.id,_that.shopId,_that.label,_that.unitType,_that.currentStock,_that.stopOrdersOnEmpty,_that.lowStockThreshold,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_id')  String shopId,  String label, @JsonKey(name: 'unit_type')  String unitType, @JsonKey(name: 'current_stock')  double currentStock, @JsonKey(name: 'stop_orders_on_empty')  bool stopOrdersOnEmpty, @JsonKey(name: 'low_stock_threshold')  double? lowStockThreshold, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _InventoryItem():
return $default(_that.id,_that.shopId,_that.label,_that.unitType,_that.currentStock,_that.stopOrdersOnEmpty,_that.lowStockThreshold,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'shop_id')  String shopId,  String label, @JsonKey(name: 'unit_type')  String unitType, @JsonKey(name: 'current_stock')  double currentStock, @JsonKey(name: 'stop_orders_on_empty')  bool stopOrdersOnEmpty, @JsonKey(name: 'low_stock_threshold')  double? lowStockThreshold, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _InventoryItem() when $default != null:
return $default(_that.id,_that.shopId,_that.label,_that.unitType,_that.currentStock,_that.stopOrdersOnEmpty,_that.lowStockThreshold,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InventoryItem implements InventoryItem {
  const _InventoryItem({required this.id, @JsonKey(name: 'shop_id') required this.shopId, required this.label, @JsonKey(name: 'unit_type') required this.unitType, @JsonKey(name: 'current_stock') required this.currentStock, @JsonKey(name: 'stop_orders_on_empty') required this.stopOrdersOnEmpty, @JsonKey(name: 'low_stock_threshold') this.lowStockThreshold, @JsonKey(name: 'created_at') required this.createdAt});
  factory _InventoryItem.fromJson(Map<String, dynamic> json) => _$InventoryItemFromJson(json);

@override final  String id;
@override@JsonKey(name: 'shop_id') final  String shopId;
@override final  String label;
@override@JsonKey(name: 'unit_type') final  String unitType;
@override@JsonKey(name: 'current_stock') final  double currentStock;
@override@JsonKey(name: 'stop_orders_on_empty') final  bool stopOrdersOnEmpty;
@override@JsonKey(name: 'low_stock_threshold') final  double? lowStockThreshold;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of InventoryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryItemCopyWith<_InventoryItem> get copyWith => __$InventoryItemCopyWithImpl<_InventoryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InventoryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.label, label) || other.label == label)&&(identical(other.unitType, unitType) || other.unitType == unitType)&&(identical(other.currentStock, currentStock) || other.currentStock == currentStock)&&(identical(other.stopOrdersOnEmpty, stopOrdersOnEmpty) || other.stopOrdersOnEmpty == stopOrdersOnEmpty)&&(identical(other.lowStockThreshold, lowStockThreshold) || other.lowStockThreshold == lowStockThreshold)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,label,unitType,currentStock,stopOrdersOnEmpty,lowStockThreshold,createdAt);

@override
String toString() {
  return 'InventoryItem(id: $id, shopId: $shopId, label: $label, unitType: $unitType, currentStock: $currentStock, stopOrdersOnEmpty: $stopOrdersOnEmpty, lowStockThreshold: $lowStockThreshold, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$InventoryItemCopyWith<$Res> implements $InventoryItemCopyWith<$Res> {
  factory _$InventoryItemCopyWith(_InventoryItem value, $Res Function(_InventoryItem) _then) = __$InventoryItemCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'shop_id') String shopId, String label,@JsonKey(name: 'unit_type') String unitType,@JsonKey(name: 'current_stock') double currentStock,@JsonKey(name: 'stop_orders_on_empty') bool stopOrdersOnEmpty,@JsonKey(name: 'low_stock_threshold') double? lowStockThreshold,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$InventoryItemCopyWithImpl<$Res>
    implements _$InventoryItemCopyWith<$Res> {
  __$InventoryItemCopyWithImpl(this._self, this._then);

  final _InventoryItem _self;
  final $Res Function(_InventoryItem) _then;

/// Create a copy of InventoryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shopId = null,Object? label = null,Object? unitType = null,Object? currentStock = null,Object? stopOrdersOnEmpty = null,Object? lowStockThreshold = freezed,Object? createdAt = null,}) {
  return _then(_InventoryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,unitType: null == unitType ? _self.unitType : unitType // ignore: cast_nullable_to_non_nullable
as String,currentStock: null == currentStock ? _self.currentStock : currentStock // ignore: cast_nullable_to_non_nullable
as double,stopOrdersOnEmpty: null == stopOrdersOnEmpty ? _self.stopOrdersOnEmpty : stopOrdersOnEmpty // ignore: cast_nullable_to_non_nullable
as bool,lowStockThreshold: freezed == lowStockThreshold ? _self.lowStockThreshold : lowStockThreshold // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
