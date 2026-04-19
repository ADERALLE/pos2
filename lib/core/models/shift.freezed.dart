// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shift.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Shift {
  String get id;
  @JsonKey(name: 'shop_id')
  String get shopId;
  @JsonKey(name: 'staff_id')
  String get staffId;
  @JsonKey(name: 'opened_at')
  DateTime get openedAt;
  @JsonKey(name: 'closed_at')
  DateTime? get closedAt;
  @JsonKey(name: 'rotation_amount')
  double get rotationAmount;
  @JsonKey(name: 'opening_note')
  String? get openingNote;
  @JsonKey(name: 'closing_note')
  String? get closingNote;

  /// Create a copy of Shift
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ShiftCopyWith<Shift> get copyWith =>
      _$ShiftCopyWithImpl<Shift>(this as Shift, _$identity);

  /// Serializes this Shift to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Shift &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.shopId, shopId) || other.shopId == shopId) &&
            (identical(other.staffId, staffId) || other.staffId == staffId) &&
            (identical(other.openedAt, openedAt) ||
                other.openedAt == openedAt) &&
            (identical(other.closedAt, closedAt) ||
                other.closedAt == closedAt) &&
            (identical(other.rotationAmount, rotationAmount) ||
                other.rotationAmount == rotationAmount) &&
            (identical(other.openingNote, openingNote) ||
                other.openingNote == openingNote) &&
            (identical(other.closingNote, closingNote) ||
                other.closingNote == closingNote));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, shopId, staffId, openedAt,
      closedAt, rotationAmount, openingNote, closingNote);

  @override
  String toString() {
    return 'Shift(id: $id, shopId: $shopId, staffId: $staffId, openedAt: $openedAt, closedAt: $closedAt, rotationAmount: $rotationAmount, openingNote: $openingNote, closingNote: $closingNote)';
  }
}

/// @nodoc
abstract mixin class $ShiftCopyWith<$Res> {
  factory $ShiftCopyWith(Shift value, $Res Function(Shift) _then) =
      _$ShiftCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'shop_id') String shopId,
      @JsonKey(name: 'staff_id') String staffId,
      @JsonKey(name: 'opened_at') DateTime openedAt,
      @JsonKey(name: 'closed_at') DateTime? closedAt,
      @JsonKey(name: 'rotation_amount') double rotationAmount,
      @JsonKey(name: 'opening_note') String? openingNote,
      @JsonKey(name: 'closing_note') String? closingNote});
}

/// @nodoc
class _$ShiftCopyWithImpl<$Res> implements $ShiftCopyWith<$Res> {
  _$ShiftCopyWithImpl(this._self, this._then);

  final Shift _self;
  final $Res Function(Shift) _then;

