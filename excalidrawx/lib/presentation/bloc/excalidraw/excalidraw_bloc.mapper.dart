// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'excalidraw_bloc.dart';

class ExcalidrawStateMapper extends ClassMapperBase<ExcalidrawState> {
  ExcalidrawStateMapper._();

  static ExcalidrawStateMapper? _instance;
  static ExcalidrawStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ExcalidrawStateMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ExcalidrawState';

  static ExcalidrawStatus _$status(ExcalidrawState v) => v.status;
  static const Field<ExcalidrawState, ExcalidrawStatus> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: ExcalidrawStatus.initial,
  );
  static String? _$errorMessage(ExcalidrawState v) => v.errorMessage;
  static const Field<ExcalidrawState, String> _f$errorMessage = Field(
    'errorMessage',
    _$errorMessage,
    opt: true,
  );
  static List<dynamic>? _$elements(ExcalidrawState v) => v.elements;
  static const Field<ExcalidrawState, List<dynamic>> _f$elements = Field(
    'elements',
    _$elements,
    opt: true,
  );

  @override
  final MappableFields<ExcalidrawState> fields = const {
    #status: _f$status,
    #errorMessage: _f$errorMessage,
    #elements: _f$elements,
  };

  static ExcalidrawState _instantiate(DecodingData data) {
    return ExcalidrawState(
      status: data.dec(_f$status),
      errorMessage: data.dec(_f$errorMessage),
      elements: data.dec(_f$elements),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ExcalidrawState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ExcalidrawState>(map);
  }

  static ExcalidrawState fromJson(String json) {
    return ensureInitialized().decodeJson<ExcalidrawState>(json);
  }
}

mixin ExcalidrawStateMappable {
  String toJson() {
    return ExcalidrawStateMapper.ensureInitialized()
        .encodeJson<ExcalidrawState>(this as ExcalidrawState);
  }

  Map<String, dynamic> toMap() {
    return ExcalidrawStateMapper.ensureInitialized().encodeMap<ExcalidrawState>(
      this as ExcalidrawState,
    );
  }

  ExcalidrawStateCopyWith<ExcalidrawState, ExcalidrawState, ExcalidrawState>
  get copyWith =>
      _ExcalidrawStateCopyWithImpl<ExcalidrawState, ExcalidrawState>(
        this as ExcalidrawState,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ExcalidrawStateMapper.ensureInitialized().stringifyValue(
      this as ExcalidrawState,
    );
  }

  @override
  bool operator ==(Object other) {
    return ExcalidrawStateMapper.ensureInitialized().equalsValue(
      this as ExcalidrawState,
      other,
    );
  }

  @override
  int get hashCode {
    return ExcalidrawStateMapper.ensureInitialized().hashValue(
      this as ExcalidrawState,
    );
  }
}

extension ExcalidrawStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ExcalidrawState, $Out> {
  ExcalidrawStateCopyWith<$R, ExcalidrawState, $Out> get $asExcalidrawState =>
      $base.as((v, t, t2) => _ExcalidrawStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ExcalidrawStateCopyWith<$R, $In extends ExcalidrawState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, dynamic, ObjectCopyWith<$R, dynamic, dynamic>?>?
  get elements;
  $R call({
    ExcalidrawStatus? status,
    String? errorMessage,
    List<dynamic>? elements,
  });
  ExcalidrawStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ExcalidrawStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ExcalidrawState, $Out>
    implements ExcalidrawStateCopyWith<$R, ExcalidrawState, $Out> {
  _ExcalidrawStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ExcalidrawState> $mapper =
      ExcalidrawStateMapper.ensureInitialized();
  @override
  ListCopyWith<$R, dynamic, ObjectCopyWith<$R, dynamic, dynamic>?>?
  get elements => $value.elements != null
      ? ListCopyWith(
          $value.elements!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(elements: v),
        )
      : null;
  @override
  $R call({
    ExcalidrawStatus? status,
    Object? errorMessage = $none,
    Object? elements = $none,
  }) => $apply(
    FieldCopyWithData({
      if (status != null) #status: status,
      if (errorMessage != $none) #errorMessage: errorMessage,
      if (elements != $none) #elements: elements,
    }),
  );
  @override
  ExcalidrawState $make(CopyWithData data) => ExcalidrawState(
    status: data.get(#status, or: $value.status),
    errorMessage: data.get(#errorMessage, or: $value.errorMessage),
    elements: data.get(#elements, or: $value.elements),
  );

  @override
  ExcalidrawStateCopyWith<$R2, ExcalidrawState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ExcalidrawStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

