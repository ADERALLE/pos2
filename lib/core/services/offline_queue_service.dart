import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists pending offline operations as JSON lists in SharedPreferences.
/// No codegen / Hive adapters needed.
class OfflineQueueService {
  static const _createKey = 'offline_pending_creates';
  static const _doneKey   = 'offline_pending_done';
  static const _cancelKey = 'offline_pending_cancel';

  // ── pending order creates ─────────────────────────────────────────────────

  Future<void> enqueueCreate(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final list  = _load(prefs, _createKey);
    list.add(payload);
    await _save(prefs, _createKey, list);
  }

  Future<List<Map<String, dynamic>>> getPendingCreates() async {
    final prefs = await SharedPreferences.getInstance();
    return _load(prefs, _createKey);
  }

  Future<void> removePendingCreate(String localId) async {
    final prefs = await SharedPreferences.getInstance();
    final list  = _load(prefs, _createKey)
      ..removeWhere((e) => e['local_id'] == localId);
    await _save(prefs, _createKey, list);
  }

  // ── pending mark-done ─────────────────────────────────────────────────────

  Future<void> enqueueMarkDone(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final list  = _load(prefs, _doneKey);
    // deduplicate: only keep latest entry per orderId
    list.removeWhere((e) => e['order_id'] == payload['order_id']);
    list.add(payload);
    await _save(prefs, _doneKey, list);
  }

  Future<List<Map<String, dynamic>>> getPendingMarkDone() async {
    final prefs = await SharedPreferences.getInstance();
    return _load(prefs, _doneKey);
  }

  Future<void> removePendingMarkDone(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final list  = _load(prefs, _doneKey)
      ..removeWhere((e) => e['order_id'] == orderId);
    await _save(prefs, _doneKey, list);
  }

  // ── pending cancels ───────────────────────────────────────────────────────

  Future<void> enqueueCancel(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final list  = _load(prefs, _cancelKey);
    list.removeWhere((e) => e['order_id'] == payload['order_id']);
    list.add(payload);
    await _save(prefs, _cancelKey, list);
  }

  Future<List<Map<String, dynamic>>> getPendingCancels() async {
    final prefs = await SharedPreferences.getInstance();
    return _load(prefs, _cancelKey);
  }

  Future<void> removePendingCancel(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final list  = _load(prefs, _cancelKey)
      ..removeWhere((e) => e['order_id'] == orderId);
    await _save(prefs, _cancelKey, list);
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _load(SharedPreferences prefs, String key) {
    final raw = prefs.getString(key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  Future<void> _save(
      SharedPreferences prefs,
      String key,
      List<Map<String, dynamic>> list,
      ) async {
    await prefs.setString(key, jsonEncode(list));
  }

  /// Total number of queued operations (for badge display).
  Future<int> pendingCount() async {
    final prefs = await SharedPreferences.getInstance();
    return _load(prefs, _createKey).length +
        _load(prefs, _doneKey).length +
        _load(prefs, _cancelKey).length;
  }
}