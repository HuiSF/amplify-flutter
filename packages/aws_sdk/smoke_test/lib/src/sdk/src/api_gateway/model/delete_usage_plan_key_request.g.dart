// GENERATED CODE - DO NOT MODIFY BY HAND

part of smoke_test.api_gateway.model.delete_usage_plan_key_request;

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeleteUsagePlanKeyRequest extends DeleteUsagePlanKeyRequest {
  @override
  final String keyId;
  @override
  final String usagePlanId;

  factory _$DeleteUsagePlanKeyRequest(
          [void Function(DeleteUsagePlanKeyRequestBuilder)? updates]) =>
      (new DeleteUsagePlanKeyRequestBuilder()..update(updates))._build();

  _$DeleteUsagePlanKeyRequest._(
      {required this.keyId, required this.usagePlanId})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        keyId, r'DeleteUsagePlanKeyRequest', 'keyId');
    BuiltValueNullFieldError.checkNotNull(
        usagePlanId, r'DeleteUsagePlanKeyRequest', 'usagePlanId');
  }

  @override
  DeleteUsagePlanKeyRequest rebuild(
          void Function(DeleteUsagePlanKeyRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeleteUsagePlanKeyRequestBuilder toBuilder() =>
      new DeleteUsagePlanKeyRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeleteUsagePlanKeyRequest &&
        keyId == other.keyId &&
        usagePlanId == other.usagePlanId;
  }

  @override
  int get hashCode {
    return $jf($jc($jc(0, keyId.hashCode), usagePlanId.hashCode));
  }
}

class DeleteUsagePlanKeyRequestBuilder
    implements
        Builder<DeleteUsagePlanKeyRequest, DeleteUsagePlanKeyRequestBuilder> {
  _$DeleteUsagePlanKeyRequest? _$v;

  String? _keyId;
  String? get keyId => _$this._keyId;
  set keyId(String? keyId) => _$this._keyId = keyId;

  String? _usagePlanId;
  String? get usagePlanId => _$this._usagePlanId;
  set usagePlanId(String? usagePlanId) => _$this._usagePlanId = usagePlanId;

  DeleteUsagePlanKeyRequestBuilder() {
    DeleteUsagePlanKeyRequest._init(this);
  }

  DeleteUsagePlanKeyRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _keyId = $v.keyId;
      _usagePlanId = $v.usagePlanId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeleteUsagePlanKeyRequest other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$DeleteUsagePlanKeyRequest;
  }

  @override
  void update(void Function(DeleteUsagePlanKeyRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeleteUsagePlanKeyRequest build() => _build();

  _$DeleteUsagePlanKeyRequest _build() {
    final _$result = _$v ??
        new _$DeleteUsagePlanKeyRequest._(
            keyId: BuiltValueNullFieldError.checkNotNull(
                keyId, r'DeleteUsagePlanKeyRequest', 'keyId'),
            usagePlanId: BuiltValueNullFieldError.checkNotNull(
                usagePlanId, r'DeleteUsagePlanKeyRequest', 'usagePlanId'));
    replace(_$result);
    return _$result;
  }
}

class _$DeleteUsagePlanKeyRequestPayload
    extends DeleteUsagePlanKeyRequestPayload {
  factory _$DeleteUsagePlanKeyRequestPayload(
          [void Function(DeleteUsagePlanKeyRequestPayloadBuilder)? updates]) =>
      (new DeleteUsagePlanKeyRequestPayloadBuilder()..update(updates))._build();

  _$DeleteUsagePlanKeyRequestPayload._() : super._();

  @override
  DeleteUsagePlanKeyRequestPayload rebuild(
          void Function(DeleteUsagePlanKeyRequestPayloadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeleteUsagePlanKeyRequestPayloadBuilder toBuilder() =>
      new DeleteUsagePlanKeyRequestPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeleteUsagePlanKeyRequestPayload;
  }

  @override
  int get hashCode {
    return 1005874204;
  }
}

class DeleteUsagePlanKeyRequestPayloadBuilder
    implements
        Builder<DeleteUsagePlanKeyRequestPayload,
            DeleteUsagePlanKeyRequestPayloadBuilder> {
  _$DeleteUsagePlanKeyRequestPayload? _$v;

  DeleteUsagePlanKeyRequestPayloadBuilder() {
    DeleteUsagePlanKeyRequestPayload._init(this);
  }

  @override
  void replace(DeleteUsagePlanKeyRequestPayload other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$DeleteUsagePlanKeyRequestPayload;
  }

  @override
  void update(void Function(DeleteUsagePlanKeyRequestPayloadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeleteUsagePlanKeyRequestPayload build() => _build();

  _$DeleteUsagePlanKeyRequestPayload _build() {
    final _$result = _$v ?? new _$DeleteUsagePlanKeyRequestPayload._();
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,no_leading_underscores_for_local_identifiers,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new,unnecessary_lambdas
