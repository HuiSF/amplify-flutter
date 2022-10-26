// GENERATED CODE - DO NOT MODIFY BY HAND

part of smoke_test.config_service.model.aggregate_compliance_by_config_rule;

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AggregateComplianceByConfigRule
    extends AggregateComplianceByConfigRule {
  @override
  final String? accountId;
  @override
  final String? awsRegion;
  @override
  final _i2.Compliance? compliance;
  @override
  final String? configRuleName;

  factory _$AggregateComplianceByConfigRule(
          [void Function(AggregateComplianceByConfigRuleBuilder)? updates]) =>
      (new AggregateComplianceByConfigRuleBuilder()..update(updates))._build();

  _$AggregateComplianceByConfigRule._(
      {this.accountId, this.awsRegion, this.compliance, this.configRuleName})
      : super._();

  @override
  AggregateComplianceByConfigRule rebuild(
          void Function(AggregateComplianceByConfigRuleBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AggregateComplianceByConfigRuleBuilder toBuilder() =>
      new AggregateComplianceByConfigRuleBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AggregateComplianceByConfigRule &&
        accountId == other.accountId &&
        awsRegion == other.awsRegion &&
        compliance == other.compliance &&
        configRuleName == other.configRuleName;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc(0, accountId.hashCode), awsRegion.hashCode),
            compliance.hashCode),
        configRuleName.hashCode));
  }
}

class AggregateComplianceByConfigRuleBuilder
    implements
        Builder<AggregateComplianceByConfigRule,
            AggregateComplianceByConfigRuleBuilder> {
  _$AggregateComplianceByConfigRule? _$v;

  String? _accountId;
  String? get accountId => _$this._accountId;
  set accountId(String? accountId) => _$this._accountId = accountId;

  String? _awsRegion;
  String? get awsRegion => _$this._awsRegion;
  set awsRegion(String? awsRegion) => _$this._awsRegion = awsRegion;

  _i2.ComplianceBuilder? _compliance;
  _i2.ComplianceBuilder get compliance =>
      _$this._compliance ??= new _i2.ComplianceBuilder();
  set compliance(_i2.ComplianceBuilder? compliance) =>
      _$this._compliance = compliance;

  String? _configRuleName;
  String? get configRuleName => _$this._configRuleName;
  set configRuleName(String? configRuleName) =>
      _$this._configRuleName = configRuleName;

  AggregateComplianceByConfigRuleBuilder() {
    AggregateComplianceByConfigRule._init(this);
  }

  AggregateComplianceByConfigRuleBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accountId = $v.accountId;
      _awsRegion = $v.awsRegion;
      _compliance = $v.compliance?.toBuilder();
      _configRuleName = $v.configRuleName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AggregateComplianceByConfigRule other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$AggregateComplianceByConfigRule;
  }

  @override
  void update(void Function(AggregateComplianceByConfigRuleBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AggregateComplianceByConfigRule build() => _build();

  _$AggregateComplianceByConfigRule _build() {
    _$AggregateComplianceByConfigRule _$result;
    try {
      _$result = _$v ??
          new _$AggregateComplianceByConfigRule._(
              accountId: accountId,
              awsRegion: awsRegion,
              compliance: _compliance?.build(),
              configRuleName: configRuleName);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'compliance';
        _compliance?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'AggregateComplianceByConfigRule', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,no_leading_underscores_for_local_identifiers,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new,unnecessary_lambdas
