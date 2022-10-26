// GENERATED CODE - DO NOT MODIFY BY HAND

part of smoke_test.config_service.model.describe_configuration_recorder_status_response;

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DescribeConfigurationRecorderStatusResponse
    extends DescribeConfigurationRecorderStatusResponse {
  @override
  final _i3.BuiltList<_i2.ConfigurationRecorderStatus>?
      configurationRecordersStatus;

  factory _$DescribeConfigurationRecorderStatusResponse(
          [void Function(DescribeConfigurationRecorderStatusResponseBuilder)?
              updates]) =>
      (new DescribeConfigurationRecorderStatusResponseBuilder()
            ..update(updates))
          ._build();

  _$DescribeConfigurationRecorderStatusResponse._(
      {this.configurationRecordersStatus})
      : super._();

  @override
  DescribeConfigurationRecorderStatusResponse rebuild(
          void Function(DescribeConfigurationRecorderStatusResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DescribeConfigurationRecorderStatusResponseBuilder toBuilder() =>
      new DescribeConfigurationRecorderStatusResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DescribeConfigurationRecorderStatusResponse &&
        configurationRecordersStatus == other.configurationRecordersStatus;
  }

  @override
  int get hashCode {
    return $jf($jc(0, configurationRecordersStatus.hashCode));
  }
}

class DescribeConfigurationRecorderStatusResponseBuilder
    implements
        Builder<DescribeConfigurationRecorderStatusResponse,
            DescribeConfigurationRecorderStatusResponseBuilder> {
  _$DescribeConfigurationRecorderStatusResponse? _$v;

  _i3.ListBuilder<_i2.ConfigurationRecorderStatus>?
      _configurationRecordersStatus;
  _i3.ListBuilder<_i2.ConfigurationRecorderStatus>
      get configurationRecordersStatus =>
          _$this._configurationRecordersStatus ??=
              new _i3.ListBuilder<_i2.ConfigurationRecorderStatus>();
  set configurationRecordersStatus(
          _i3.ListBuilder<_i2.ConfigurationRecorderStatus>?
              configurationRecordersStatus) =>
      _$this._configurationRecordersStatus = configurationRecordersStatus;

  DescribeConfigurationRecorderStatusResponseBuilder() {
    DescribeConfigurationRecorderStatusResponse._init(this);
  }

  DescribeConfigurationRecorderStatusResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _configurationRecordersStatus =
          $v.configurationRecordersStatus?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DescribeConfigurationRecorderStatusResponse other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$DescribeConfigurationRecorderStatusResponse;
  }

  @override
  void update(
      void Function(DescribeConfigurationRecorderStatusResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  DescribeConfigurationRecorderStatusResponse build() => _build();

  _$DescribeConfigurationRecorderStatusResponse _build() {
    _$DescribeConfigurationRecorderStatusResponse _$result;
    try {
      _$result = _$v ??
          new _$DescribeConfigurationRecorderStatusResponse._(
              configurationRecordersStatus:
                  _configurationRecordersStatus?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'configurationRecordersStatus';
        _configurationRecordersStatus?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'DescribeConfigurationRecorderStatusResponse',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,no_leading_underscores_for_local_identifiers,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new,unnecessary_lambdas
