// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StaffList)
final staffListProvider = StaffListFamily._();

final class StaffListProvider
    extends $AsyncNotifierProvider<StaffList, List<Staff>> {
  StaffListProvider._({
    required StaffListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'staffListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$staffListHash();

  @override
  String toString() {
    return r'staffListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StaffList create() => StaffList();

  @override
  bool operator ==(Object other) {
    return other is StaffListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$staffListHash() => r'cafa6e8583f2d7eb7e80e4da41b763eddf20a8c2';

final class StaffListFamily extends $Family
    with
        $ClassFamilyOverride<
          StaffList,
          AsyncValue<List<Staff>>,
          List<Staff>,
          FutureOr<List<Staff>>,
          String
        > {
  StaffListFamily._()
    : super(
        retry: null,
        name: r'staffListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StaffListProvider call(String shopId) =>
      StaffListProvider._(argument: shopId, from: this);

  @override
  String toString() => r'staffListProvider';
}

abstract class _$StaffList extends $AsyncNotifier<List<Staff>> {
  late final _$args = ref.$arg as String;
  String get shopId => _$args;

  FutureOr<List<Staff>> build(String shopId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Staff>>, List<Staff>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Staff>>, List<Staff>>,
              AsyncValue<List<Staff>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
