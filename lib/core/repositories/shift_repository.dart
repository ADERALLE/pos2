import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/shift.dart';
import '../services/supabase_provider.dart';

part 'shift_repository.g.dart';

@riverpod
ShiftRepository shiftRepository(Ref ref) {
  return ShiftRepository(ref.watch(supabaseClientProvider));
}

class ShiftRepository {
  ShiftRepository(this._client);
  final SupabaseClient _client;

  Future<Shift> openShift({
    required String shopId,
    required String staffId,
    String? note,
    double rotationAmount = 0,
  }) async {
    final data = await _client
        .from('shifts')
        .insert({
      'shop_id': shopId,
      'staff_id': staffId,
      if (note != null) 'opening_note': note,
      'rotation_amount': rotationAmount,
    })
        .select()
        .single();
    return Shift.fromJson(data);
  }

  Future<Shift> closeShift({
    required String shiftId,
    String? note,
  }) async {
    final data = await _client
        .from('shifts')
        .update({
      'closed_at': DateTime.now().toUtc().toIso8601String(),
      if (note != null) 'closing_note': note,
    })
        .eq('id', shiftId)
        .select()
        .single();
    return Shift.fromJson(data);
  }

  Future<Shift?> getActiveShift(String staffId) async {
    final data = await _client
        .from('shifts')
        .select()
        .eq('staff_id', staffId)
        .isFilter('closed_at', null)
        .maybeSingle();
    return data == null ? null : Shift.fromJson(data);
  }

  Future<List<Shift>> getShopShifts(String shopId) async {
    final data = await _client
        .from('shifts')
        .select()
        .eq('shop_id', shopId)
        .order('opened_at', ascending: false);
    return data.map((e) => Shift.fromJson(e)).toList();
  }

  Future<List<Shift>> getStaffShifts(String staffId) async {
    final data = await _client
        .from('shifts')
        .select()
        .eq('staff_id', staffId)
        .order('opened_at', ascending: false);
    return data.map((e) => Shift.fromJson(e)).toList();
  }
}