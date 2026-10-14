// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization_ref.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrganizationRef {

 String get id; String get name; String get type;@JsonKey(name: 'parent_id', required: true) String? get parentId;@JsonKey(name: 'tax_identification_number', required: true) String? get taxIdentificationNumber;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt; OrganizationRef? get parent;
/// Create a copy of OrganizationRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganizationRefCopyWith<OrganizationRef> get copyWith => _$OrganizationRefCopyWithImpl<OrganizationRef>(this as OrganizationRef, _$identity);

  /// Serializes this OrganizationRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OrganizationRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrganizationRef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.parentId, _this.parentId) || other.parentId == _this.parentId)&&(identical(other.taxIdentificationNumber, _this.taxIdentificationNumber) || other.taxIdentificationNumber == _this.taxIdentificationNumber)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.parent, _this.parent) || other.parent == _this.parent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OrganizationRef;
  return Object.hash(runtimeType,_this.id,_this.name,_this.type,_this.parentId,_this.taxIdentificationNumber,_this.createdAt,_this.updatedAt,_this.parent);
}

@override
String toString() {
  final _this = this as OrganizationRef;
  return 'OrganizationRef(id: ${_this.id}, name: ${_this.name}, type: ${_this.type}, parentId: ${_this.parentId}, taxIdentificationNumber: ${_this.taxIdentificationNumber}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, parent: ${_this.parent})';
}


}

/// @nodoc
abstract mixin class $OrganizationRefCopyWith<$Res>  {
  factory $OrganizationRefCopyWith(OrganizationRef value, $Res Function(OrganizationRef) _then) = _$OrganizationRefCopyWithImpl;
@useResult
$Res call({
 String id, String name, String type,@JsonKey(name: 'parent_id', required: true) String? parentId,@JsonKey(name: 'tax_identification_number', required: true) String? taxIdentificationNumber,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt, OrganizationRef? parent
});


$OrganizationRefCopyWith<$Res>? get parent;

}
/// @nodoc
class _$OrganizationRefCopyWithImpl<$Res>
    implements $OrganizationRefCopyWith<$Res> {
  _$OrganizationRefCopyWithImpl(this._self, this._then);

  final OrganizationRef _self;
  final $Res Function(OrganizationRef) _then;

/// Create a copy of OrganizationRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? parentId = freezed,Object? taxIdentificationNumber = freezed,Object? createdAt = null,Object? updatedAt = null,Object? parent = freezed,}) {
  return _then(OrganizationRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,taxIdentificationNumber: freezed == taxIdentificationNumber ? _self.taxIdentificationNumber : taxIdentificationNumber // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,parent: freezed == parent ? _self.parent : parent // ignore: cast_nullable_to_non_nullable
as OrganizationRef?,
  ));
}
/// Create a copy of OrganizationRef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrganizationRefCopyWith<$Res>? get parent {
    if (_self.parent == null) {
    return null;
  }

  return $OrganizationRefCopyWith<$Res>(_self.parent!, (value) {
    return _then(_self.copyWith(parent: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrganizationRef].
extension OrganizationRefPatterns on OrganizationRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrganizationRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrganizationRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrganizationRef value)  $default,){
final _that = this;
switch (_that) {
case _OrganizationRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrganizationRef value)?  $default,){
final _that = this;
switch (_that) {
case _OrganizationRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String type, @JsonKey(name: 'parent_id', required: true)  String? parentId, @JsonKey(name: 'tax_identification_number', required: true)  String? taxIdentificationNumber, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  OrganizationRef? parent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrganizationRef() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.parentId,_that.taxIdentificationNumber,_that.createdAt,_that.updatedAt,_that.parent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String type, @JsonKey(name: 'parent_id', required: true)  String? parentId, @JsonKey(name: 'tax_identification_number', required: true)  String? taxIdentificationNumber, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  OrganizationRef? parent)  $default,) {final _that = this;
switch (_that) {
case _OrganizationRef():
return $default(_that.id,_that.name,_that.type,_that.parentId,_that.taxIdentificationNumber,_that.createdAt,_that.updatedAt,_that.parent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String type, @JsonKey(name: 'parent_id', required: true)  String? parentId, @JsonKey(name: 'tax_identification_number', required: true)  String? taxIdentificationNumber, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  OrganizationRef? parent)?  $default,) {final _that = this;
switch (_that) {
case _OrganizationRef() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.parentId,_that.taxIdentificationNumber,_that.createdAt,_that.updatedAt,_that.parent);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true, explicitToJson: true)
class _OrganizationRef implements OrganizationRef {
  const _OrganizationRef({required this.id, required this.name, required this.type, @JsonKey(name: 'parent_id', required: true) this.parentId, @JsonKey(name: 'tax_identification_number', required: true) this.taxIdentificationNumber, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, this.parent});
  factory _OrganizationRef.fromJson(Map<String, dynamic> json) => _$OrganizationRefFromJson(json);

@override final  String id;
@override final  String name;
@override final  String type;
@override@JsonKey(name: 'parent_id', required: true) final  String? parentId;
@override@JsonKey(name: 'tax_identification_number', required: true) final  String? taxIdentificationNumber;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String updatedAt;
@override final  OrganizationRef? parent;

/// Create a copy of OrganizationRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrganizationRefCopyWith<_OrganizationRef> get copyWith => __$OrganizationRefCopyWithImpl<_OrganizationRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrganizationRefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrganizationRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.taxIdentificationNumber, taxIdentificationNumber) || other.taxIdentificationNumber == taxIdentificationNumber)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.parent, parent) || other.parent == parent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,type,parentId,taxIdentificationNumber,createdAt,updatedAt,parent);
}

@override
String toString() {
    return 'OrganizationRef(id: $id, name: $name, type: $type, parentId: $parentId, taxIdentificationNumber: $taxIdentificationNumber, createdAt: $createdAt, updatedAt: $updatedAt, parent: $parent)';
}


}

/// @nodoc
abstract mixin class _$OrganizationRefCopyWith<$Res> implements $OrganizationRefCopyWith<$Res> {
  factory _$OrganizationRefCopyWith(_OrganizationRef value, $Res Function(_OrganizationRef) _then) = __$OrganizationRefCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String type,@JsonKey(name: 'parent_id', required: true) String? parentId,@JsonKey(name: 'tax_identification_number', required: true) String? taxIdentificationNumber,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt, OrganizationRef? parent
});


@override $OrganizationRefCopyWith<$Res>? get parent;

}
/// @nodoc
class __$OrganizationRefCopyWithImpl<$Res>
    implements _$OrganizationRefCopyWith<$Res> {
  __$OrganizationRefCopyWithImpl(this._self, this._then);

  final _OrganizationRef _self;
  final $Res Function(_OrganizationRef) _then;

/// Create a copy of OrganizationRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? parentId = freezed,Object? taxIdentificationNumber = freezed,Object? createdAt = null,Object? updatedAt = null,Object? parent = freezed,}) {
  return _then(_OrganizationRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,taxIdentificationNumber: freezed == taxIdentificationNumber ? _self.taxIdentificationNumber : taxIdentificationNumber // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,parent: freezed == parent ? _self.parent : parent // ignore: cast_nullable_to_non_nullable
as OrganizationRef?,
  ));
}

/// Create a copy of OrganizationRef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrganizationRefCopyWith<$Res>? get parent {
    if (_self.parent == null) {
    return null;
  }

  return $OrganizationRefCopyWith<$Res>(_self.parent!, (value) {
    return _then(_self.copyWith(parent: value));
  });
}
}

// dart format on
