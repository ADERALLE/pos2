import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/staff.dart';
import '../services/supabase_provider.dart';

part 'staff_repository.g.dart';

@riverpod
StaffRepository staffRepository(Ref ref) {
  return StaffRepository(ref.watch(supabaseClientProvider));
}

class StaffRepository {
  StaffRepository(this._client);
  final SupabaseClient _client;

  Future<List<Staff>> getStaff(String shopId) async {
    final data = await _client
        .from('staff')
        .select()
        .eq('shop_id', shopId)
        .order('created_at');
    // print(data);

    return data.map((e) => Staff.fromJson(e)).toList();
  }

  Future<Staff> createStaff({
    required String shopId,
    required String name,
    required StaffRole role,
    String? pin,
  }) async {
    final data = await _client
        .from('staff')
        .insert({
      'shop_id': shopId,
      'name': name,
      'role': role.name,
      if (pin != null) 'pin': pin,
    })
        .select()
        .single();
    return Staff.fromJson(data);
  }

  Future<Staff> updateStaff({
    required String staffId,
    String? name,
    StaffRole? role,
    String? pin,
    bool? isActive,
  }) async {
    final data = await _client
        .from('staff')
        .update({
      if (name != null) 'name': name,
      if (role != null) 'role': role.name,
      if (pin != null) 'pin': pin,
      if (isActive != null) 'is_active': isActive,
    })
        .eq('id', staffId)
        .select()
        .single();
    return Staff.fromJson(data);
  }

  Future<void> deleteStaff(String staffId) async {
    await _client.from('staff').delete().eq('id', staffId);
  }
}