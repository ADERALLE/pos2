// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'combo_menu.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ComboMenu {

 String get id;@JsonKey(name: 'shop_id') String get shopId; String get name; String? get description; double get price;@JsonKey(name: 'image_url') String? get imageUrl;@JsonKey(name: 'category_id') String? get categoryId;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'sort_order') int get sortOrder;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;@JsonKey(name: 'combo_menu_items') List<ComboMenuItem> get comboMenuItems;
/// Create a copy of ComboMenu
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComboMenuCopyWith<ComboMenu> get copyWith => _$ComboMenuCopyWithImpl<ComboMenu>(this as ComboMenu, _$identity);

  /// Serializes this ComboMenu to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComboMenu&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.comboMenuItems, comboMenuItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,name,description,price,imageUrl,categoryId,isActive,sortOrder,createdAt,updatedAt,const DeepCollectionEquality().hash(comboMenuItems));

@override
String toString() {
  return 'ComboMenu(id: $id, shopId: $shopId, name: $name, description: $description, price: $price, imageUrl: $imageUrl, categoryId: $categoryId, isActive: $isActive, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt, comboMenuItems: $comboMenuItems)';
}


}

/// @nodoc
abstract mixin class $ComboMenuCopyWith<$Res>  {
  factory $ComboMenuCopyWith(ComboMenu value, $Res Function(ComboMenu) _then) = _$ComboMenuCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'shop_id') String shopId, String name, String? description, double price,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'category_id') String? categoryId,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'combo_menu_items') List<ComboMenuItem> comboMenuItems
});




}
/// @nodoc
class _$ComboMenuCopyWithImpl<$Res>
    implements $ComboMenuCopyWith<$Res> {
  _$ComboMenuCopyWithImpl(this._self, this._then);

  final ComboMenu _self;
  final $Res Function(ComboMenu) _then;

/// Create a copy of ComboMenu
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shopId = null,Object? name = null,Object? description = freezed,Object? price = null,Object? imageUrl = freezed,Object? categoryId = freezed,Object? isActive = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,Object? comboMenuItems = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,comboMenuItems: null == comboMenuItems ? _self.comboMenuItems : comboMenuItems // ignore: cast_nullable_to_non_nullable
as List<ComboMenuItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [ComboMenu].
extension ComboMenuPatterns on ComboMenu {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComboMenu value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComboMenu() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComboMenu value)  $default,){
final _that = this;
switch (_that) {
case _ComboMenu():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComboMenu value)?  $default,){
final _that = this;
switch (_that) {
case _ComboMenu() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_id')  String shopId,  String name,  String? description,  double price, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'category_id')  String? categoryId, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'combo_menu_items')  List<ComboMenuItem> comboMenuItems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComboMenu() when $default != null:
return $default(_that.id,_that.shopId,_that.name,_that.description,_that.price,_that.imageUrl,_that.categoryId,_that.isActive,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.comboMenuItems);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_id')  String shopId,  String name,  String? description,  double price, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'category_id')  String? categoryId, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'combo_menu_items')  List<ComboMenuItem> comboMenuItems)  $default,) {final _that = this;
switch (_that) {
case _ComboMenu():
return $default(_that.id,_that.shopId,_that.name,_that.description,_that.price,_that.imageUrl,_that.categoryId,_that.isActive,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.comboMenuItems);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'shop_id')  String shopId,  String name,  String? description,  double price, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'category_id')  String? categoryId, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'combo_menu_items')  List<ComboMenuItem> comboMenuItems)?  $default,) {final _that = this;
switch (_that) {
case _ComboMenu() when $default != null:
return $default(_that.id,_that.shopId,_that.name,_that.description,_that.price,_that.imageUrl,_that.categoryId,_that.isActive,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.comboMenuItems);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ComboMenu implements ComboMenu {
  const _ComboMenu({required this.id, @JsonKey(name: 'shop_id') required this.shopId, required this.name, this.description, required this.price, @JsonKey(name: 'image_url') this.imageUrl, @JsonKey(name: 'category_id') this.categoryId, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'sort_order') this.sortOrder = 0, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'combo_menu_items') final  List<ComboMenuItem> comboMenuItems = const []}): _comboMenuItems = comboMenuItems;
  factory _ComboMenu.fromJson(Map<String, dynamic> json) => _$ComboMenuFromJson(json);

@override final  String id;
@override@JsonKey(name: 'shop_id') final  String shopId;
@override final  String name;
@override final  String? description;
@override final  double price;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
@override@JsonKey(name: 'category_id') final  String? categoryId;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'sort_order') final  int sortOrder;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
 final  List<ComboMenuItem> _comboMenuItems;
@override@JsonKey(name: 'combo_menu_items') List<ComboMenuItem> get comboMenuItems {
  if (_comboMenuItems is EqualUnmodifiableListView) return _comboMenuItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_comboMenuItems);
}


/// Create a copy of ComboMenu
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComboMenuCopyWith<_ComboMenu> get copyWith => __$ComboMenuCopyWithImpl<_ComboMenu>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComboMenuToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComboMenu&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._comboMenuItems, _comboMenuItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,name,description,price,imageUrl,categoryId,isActive,sortOrder,createdAt,updatedAt,const DeepCollectionEquality().hash(_comboMenuItems));

@override
String toString() {
  return 'ComboMenu(id: $id, shopId: $shopId, name: $name, description: $description, price: $price, imageUrl: $imageUrl, categoryId: $categoryId, isActive: $isActive, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt, comboMenuItems: $comboMenuItems)';
}


}

/// @nodoc
abstract mixin class _$ComboMenuCopyWith<$Res> implements $ComboMenuCopyWith<$Res> {
  factory _$ComboMenuCopyWith(_ComboMenu value, $Res Function(_ComboMenu) _then) = __$ComboMenuCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'shop_id') String shopId, String name, String? description, double price,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'category_id') String? categoryId,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'combo_menu_items') List<ComboMenuItem> comboMenuItems
});




}
/// @nodoc
class __$ComboMenuCopyWithImpl<$Res>
    implements _$ComboMenuCopyWith<$Res> {
  __$ComboMenuCopyWithImpl(this._self, this._then);

  final _ComboMenu _self;
  final $Res Function(_ComboMenu) _then;

/// Create a copy of ComboMenu
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shopId = null,Object? name = null,Object? description = freezed,Object? price = null,Object? imageUrl = freezed,Object? categoryId = freezed,Object? isActive = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,Object? comboMenuItems = null,}) {
  return _then(_ComboMenu(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,comboMenuItems: null == comboMenuItems ? _self._comboMenuItems : comboMenuItems // ignore: cast_nullable_to_non_nullable
as List<ComboMenuItem>,
  ));
}


}

// dart format on
