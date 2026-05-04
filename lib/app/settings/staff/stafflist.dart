import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/appconstants.dart';
import '../../../core/models/size_config.dart';
import '../../../core/models/staff.dart';
import '../../../core/viewmodels/staff_viewmodel.dart';

// ── Staff List Page ───────────────────────────────────────────────────────────

class StaffListPage extends ConsumerWidget {
  const StaffListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig().init(context);
    final scheme = Theme.of(context).colorScheme;
    final staffAsync = ref.watch(staffListProvider(AppConstants.shopId));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStaffForm(context, ref),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Staff'),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: const Text('Staff'),
            floating: true,
            pinned: true,
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig().cardPadd(25),
              vertical: 16,
            ),
            sliver: staffAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 48, color: scheme.error),
                      const SizedBox(height: 12),
                      Text('Error: $e',
                          style: TextStyle(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
              data: (staffList) {
                if (staffList.isEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyState(
                      onAdd: () => _showStaffForm(context, ref),
                    ),
                  );
                }

                // Group by role: managers first, then others
                final managers = staffList
                    .where((s) => s.role == StaffRole.manager)
                    .toList();
                final others = staffList
                    .where((s) => s.role != StaffRole.manager)
                    .toList();

                return SliverList(
                  delegate: SliverChildListDelegate([
                    if (managers.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'Managers',
                        count: managers.length,
                      ),
                      const SizedBox(height: 8),
                      _StaffCard(
                        children: [
                          for (int i = 0; i < managers.length; i++) ...[
                            _StaffTile(staff: managers[i]),
                            if (i < managers.length - 1)
                              const Divider(height: 1, indent: 72),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (others.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'Team',
                        count: others.length,
                      ),
                      const SizedBox(height: 8),
                      _StaffCard(
                        children: [
                          for (int i = 0; i < others.length; i++) ...[
                            _StaffTile(staff: others[i]),
                            if (i < others.length - 1)
                              const Divider(height: 1, indent: 72),
                          ],
                        ],
                      ),
                    ],
                    const SizedBox(height: 80), // FAB clearance
                  ]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStaffForm(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _StaffFormSheet(ref: ref),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Staff Card container ──────────────────────────────────────────────────────

class _StaffCard extends StatelessWidget {
  const _StaffCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withOpacity(0.4),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

// ── Staff Tile ────────────────────────────────────────────────────────────────

class _StaffTile extends ConsumerWidget {
  const _StaffTile({required this.staff});
  final Staff staff;

  Color _roleColor(StaffRole role, ColorScheme scheme) => switch (role) {
    StaffRole.manager => Colors.amber.shade700,
    StaffRole.cashier => scheme.primary,
    _ => Colors.teal,
  };

  IconData _roleIcon(StaffRole role) => switch (role) {
    StaffRole.manager => Icons.star_rounded,
    StaffRole.cashier => Icons.point_of_sale_rounded,
    _ => Icons.person_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final roleColor = _roleColor(staff.role, scheme);

    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _StaffFormSheet(ref: ref, existing: staff),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: roleColor.withOpacity(0.12),
                  child: Text(
                    staff.name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: roleColor,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: roleColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.surface, width: 1.5),
                    ),
                    child: Icon(
                      _roleIcon(staff.role),
                      size: 9,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          staff.role.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: roleColor,
                          ),
                        ),
                      ),
                      if (!staff.isActive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: scheme.errorContainer.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Inactive',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: scheme.error,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            Switch(
              value: staff.isActive,
              onChanged: (val) => ref
                  .read(staffListProvider(AppConstants.shopId).notifier)
                  .update2(
                staffId: staff.id,
                shopId: AppConstants.shopId,
                isActive: val,
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
              tooltip: 'Remove',
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove staff member?'),
        content: Text(
          'This will permanently remove ${staff.name} from the team. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: scheme.error),
            onPressed: () {
              ref
                  .read(staffListProvider(AppConstants.shopId).notifier)
                  .delete(staffId: staff.id, shopId: AppConstants.shopId);
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.people_alt_outlined,
            size: 48,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'No staff yet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add your first team member to get started',
          style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Add Staff Member'),
        ),
      ],
    );
  }
}

// ── Staff Form Sheet ──────────────────────────────────────────────────────────

class _StaffFormSheet extends StatefulWidget {
  const _StaffFormSheet({required this.ref, this.existing});
  final WidgetRef ref;
  final Staff? existing;

  @override
  State<_StaffFormSheet> createState() => _StaffFormSheetState();
}

class _StaffFormSheetState extends State<_StaffFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _pinController;
  late StaffRole _role;
  bool _loading = false;
  bool _pinVisible = false;

  bool get _isEdit => widget.existing != null;
  int get _pinMaxLength => _role == StaffRole.manager ? 8 : 4;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name);
    _pinController = TextEditingController(text: widget.existing?.pin);
    _role = widget.existing?.role ?? StaffRole.cashier;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  String? _validatePin(String? v) {
    if (v == null || v.trim().isEmpty) return null; // optional
    final trimmed = v.trim();
    if (trimmed.length != _pinMaxLength) {
      return 'PIN must be exactly $_pinMaxLength digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
      return 'PIN must contain digits only';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final notifier =
    widget.ref.read(staffListProvider(AppConstants.shopId).notifier);

    final pin = _pinController.text.trim().isEmpty
        ? null
        : _pinController.text.trim();

    if (!_isEdit) {
      await notifier.create(
        shopId: AppConstants.shopId,
        name: _nameController.text.trim(),
        role: _role,
        pin: pin,
      );
    } else {
      await notifier.update2(
        staffId: widget.existing!.id,
        shopId: AppConstants.shopId,
        name: _nameController.text.trim(),
        role: _role,
        pin: pin,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isEdit ? 'Edit Staff Member' : 'Add Staff Member',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  _loading
                      ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                      : FilledButton(
                    onPressed: _submit,
                    child: Text(_isEdit ? 'Save' : 'Add'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20, 24, 20,
                  MediaQuery.of(context).viewInsets.bottom + 32,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name field
                      _FormLabel(label: 'Full Name'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: _inputDecoration(
                          context,
                          hint: 'e.g. John Doe',
                          icon: Icons.person_outline_rounded,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Name is required'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Role field
                      _FormLabel(label: 'Role'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<StaffRole>(
                        value: _role,
                        decoration: _inputDecoration(
                          context,
                          hint: 'Select role',
                          icon: Icons.badge_outlined,
                        ),
                        items: StaffRole.values
                            .map((r) => DropdownMenuItem(
                          value: r,
                          child: Row(
                            children: [
                              Icon(
                                r == StaffRole.manager
                                    ? Icons.star_rounded
                                    : Icons.point_of_sale_rounded,
                                size: 16,
                                color: r == StaffRole.manager
                                    ? Colors.amber.shade700
                                    : Theme.of(context)
                                    .colorScheme
                                    .primary,
                              ),
                              const SizedBox(width: 8),
                              Text(r.name),
                            ],
                          ),
                        ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              _role = v;
                              _pinController.clear();
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // PIN field
                      Row(
                        children: [
                          _FormLabel(label: 'PIN'),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: _role == StaffRole.manager
                                  ? Colors.amber.shade700.withOpacity(0.1)
                                  : scheme.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$_pinMaxLength digits${_role == StaffRole.manager ? ' · Manager' : ''}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _role == StaffRole.manager
                                    ? Colors.amber.shade700
                                    : scheme.primary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Optional',
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _pinController,
                        keyboardType: TextInputType.number,
                        maxLength: _pinMaxLength,
                        obscureText: !_pinVisible,
                        decoration: _inputDecoration(
                          context,
                          hint: 'Enter ${_pinMaxLength}-digit PIN',
                          icon: Icons.lock_outline_rounded,
                        ).copyWith(
                          counterText: '',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _pinVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: scheme.onSurfaceVariant,
                            ),
                            onPressed: () =>
                                setState(() => _pinVisible = !_pinVisible),
                          ),
                        ),
                        validator: _validatePin,
                      ),

                      const SizedBox(height: 8),

                      // Manager notice
                      if (_role == StaffRole.manager)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade700.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.amber.shade700.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  size: 16,
                                  color: Colors.amber.shade700),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Manager accounts require an 8-digit PIN for enhanced security.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      BuildContext context, {
        required String hint,
        required IconData icon,
      }) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: scheme.onSurfaceVariant),
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withOpacity(0.5),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.error),
      ),
    );
  }
}

// ── Form Label ────────────────────────────────────────────────────────────────

class _FormLabel extends StatelessWidget {
  const _FormLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}