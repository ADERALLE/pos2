import 'package:pos_v1/core/repositories/staff_dashboard_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pos_v1/core/repositories/staff_dashboard_repository.dart';

part 'staff_dashboard_viewmodel.g.dart';

@riverpod
Future<List<Map<String, dynamic>>> staffList(Ref ref, String shopId) {
  return ref.read(staffDashboardRepositoryProvider).getStaffList(shopId);
}

@riverpod
Future<Map<String, dynamic>> staffStats(Ref ref, String staffId) {
  return ref.read(staffDashboardRepositoryProvider).getStaffStats(staffId);
}

@riverpod
class StaffShifts extends _$StaffShifts {
  int _page = 0;
  bool _hasMore = true;

  @override
  Future<List<Map<String, dynamic>>> build(String staffId) async {
    _page = 0;
    final results = await ref
        .read(staffDashboardRepositoryProvider)
        .getShiftsByStaff(staffId: staffId, page: 0);
    _hasMore = results.length == StaffDashboardRepository.pageSize;
    return results;
  }

  Future<void> loadMore(String staffId) async {
    if (!_hasMore || state.isLoading) return;
    _page++;
    final more = await ref
        .read(staffDashboardRepositoryProvider)
        .getShiftsByStaff(staffId: staffId, page: _page);
    if (!ref.mounted) return;
    if (more.isEmpty) {
      _hasMore = false;
      return;
    }
    if (more.length < StaffDashboardRepository.pageSize) {
      _hasMore = false;
    }
    state = AsyncData([...?state.value, ...more]);
  }

  bool get hasMore => _hasMore;
}