  /// Create a copy of Shift
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? shopId = null,
    Object? staffId = null,
    Object? openedAt = null,
    Object? closedAt = freezed,
    Object? rotationAmount = null,
    Object? openingNote = freezed,
    Object? closingNote = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      shopId: null == shopId
          ? _self.shopId
          : shopId // ignore: cast_nullable_to_non_nullable
              as String,
      staffId: null == staffId
          ? _self.staffId
          : staffId // ignore: cast_nullable_to_non_nullable
              as String,
      openedAt: null == openedAt
          ? _self.openedAt
          : openedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      closedAt: freezed == closedAt
          ? _self.closedAt
          : closedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rotationAmount: null == rotationAmount
          ? _self.rotationAmount
          : rotationAmount // ignore: cast_nullable_to_non_nullable
              as double,
      openingNote: freezed == openingNote
          ? _self.openingNote
          : openingNote // ignore: cast_nullable_to_non_nullable
              as String?,
      closingNote: freezed == closingNote
          ? _self.closingNote
          : closingNote // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Shift].
extension ShiftPatterns on Shift {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Shift value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Shift() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Shift value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Shift():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Shift value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Shift() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            @JsonKey(name: 'shop_id') String shopId,
            @JsonKey(name: 'staff_id') String staffId,
            @JsonKey(name: 'opened_at') DateTime openedAt,
            @JsonKey(name: 'closed_at') DateTime? closedAt,
            @JsonKey(name: 'rotation_amount') double rotationAmount,
            @JsonKey(name: 'opening_note') String? openingNote,
            @JsonKey(name: 'closing_note') String? closingNote)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Shift() when $default != null:
        return $default(
            _that.id,
            _that.shopId,
            _that.staffId,
            _that.openedAt,
            _that.closedAt,
            _that.rotationAmount,
            _that.openingNote,
            _that.closingNote);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            @JsonKey(name: 'shop_id') String shopId,
            @JsonKey(name: 'staff_id') String staffId,
            @JsonKey(name: 'opened_at') DateTime openedAt,
            @JsonKey(name: 'closed_at') DateTime? closedAt,
            @JsonKey(name: 'rotation_amount') double rotationAmount,
            @JsonKey(name: 'opening_note') String? openingNote,
            @JsonKey(name: 'closing_note') String? closingNote)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Shift():
        return $default(
            _that.id,
            _that.shopId,
            _that.staffId,
            _that.openedAt,
            _that.closedAt,
            _that.rotationAmount,
            _that.openingNote,
            _that.closingNote);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            @JsonKey(name: 'shop_id') String shopId,
            @JsonKey(name: 'staff_id') String staffId,
            @JsonKey(name: 'opened_at') DateTime openedAt,
            @JsonKey(name: 'closed_at') DateTime? closedAt,
            @JsonKey(name: 'rotation_amount') double rotationAmount,
            @JsonKey(name: 'opening_note') String? openingNote,
            @JsonKey(name: 'closing_note') String? closingNote)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Shift() when $default != null:
        return $default(
            _that.id,
            _that.shopId,
            _that.staffId,
            _that.openedAt,
            _that.closedAt,
            _that.rotationAmount,
            _that.openingNote,
            _that.closingNote);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Shift implements Shift {
  const _Shift(
      {required this.id,
      @JsonKey(name: 'shop_id') required this.shopId,
      @JsonKey(name: 'staff_id') required this.staffId,
      @JsonKey(name: 'opened_at') required this.openedAt,
      @JsonKey(name: 'closed_at') this.closedAt,
      @JsonKey(name: 'rotation_amount') this.rotationAmount = 0.0,
      @JsonKey(name: 'opening_note') this.openingNote,
      @JsonKey(name: 'closing_note') this.closingNote});
  factory _Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'shop_id')
  final String shopId;
  @override
  @JsonKey(name: 'staff_id')
  final String staffId;
  @override
  @JsonKey(name: 'opened_at')
  final DateTime openedAt;
  @override
  @JsonKey(name: 'closed_at')
  final DateTime? closedAt;
  @override
  @JsonKey(name: 'rotation_amount')
  final double rotationAmount;
  @override
  @JsonKey(name: 'opening_note')
  final String? openingNote;
  @override
  @JsonKey(name: 'closing_note')
  final String? closingNote;

  /// Create a copy of Shift
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ShiftCopyWith<_Shift> get copyWith =>
      __$ShiftCopyWithImpl<_Shift>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ShiftToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Shift &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.shopId, shopId) || other.shopId == shopId) &&
            (identical(other.staffId, staffId) || other.staffId == staffId) &&
            (identical(other.openedAt, openedAt) ||
                other.openedAt == openedAt) &&
            (identical(other.closedAt, closedAt) ||
                other.closedAt == closedAt) &&
            (identical(other.rotationAmount, rotationAmount) ||
                other.rotationAmount == rotationAmount) &&
            (identical(other.openingNote, openingNote) ||
                other.openingNote == openingNote) &&
            (identical(other.closingNote, closingNote) ||
                other.closingNote == closingNote));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, shopId, staffId, openedAt,
      closedAt, rotationAmount, openingNote, closingNote);

  @override
  String toString() {
    return 'Shift(id: $id, shopId: $shopId, staffId: $staffId, openedAt: $openedAt, closedAt: $closedAt, rotationAmount: $rotationAmount, openingNote: $openingNote, closingNote: $closingNote)';
  }
}

/// @nodoc
abstract mixin class _$ShiftCopyWith<$Res> implements $ShiftCopyWith<$Res> {
  factory _$ShiftCopyWith(_Shift value, $Res Function(_Shift) _then) =
      __$ShiftCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'shop_id') String shopId,
      @JsonKey(name: 'staff_id') String staffId,
      @JsonKey(name: 'opened_at') DateTime openedAt,
      @JsonKey(name: 'closed_at') DateTime? closedAt,
      @JsonKey(name: 'rotation_amount') double rotationAmount,
      @JsonKey(name: 'opening_note') String? openingNote,
      @JsonKey(name: 'closing_note') String? closingNote});
}

/// @nodoc
class __$ShiftCopyWithImpl<$Res> implements _$ShiftCopyWith<$Res> {
  __$ShiftCopyWithImpl(this._self, this._then);

  final _Shift _self;
  final $Res Function(_Shift) _then;

  /// Create a copy of Shift
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? shopId = null,
    Object? staffId = null,
    Object? openedAt = null,
    Object? closedAt = freezed,
    Object? rotationAmount = null,
    Object? openingNote = freezed,
    Object? closingNote = freezed,
  }) {
    return _then(_Shift(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      shopId: null == shopId
          ? _self.shopId
          : shopId // ignore: cast_nullable_to_non_nullable
              as String,
      staffId: null == staffId
          ? _self.staffId
          : staffId // ignore: cast_nullable_to_non_nullable
              as String,
      openedAt: null == openedAt
          ? _self.openedAt
          : openedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      closedAt: freezed == closedAt
          ? _self.closedAt
          : closedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rotationAmount: null == rotationAmount
          ? _self.rotationAmount
          : rotationAmount // ignore: cast_nullable_to_non_nullable
              as double,
      openingNote: freezed == openingNote
          ? _self.openingNote
          : openingNote // ignore: cast_nullable_to_non_nullable
              as String?,
      closingNote: freezed == closingNote
          ? _self.closingNote
          : closingNote // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
