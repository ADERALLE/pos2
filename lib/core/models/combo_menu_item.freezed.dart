// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'combo_menu_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ComboMenuItem {

 String get id;@JsonKey(name: 'combo_menu_id') String get comboMenuId;@JsonKey(name: 'menu_item_id') String get menuItemId; int get quantity;/// When non-null, items sharing the same [choiceGroup] form a pick-one set.
/// The customer must choose exactly one item per group.
@JsonKey(name: 'choice_group') String? get choiceGroup;@JsonKey(name: 'menu_items') MenuItem? get menuItem;
/// Create a copy of ComboMenuItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComboMenuItemCopyWith<ComboMenuItem> get copyWith => _$ComboMenuItemCopyWithImpl<ComboMenuItem>(this as ComboMenuItem, _$identity);

  /// Serializes this ComboMenuItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComboMenuItem&&(identical(other.id, id) || other.id == id)&&(identical(other.comboMenuId, comboMenuId) || other.comboMenuId == comboMenuId)&&(identical(other.menuItemId, menuItemId) || other.menuItemId == menuItemId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.choiceGroup, choiceGroup) || other.choiceGroup == choiceGroup)&&(identical(other.menuItem, menuItem) || other.menuItem == menuItem));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,comboMenuId,menuItemId,quantity,choiceGroup,menuItem);

@override
String toString() {
  return 'ComboMenuItem(id: $id, comboMenuId: $comboMenuId, menuItemId: $menuItemId, quantity: $quantity, choiceGroup: $choiceGroup, menuItem: $menuItem)';
}


}

/// @nodoc
abstract mixin class $ComboMenuItemCopyWith<$Res>  {
  factory $ComboMenuItemCopyWith(ComboMenuItem value, $Res Function(ComboMenuItem) _then) = _$ComboMenuItemCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'combo_menu_id') String comboMenuId,@JsonKey(name: 'menu_item_id') String menuItemId, int quantity,@JsonKey(name: 'choice_group') String? choiceGroup,@JsonKey(name: 'menu_items') MenuItem? menuItem
});


$MenuItemCopyWith<$Res>? get menuItem;

}
/// @nodoc
class _$ComboMenuItemCopyWithImpl<$Res>
    implements $ComboMenuItemCopyWith<$Res> {
  _$ComboMenuItemCopyWithImpl(this._self, this._then);

  final ComboMenuItem _self;
  final $Res Function(ComboMenuItem) _then;

/// Create a copy of ComboMenuItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? comboMenuId = null,Object? menuItemId = null,Object? quantity = null,Object? choiceGroup = freezed,Object? menuItem = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,comboMenuId: null == comboMenuId ? _self.comboMenuId : comboMenuId // ignore: cast_nullable_to_non_nullable
as String,menuItemId: null == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,choiceGroup: freezed == choiceGroup ? _self.choiceGroup : choiceGroup // ignore: cast_nullable_to_non_nullable
as String?,menuItem: freezed == menuItem ? _self.menuItem : menuItem // ignore: cast_nullable_to_non_nullable
as MenuItem?,
  ));
}
/// Create a copy of ComboMenuItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MenuItemCopyWith<$Res>? get menuItem {
    if (_self.menuItem == null) {
    return null;
  }

  return $MenuItemCopyWith<$Res>(_self.menuItem!, (value) {
    return _then(_self.copyWith(menuItem: value));
  });
}
}


