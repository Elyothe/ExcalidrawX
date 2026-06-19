// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'home_bloc.dart';

class HomeStateMapper extends ClassMapperBase<HomeState> {
  HomeStateMapper._();

  static HomeStateMapper? _instance;
  static HomeStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = HomeStateMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'HomeState';

  static HomeStatus _$status(HomeState v) => v.status;
  static const Field<HomeState, HomeStatus> _f$status = Field(
    'status',
    _$status,
    opt: true,
    def: HomeStatus.initial,
  );
  static String? _$savedPath(HomeState v) => v.savedPath;
  static const Field<HomeState, String> _f$savedPath = Field(
    'savedPath',
    _$savedPath,
    opt: true,
  );
  static String? _$errorMessage(HomeState v) => v.errorMessage;
  static const Field<HomeState, String> _f$errorMessage = Field(
    'errorMessage',
    _$errorMessage,
    opt: true,
  );
  static List<String> _$savedFolders(HomeState v) => v.savedFolders;
  static const Field<HomeState, List<String>> _f$savedFolders = Field(
    'savedFolders',
    _$savedFolders,
    opt: true,
    def: const [],
  );
  static Map<String, List<String>> _$folderFiles(HomeState v) => v.folderFiles;
  static const Field<HomeState, Map<String, List<String>>> _f$folderFiles =
      Field('folderFiles', _$folderFiles, opt: true, def: const {});
  static String? _$openedFilePath(HomeState v) => v.openedFilePath;
  static const Field<HomeState, String> _f$openedFilePath = Field(
    'openedFilePath',
    _$openedFilePath,
    opt: true,
  );
  static List<dynamic>? _$openedElements(HomeState v) => v.openedElements;
  static const Field<HomeState, List<dynamic>> _f$openedElements = Field(
    'openedElements',
    _$openedElements,
    opt: true,
  );

  @override
  final MappableFields<HomeState> fields = const {
    #status: _f$status,
    #savedPath: _f$savedPath,
    #errorMessage: _f$errorMessage,
    #savedFolders: _f$savedFolders,
    #folderFiles: _f$folderFiles,
    #openedFilePath: _f$openedFilePath,
    #openedElements: _f$openedElements,
  };

  static HomeState _instantiate(DecodingData data) {
    return HomeState(
      status: data.dec(_f$status),
      savedPath: data.dec(_f$savedPath),
      errorMessage: data.dec(_f$errorMessage),
      savedFolders: data.dec(_f$savedFolders),
      folderFiles: data.dec(_f$folderFiles),
      openedFilePath: data.dec(_f$openedFilePath),
      openedElements: data.dec(_f$openedElements),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static HomeState fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<HomeState>(map);
  }

  static HomeState fromJson(String json) {
    return ensureInitialized().decodeJson<HomeState>(json);
  }
}

mixin HomeStateMappable {
  String toJson() {
    return HomeStateMapper.ensureInitialized().encodeJson<HomeState>(
      this as HomeState,
    );
  }

  Map<String, dynamic> toMap() {
    return HomeStateMapper.ensureInitialized().encodeMap<HomeState>(
      this as HomeState,
    );
  }

  HomeStateCopyWith<HomeState, HomeState, HomeState> get copyWith =>
      _HomeStateCopyWithImpl<HomeState, HomeState>(
        this as HomeState,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return HomeStateMapper.ensureInitialized().stringifyValue(
      this as HomeState,
    );
  }

  @override
  bool operator ==(Object other) {
    return HomeStateMapper.ensureInitialized().equalsValue(
      this as HomeState,
      other,
    );
  }

  @override
  int get hashCode {
    return HomeStateMapper.ensureInitialized().hashValue(this as HomeState);
  }
}

extension HomeStateValueCopy<$R, $Out> on ObjectCopyWith<$R, HomeState, $Out> {
  HomeStateCopyWith<$R, HomeState, $Out> get $asHomeState =>
      $base.as((v, t, t2) => _HomeStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class HomeStateCopyWith<$R, $In extends HomeState, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get savedFolders;
  MapCopyWith<
    $R,
    String,
    List<String>,
    ObjectCopyWith<$R, List<String>, List<String>>
  >
  get folderFiles;
  ListCopyWith<$R, dynamic, ObjectCopyWith<$R, dynamic, dynamic>?>?
  get openedElements;
  $R call({
    HomeStatus? status,
    String? savedPath,
    String? errorMessage,
    List<String>? savedFolders,
    Map<String, List<String>>? folderFiles,
    String? openedFilePath,
    List<dynamic>? openedElements,
  });
  HomeStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _HomeStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, HomeState, $Out>
    implements HomeStateCopyWith<$R, HomeState, $Out> {
  _HomeStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<HomeState> $mapper =
      HomeStateMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get savedFolders => ListCopyWith(
    $value.savedFolders,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(savedFolders: v),
  );
  @override
  MapCopyWith<
    $R,
    String,
    List<String>,
    ObjectCopyWith<$R, List<String>, List<String>>
  >
  get folderFiles => MapCopyWith(
    $value.folderFiles,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(folderFiles: v),
  );
  @override
  ListCopyWith<$R, dynamic, ObjectCopyWith<$R, dynamic, dynamic>?>?
  get openedElements => $value.openedElements != null
      ? ListCopyWith(
          $value.openedElements!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(openedElements: v),
        )
      : null;
  @override
  $R call({
    HomeStatus? status,
    Object? savedPath = $none,
    Object? errorMessage = $none,
    List<String>? savedFolders,
    Map<String, List<String>>? folderFiles,
    Object? openedFilePath = $none,
    Object? openedElements = $none,
  }) => $apply(
    FieldCopyWithData({
      if (status != null) #status: status,
      if (savedPath != $none) #savedPath: savedPath,
      if (errorMessage != $none) #errorMessage: errorMessage,
      if (savedFolders != null) #savedFolders: savedFolders,
      if (folderFiles != null) #folderFiles: folderFiles,
      if (openedFilePath != $none) #openedFilePath: openedFilePath,
      if (openedElements != $none) #openedElements: openedElements,
    }),
  );
  @override
  HomeState $make(CopyWithData data) => HomeState(
    status: data.get(#status, or: $value.status),
    savedPath: data.get(#savedPath, or: $value.savedPath),
    errorMessage: data.get(#errorMessage, or: $value.errorMessage),
    savedFolders: data.get(#savedFolders, or: $value.savedFolders),
    folderFiles: data.get(#folderFiles, or: $value.folderFiles),
    openedFilePath: data.get(#openedFilePath, or: $value.openedFilePath),
    openedElements: data.get(#openedElements, or: $value.openedElements),
  );

  @override
  HomeStateCopyWith<$R2, HomeState, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _HomeStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

