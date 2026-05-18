// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_recipe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InventoryRecipe {

 String get id;@JsonKey(name: 'shop_id') String get shopId;@JsonKey(name: 'menu_item_id') String get menuItemId;@JsonKey(name: 'inventory_item_id') String get inventoryItemId;@JsonKey(name: 'usage_value') double get usageValue;
/// Create a copy of InventoryRecipe
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryRecipeCopyWith<InventoryRecipe> get copyWith => _$InventoryRecipeCopyWithImpl<InventoryRecipe>(this as InventoryRecipe, _$identity);

  /// Serializes this InventoryRecipe to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryRecipe&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.menuItemId, menuItemId) || other.menuItemId == menuItemId)&&(identical(other.inventoryItemId, inventoryItemId) || other.inventoryItemId == inventoryItemId)&&(identical(other.usageValue, usageValue) || other.usageValue == usageValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,menuItemId,inventoryItemId,usageValue);

@override
String toString() {
  return 'InventoryRecipe(id: $id, shopId: $shopId, menuItemId: $menuItemId, inventoryItemId: $inventoryItemId, usageValue: $usageValue)';
}


}

/// @nodoc
abstract mixin class $InventoryRecipeCopyWith<$Res>  {
  factory $InventoryRecipeCopyWith(InventoryRecipe value, $Res Function(InventoryRecipe) _then) = _$InventoryRecipeCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'shop_id') String shopId,@JsonKey(name: 'menu_item_id') String menuItemId,@JsonKey(name: 'inventory_item_id') String inventoryItemId,@JsonKey(name: 'usage_value') double usageValue
});




}
/// @nodoc
class _$InventoryRecipeCopyWithImpl<$Res>
    implements $InventoryRecipeCopyWith<$Res> {
  _$InventoryRecipeCopyWithImpl(this._self, this._then);

  final InventoryRecipe _self;
  final $Res Function(InventoryRecipe) _then;

/// Create a copy of InventoryRecipe
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shopId = null,Object? menuItemId = null,Object? inventoryItemId = null,Object? usageValue = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,menuItemId: null == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String,inventoryItemId: null == inventoryItemId ? _self.inventoryItemId : inventoryItemId // ignore: cast_nullable_to_non_nullable
as String,usageValue: null == usageValue ? _self.usageValue : usageValue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [InventoryRecipe].
extension InventoryRecipePatterns on InventoryRecipe {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryRecipe value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryRecipe() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryRecipe value)  $default,){
final _that = this;
switch (_that) {
case _InventoryRecipe():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryRecipe value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryRecipe() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_id')  String shopId, @JsonKey(name: 'menu_item_id')  String menuItemId, @JsonKey(name: 'inventory_item_id')  String inventoryItemId, @JsonKey(name: 'usage_value')  double usageValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryRecipe() when $default != null:
return $default(_that.id,_that.shopId,_that.menuItemId,_that.inventoryItemId,_that.usageValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_id')  String shopId, @JsonKey(name: 'menu_item_id')  String menuItemId, @JsonKey(name: 'inventory_item_id')  String inventoryItemId, @JsonKey(name: 'usage_value')  double usageValue)  $default,) {final _that = this;
switch (_that) {
case _InventoryRecipe():
return $default(_that.id,_that.shopId,_that.menuItemId,_that.inventoryItemId,_that.usageValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'shop_id')  String shopId, @JsonKey(name: 'menu_item_id')  String menuItemId, @JsonKey(name: 'inventory_item_id')  String inventoryItemId, @JsonKey(name: 'usage_value')  double usageValue)?  $default,) {final _that = this;
switch (_that) {
case _InventoryRecipe() when $default != null:
return $default(_that.id,_that.shopId,_that.menuItemId,_that.inventoryItemId,_that.usageValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InventoryRecipe implements InventoryRecipe {
  const _InventoryRecipe({required this.id, @JsonKey(name: 'shop_id') required this.shopId, @JsonKey(name: 'menu_item_id') required this.menuItemId, @JsonKey(name: 'inventory_item_id') required this.inventoryItemId, @JsonKey(name: 'usage_value') required this.usageValue});
  factory _InventoryRecipe.fromJson(Map<String, dynamic> json) => _$InventoryRecipeFromJson(json);

@override final  String id;
@override@JsonKey(name: 'shop_id') final  String shopId;
@override@JsonKey(name: 'menu_item_id') final  String menuItemId;
@override@JsonKey(name: 'inventory_item_id') final  String inventoryItemId;
@override@JsonKey(name: 'usage_value') final  double usageValue;

/// Create a copy of InventoryRecipe
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryRecipeCopyWith<_InventoryRecipe> get copyWith => __$InventoryRecipeCopyWithImpl<_InventoryRecipe>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InventoryRecipeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryRecipe&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.menuItemId, menuItemId) || other.menuItemId == menuItemId)&&(identical(other.inventoryItemId, inventoryItemId) || other.inventoryItemId == inventoryItemId)&&(identical(other.usageValue, usageValue) || other.usageValue == usageValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,menuItemId,inventoryItemId,usageValue);

@override
String toString() {
  return 'InventoryRecipe(id: $id, shopId: $shopId, menuItemId: $menuItemId, inventoryItemId: $inventoryItemId, usageValue: $usageValue)';
}


}

/// @nodoc
abstract mixin class _$InventoryRecipeCopyWith<$Res> implements $InventoryRecipeCopyWith<$Res> {
  factory _$InventoryRecipeCopyWith(_InventoryRecipe value, $Res Function(_InventoryRecipe) _then) = __$InventoryRecipeCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'shop_id') String shopId,@JsonKey(name: 'menu_item_id') String menuItemId,@JsonKey(name: 'inventory_item_id') String inventoryItemId,@JsonKey(name: 'usage_value') double usageValue
});




}
/// @nodoc
class __$InventoryRecipeCopyWithImpl<$Res>
    implements _$InventoryRecipeCopyWith<$Res> {
  __$InventoryRecipeCopyWithImpl(this._self, this._then);

  final _InventoryRecipe _self;
  final $Res Function(_InventoryRecipe) _then;

/// Create a copy of InventoryRecipe
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shopId = null,Object? menuItemId = null,Object? inventoryItemId = null,Object? usageValue = null,}) {
  return _then(_InventoryRecipe(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,menuItemId: null == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String,inventoryItemId: null == inventoryItemId ? _self.inventoryItemId : inventoryItemId // ignore: cast_nullable_to_non_nullable
as String,usageValue: null == usageValue ? _self.usageValue : usageValue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
