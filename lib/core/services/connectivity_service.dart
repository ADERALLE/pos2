import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

/// Emits true when at least one connectivity type is available.
@Riverpod(keepAlive: true)
// CHANGE: ConnectivityStreamRef -> ConnectivityStreamRef (if still failing, use Ref)
Stream<bool> connectivityStream(Ref ref) {
  return Connectivity()
      .onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none));
}

/// Synchronous snapshot: is the device currently online?
@Riverpod(keepAlive: true)
// CHANGE: IsOnlineRef -> IsOnlineRef (or Ref)
bool isOnline(Ref ref) {
  return ref.watch(connectivityStreamProvider).value ?? true;
}