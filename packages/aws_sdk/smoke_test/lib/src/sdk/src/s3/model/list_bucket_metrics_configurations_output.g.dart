// GENERATED CODE - DO NOT MODIFY BY HAND

part of smoke_test.s3.model.list_bucket_metrics_configurations_output;

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ListBucketMetricsConfigurationsOutput
    extends ListBucketMetricsConfigurationsOutput {
  @override
  final String? continuationToken;
  @override
  final bool? isTruncated;
  @override
  final _i3.BuiltList<_i2.MetricsConfiguration>? metricsConfigurationList;
  @override
  final String? nextContinuationToken;

  factory _$ListBucketMetricsConfigurationsOutput(
          [void Function(ListBucketMetricsConfigurationsOutputBuilder)?
              updates]) =>
      (new ListBucketMetricsConfigurationsOutputBuilder()..update(updates))
          ._build();

  _$ListBucketMetricsConfigurationsOutput._(
      {this.continuationToken,
      this.isTruncated,
      this.metricsConfigurationList,
      this.nextContinuationToken})
      : super._();

  @override
  ListBucketMetricsConfigurationsOutput rebuild(
          void Function(ListBucketMetricsConfigurationsOutputBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ListBucketMetricsConfigurationsOutputBuilder toBuilder() =>
      new ListBucketMetricsConfigurationsOutputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListBucketMetricsConfigurationsOutput &&
        continuationToken == other.continuationToken &&
        isTruncated == other.isTruncated &&
        metricsConfigurationList == other.metricsConfigurationList &&
        nextContinuationToken == other.nextContinuationToken;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc(0, continuationToken.hashCode), isTruncated.hashCode),
            metricsConfigurationList.hashCode),
        nextContinuationToken.hashCode));
  }
}

class ListBucketMetricsConfigurationsOutputBuilder
    implements
        Builder<ListBucketMetricsConfigurationsOutput,
            ListBucketMetricsConfigurationsOutputBuilder> {
  _$ListBucketMetricsConfigurationsOutput? _$v;

  String? _continuationToken;
  String? get continuationToken => _$this._continuationToken;
  set continuationToken(String? continuationToken) =>
      _$this._continuationToken = continuationToken;

  bool? _isTruncated;
  bool? get isTruncated => _$this._isTruncated;
  set isTruncated(bool? isTruncated) => _$this._isTruncated = isTruncated;

  _i3.ListBuilder<_i2.MetricsConfiguration>? _metricsConfigurationList;
  _i3.ListBuilder<_i2.MetricsConfiguration> get metricsConfigurationList =>
      _$this._metricsConfigurationList ??=
          new _i3.ListBuilder<_i2.MetricsConfiguration>();
  set metricsConfigurationList(
          _i3.ListBuilder<_i2.MetricsConfiguration>?
              metricsConfigurationList) =>
      _$this._metricsConfigurationList = metricsConfigurationList;

  String? _nextContinuationToken;
  String? get nextContinuationToken => _$this._nextContinuationToken;
  set nextContinuationToken(String? nextContinuationToken) =>
      _$this._nextContinuationToken = nextContinuationToken;

  ListBucketMetricsConfigurationsOutputBuilder() {
    ListBucketMetricsConfigurationsOutput._init(this);
  }

  ListBucketMetricsConfigurationsOutputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _continuationToken = $v.continuationToken;
      _isTruncated = $v.isTruncated;
      _metricsConfigurationList = $v.metricsConfigurationList?.toBuilder();
      _nextContinuationToken = $v.nextContinuationToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ListBucketMetricsConfigurationsOutput other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ListBucketMetricsConfigurationsOutput;
  }

  @override
  void update(
      void Function(ListBucketMetricsConfigurationsOutputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ListBucketMetricsConfigurationsOutput build() => _build();

  _$ListBucketMetricsConfigurationsOutput _build() {
    _$ListBucketMetricsConfigurationsOutput _$result;
    try {
      _$result = _$v ??
          new _$ListBucketMetricsConfigurationsOutput._(
              continuationToken: continuationToken,
              isTruncated: isTruncated,
              metricsConfigurationList: _metricsConfigurationList?.build(),
              nextContinuationToken: nextContinuationToken);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'metricsConfigurationList';
        _metricsConfigurationList?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'ListBucketMetricsConfigurationsOutput',
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
