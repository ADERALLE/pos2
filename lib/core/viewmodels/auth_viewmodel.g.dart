// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Auth)
final authProvider = AuthProvider._();

final class AuthProvider extends $NotifierProvider<Auth, AuthState> {
  AuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authHash();

  @$internal
  @override
  Auth create() => Auth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthState>(value),
    );
  }
}

String _$authHash() => r'afc1e25bae55cbf46f7f17ef413536d8c9aa1c47';

abstract class _$Auth extends $Notifier<AuthState> {
  AuthState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AuthState, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthState, AuthState>,
              AuthState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(currentStaff)
final currentStaffProvider = CurrentStaffProvider._();

final class CurrentStaffProvider
    extends $FunctionalProvider<Staff?, Staff?, Staff?>
    with $Provider<Staff?> {
  CurrentStaffProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentStaffProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentStaffHash();

  @$internal
  @override
  $ProviderElement<Staff?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Staff? create(Ref ref) {
    return currentStaff(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Staff? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Staff?>(value),
    );
  }
}

String _$currentStaffHash() => r'568da9ba7d59e3651823eef9b77641216a58a1e7';
