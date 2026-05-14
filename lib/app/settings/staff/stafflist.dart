import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/appconstants.dart';
import '../../../core/models/size_config.dart';
import '../../../core/models/staff.dart';
import '../../../core/viewmodels/staff_viewmodel.dart';
import '../../../i10n/app_localizations.dart';

// ── Staff List Page ───────────────────────────────────────────────────────────

class StaffListPage extends ConsumerWidget {
  const StaffListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig().init(context);
    final scheme = Theme.of(context).colorScheme;
    final staffAsync = ref.watch(staffListProvider(AppConstants.shopId));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStaffForm(context, ref),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(l10n.addStaff),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: Text(l10n.staff),
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
                      Text('${l10n.error}: $e',
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

                final managers = staffList
                    .where((s) => s.role == StaffRole.manager)
                    .toList();
                final others = staffList
                    .where((s) => s.role != StaffRole.manager)
                    .toList();

                return SliverList(
                  delegate: SliverChildListDelegate([
                    if (managers.isNotEmpty) ...[
                      _SectionHeader(title: l10n.managers, count: managers.length),
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
                      _SectionHeader(title: l10n.team, count: others.length),
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
                    const SizedBox(height: 80),
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
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4),
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
    final l10n = AppLocalizations.of(context)!;

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
                    child: Icon(_roleIcon(staff.role),
                        size: 9, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
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
                      // PIN length badge
                      if (staff.pin != null && staff.pin!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${staff.pin!.length}-${l10n.digitPin}',
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            l10n.noPin,
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
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
                            l10n.inactive,
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
              tooltip: l10n.remove,
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.removeStaffMemberQuestion),
        content: Text(
          '${l10n.permanentlyRemoveFromMenu} ${staff.name} ${l10n.fromTheTeam}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: scheme.error),
            onPressed: () async {
              await ref
                  .read(staffListProvider(AppConstants.shopId).notifier)
                  .delete(
                  staffId: staff.id, shopId: AppConstants.shopId);
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text(l10n.remove),
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.people_alt_outlined,
              size: 48, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.noStaffYet,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.addFirstTeamMember,
          style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: Text(l10n.addStaffMember),
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

  /// For managers, user picks the PIN length (4–12).
  /// For cashiers it is always fixed at 4.
  int _managerPinLength = 6;

  static const int _cashierPinLength = 4;
  static const int _managerPinMin = 4;
  static const int _managerPinMax = 12;

  bool get _isEdit => widget.existing != null;
  int get _pinMaxLength =>
      _role == StaffRole.manager ? _managerPinLength : _cashierPinLength;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name);
    _pinController = TextEditingController(text: widget.existing?.pin);
    _role = widget.existing?.role ?? StaffRole.cashier;

    // When editing, infer the manager PIN length from the existing PIN length.
    if (_isEdit &&
        widget.existing!.role == StaffRole.manager &&
        widget.existing!.pin != null &&
        widget.existing!.pin!.isNotEmpty) {
      final len = widget.existing!.pin!.length;
      _managerPinLength =
          len.clamp(_managerPinMin, _managerPinMax);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  String? _validatePin(String? v) {
    final l10n = AppLocalizations.of(context)!;
    if (v == null || v.trim().isEmpty) return null; // PIN is optional
    final trimmed = v.trim();
    if (trimmed.length != _pinMaxLength) {
      return '${l10n.pinExactDigitsPrefix} $_pinMaxLength ${l10n.pinExactDigitsSuffix}';
    }
    if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
      return l10n.pinDigitsOnly;
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    _isEdit ? l10n.editStaffMember : l10n.addStaffMember,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  _loading
                      ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child:
                      CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                      : FilledButton(
                    onPressed: _submit,
                    child: Text(_isEdit ? l10n.save : l10n.add),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 32,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Name ──────────────────────────────────────────────
                      _FormLabel(label: l10n.fullName),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: _inputDecoration(
                          context,
                          hint: l10n.exampleJohnDoe,
                          icon: Icons.person_outline_rounded,
                        ),
                        validator: (v) =>
                        v == null || v.trim().isEmpty
                            ? l10n.nameIsRequired
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // ── Role ──────────────────────────────────────────────
                      _FormLabel(label: l10n.role),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<StaffRole>(
                        value: _role,
                        decoration: _inputDecoration(
                          context,
                          hint: l10n.selectRole,
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
                                    : scheme.primary,
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

                      // ── PIN length picker (managers only) ─────────────────
                      if (_role == StaffRole.manager) ...[
                        _FormLabel(label: l10n.pinLength),
                        const SizedBox(height: 8),
                        _PinLengthPicker(
                          value: _managerPinLength,
                          min: _managerPinMin,
                          max: _managerPinMax,
                          onChanged: (len) => setState(() {
                            _managerPinLength = len;
                            _pinController.clear();
                          }),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── PIN field ─────────────────────────────────────────
                      Row(
                        children: [
                          _FormLabel(label: l10n.pin),
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
                              '$_pinMaxLength ${l10n.digits}'
                                  '${_role == StaffRole.manager ? ' · ${l10n.manager}' : ''}',
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
                            l10n.optional,
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
                          hint: '${l10n.enterDigitPinOptional} ($_pinMaxLength)',
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

                      // ── No-PIN info banner ────────────────────────────────
                      _NoPinNotice(role: _role),

                      // ── Manager security notice ───────────────────────────
                      if (_role == StaffRole.manager) ...[
                        const SizedBox(height: 8),
                        _ManagerPinNotice(pinLength: _managerPinLength),
                      ],
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
        borderSide:
        BorderSide(color: scheme.outlineVariant.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        BorderSide(color: scheme.outlineVariant.withOpacity(0.4)),
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

// ── PIN Length Picker ─────────────────────────────────────────────────────────
// Horizontal scrollable row of selectable digit-count chips (4 to 12).

class _PinLengthPicker extends StatelessWidget {
  const _PinLengthPicker({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int len = min; len <= max; len++) ...[
            GestureDetector(
              onTap: () => onChanged(len),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 48,
                height: 40,
                decoration: BoxDecoration(
                  color: value == len
                      ? Colors.amber.shade700
                      : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: value == len
                        ? Colors.amber.shade700
                        : scheme.outlineVariant.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$len',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: value == len
                          ? Colors.white
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            if (len < max) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

// ── No-PIN Notice ─────────────────────────────────────────────────────────────

class _NoPinNotice extends StatelessWidget {
  const _NoPinNotice({required this.role});
  final StaffRole role;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.noPinNotice,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Manager PIN Notice ────────────────────────────────────────────────────────

class _ManagerPinNotice extends StatelessWidget {
  const _ManagerPinNotice({required this.pinLength});
  final int pinLength;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade700.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade700.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${l10n.managerPinNoticePrefix} $pinLength-${l10n.managerPinNoticeSuffix}',
              style: TextStyle(fontSize: 12, color: Colors.amber.shade800),
            ),
          ),
        ],
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