/// Adds pattern-matching-related methods to [ComboMenuItem].
extension ComboMenuItemPatterns on ComboMenuItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComboMenuItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComboMenuItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComboMenuItem value)  $default,){
final _that = this;
switch (_that) {
case _ComboMenuItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComboMenuItem value)?  $default,){
final _that = this;
switch (_that) {
case _ComboMenuItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'combo_menu_id')  String comboMenuId, @JsonKey(name: 'menu_item_id')  String menuItemId,  int quantity, @JsonKey(name: 'choice_group')  String? choiceGroup, @JsonKey(name: 'menu_items')  MenuItem? menuItem)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComboMenuItem() when $default != null:
return $default(_that.id,_that.comboMenuId,_that.menuItemId,_that.quantity,_that.choiceGroup,_that.menuItem);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'combo_menu_id')  String comboMenuId, @JsonKey(name: 'menu_item_id')  String menuItemId,  int quantity, @JsonKey(name: 'choice_group')  String? choiceGroup, @JsonKey(name: 'menu_items')  MenuItem? menuItem)  $default,) {final _that = this;
switch (_that) {
case _ComboMenuItem():
return $default(_that.id,_that.comboMenuId,_that.menuItemId,_that.quantity,_that.choiceGroup,_that.menuItem);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'combo_menu_id')  String comboMenuId, @JsonKey(name: 'menu_item_id')  String menuItemId,  int quantity, @JsonKey(name: 'choice_group')  String? choiceGroup, @JsonKey(name: 'menu_items')  MenuItem? menuItem)?  $default,) {final _that = this;
switch (_that) {
case _ComboMenuItem() when $default != null:
return $default(_that.id,_that.comboMenuId,_that.menuItemId,_that.quantity,_that.choiceGroup,_that.menuItem);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ComboMenuItem implements ComboMenuItem {
  const _ComboMenuItem({required this.id, @JsonKey(name: 'combo_menu_id') required this.comboMenuId, @JsonKey(name: 'menu_item_id') required this.menuItemId, this.quantity = 1, @JsonKey(name: 'choice_group') this.choiceGroup, @JsonKey(name: 'menu_items') this.menuItem});
  factory _ComboMenuItem.fromJson(Map<String, dynamic> json) => _$ComboMenuItemFromJson(json);

@override final  String id;
@override@JsonKey(name: 'combo_menu_id') final  String comboMenuId;
@override@JsonKey(name: 'menu_item_id') final  String menuItemId;
@override@JsonKey() final  int quantity;
/// When non-null, items sharing the same [choiceGroup] form a pick-one set.
/// The customer must choose exactly one item per group.
@override@JsonKey(name: 'choice_group') final  String? choiceGroup;
@override@JsonKey(name: 'menu_items') final  MenuItem? menuItem;

/// Create a copy of ComboMenuItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComboMenuItemCopyWith<_ComboMenuItem> get copyWith => __$ComboMenuItemCopyWithImpl<_ComboMenuItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComboMenuItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComboMenuItem&&(identical(other.id, id) || other.id == id)&&(identical(other.comboMenuId, comboMenuId) || other.comboMenuId == comboMenuId)&&(identical(other.menuItemId, menuItemId) || other.menuItemId == menuItemId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.choiceGroup, choiceGroup) || other.choiceGroup == choiceGroup)&&(identical(other.menuItem, menuItem) || other.menuItem == menuItem));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,comboMenuId,menuItemId,quantity,choiceGroup,menuItem);

@override
String toString() {
  return 'ComboMenuItem(id: $id, comboMenuId: $comboMenuId, menuItemId: $menuItemId, quantity: $quantity, choiceGroup: $choiceGroup, menuItem: $menuItem)';
}


}

/// @nodoc
abstract mixin class _$ComboMenuItemCopyWith<$Res> implements $ComboMenuItemCopyWith<$Res> {
  factory _$ComboMenuItemCopyWith(_ComboMenuItem value, $Res Function(_ComboMenuItem) _then) = __$ComboMenuItemCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'combo_menu_id') String comboMenuId,@JsonKey(name: 'menu_item_id') String menuItemId, int quantity,@JsonKey(name: 'choice_group') String? choiceGroup,@JsonKey(name: 'menu_items') MenuItem? menuItem
});


@override $MenuItemCopyWith<$Res>? get menuItem;

}
/// @nodoc
class __$ComboMenuItemCopyWithImpl<$Res>
    implements _$ComboMenuItemCopyWith<$Res> {
  __$ComboMenuItemCopyWithImpl(this._self, this._then);

  final _ComboMenuItem _self;
  final $Res Function(_ComboMenuItem) _then;

/// Create a copy of ComboMenuItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? comboMenuId = null,Object? menuItemId = null,Object? quantity = null,Object? choiceGroup = freezed,Object? menuItem = freezed,}) {
  return _then(_ComboMenuItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,comboMenuId: null == comboMenuId ? _self.comboMenuId : comboMenuId // ignore: cast_nullable_to_non_nullable
as String,menuItemId: null == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,choiceGroup: freezed == choiceGroup ? _self.choiceGroup : choiceGroup // ignore: cast_nullable_to_non_nullable
as String?,menuItem: freezed == menuItem ? _self.menuItem : menuItem // ignore: cast_nullable_to_non_nullable
as MenuItem?,
  ));
}

/// Create a copy of ComboMenuItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MenuItemCopyWith<$Res>? get menuItem {
    if (_self.menuItem == null) {
    return null;
  }

  return $MenuItemCopyWith<$Res>(_self.menuItem!, (value) {
    return _then(_self.copyWith(menuItem: value));
  });
}
}

// dart format on
