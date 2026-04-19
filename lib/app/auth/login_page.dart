import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_v1/core/appconstants.dart';
import 'package:pos_v1/core/repositories/shift_repository.dart';
import 'package:pos_v1/core/viewmodels/shift_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/staff_viewmodel.dart';
import 'package:pos_v1/core/models/staff.dart';
import '../../core/models/size_config.dart';
import '../../core/viewmodels/auth_viewmodel.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  Staff? _selectedStaff;
  String _pin = '';
  bool _error = false;
  bool _loading = false;

  void _onDigit(String digit) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += digit;
      _error = false;
    });
    if (_pin.length == 4) _submit();
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    setState(() => _loading = true);

    final success =
    await ref.read(authProvider.notifier).login(_selectedStaff!, _pin);

    if (!success) {
      setState(() {
        _error = true;
        _pin = '';
        _loading = false;
      });
      return;
    }

    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final staffAsync =
    ref.watch(staffListProvider(AppConstants.shopId));

    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig().cardPadd(25)),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverAppBar(
                title: Text('Welcome'),
                pinned: true,
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // staff list
                    staffAsync.when(
                      loading: () =>
                      const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('$e'),
                      data: (staffList) {
                        final active = staffList
                            .where((s) => s.isActive)
                            .toList();
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: active
                              .map((s) => _StaffChip(
                            staff: s,
                            selected: _selectedStaff?.id == s.id,
                            onTap: () => setState(() {
                              _selectedStaff = s;
                              _pin = '';
                              _error = false;
                            }),
                          ))
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    if (_selectedStaff != null) ...[
                      Text(
                        'Enter PIN for ${_selectedStaff!.name}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      // PIN dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          4,
                              (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i < _pin.length
                                  ? _error
                                  ? Colors.red
                                  : Theme.of(context).colorScheme.primary
                                  : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                      if (_error) ...[
                        const SizedBox(height: 8),
                        const Text('Wrong PIN',
                            style: TextStyle(color: Colors.red)),
                      ],
                      const SizedBox(height: 24),
                      // PIN pad
                      _PinPad(
                        onDigit: _loading ? (_) {} : _onDigit,
                        onDelete: _loading ? () {} : _onDelete,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── staff chip ────────────────────────────────────────────────────────────────

class _StaffChip extends StatelessWidget {
  const _StaffChip({
    required this.staff,
    required this.selected,
    required this.onTap,
  });
  final Staff staff;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: selected
                  ? Colors.white.withOpacity(0.2)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Text(
                staff.name[0].toUpperCase(),
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              staff.name,
              style: TextStyle(
                color: selected ? Colors.white : null,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              staff.role.name,
              style: TextStyle(
                fontSize: 11,
                color:
                selected ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── pin pad ───────────────────────────────────────────────────────────────────

class _PinPad extends StatelessWidget {
  const _PinPad({required this.onDigit, required this.onDelete});
  final void Function(String) onDigit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', 'del'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              if (key.isEmpty) return const SizedBox(width: 80, height: 64);
              return GestureDetector(
                onTap: () =>
                key == 'del' ? onDelete() : onDigit(key),
                child: Container(
                  width: 80,
                  height: 64,
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: key == 'del'
                        ? const Icon(Icons.backspace_outlined)
                        : Text(key,
                        style: Theme.of(context).textTheme.headlineSmall),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}