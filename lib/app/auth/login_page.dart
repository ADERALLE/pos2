import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_v1/core/appconstants.dart';
import '../../core/models/staff.dart';
import '../../core/models/size_config.dart';
import '../../core/viewmodels/auth_viewmodel.dart';
import '../../core/viewmodels/staff_viewmodel.dart';
import '../../i10n/app_localizations.dart';

// ── Breakpoints ───────────────────────────────────────────────────────────────

class _Bp {
  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= 600;
}

// ── Login Page ────────────────────────────────────────────────────────────────

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

  int get _requiredPinLength => _selectedStaff?.pin?.length ?? 4;
  bool get _staffHasNoPin =>
      _selectedStaff != null &&
          (_selectedStaff!.pin == null || _selectedStaff!.pin!.isEmpty);

  void _selectStaff(Staff s) {
    setState(() {
      _selectedStaff = s;
      _pin = '';
      _error = false;
    });
    if (s.pin == null || s.pin!.isEmpty) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _submit(bypassPin: true));
    }
  }

  void _onDigit(String digit) {
    if (_loading || _pin.length >= _requiredPinLength) return;
    setState(() {
      _pin += digit;
      _error = false;
    });
    if (_pin.length == _requiredPinLength) _submit();
  }

  void _onDelete() {
    if (_loading || _pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit({bool bypassPin = false}) async {
    if (_selectedStaff == null) return;
    setState(() => _loading = true);

    final success = await ref
        .read(authProvider.notifier)
        .login(_selectedStaff!, bypassPin ? "" : _pin);

    if (!mounted) return;

    if (!success) {
      setState(() {
        _error = true;
        _pin = '';
        _loading = false;
        if (bypassPin) _selectedStaff = null;
      });
      return;
    }

    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final l10n = AppLocalizations.of(context)!;
    final staffAsync = ref.watch(staffListProvider(AppConstants.shopId));
    final isTablet = _Bp.isTablet(context);

    return Scaffold(
      body: SafeArea(
        child: isTablet
            ? _TabletLayout(
          l10n: l10n,
          staffAsync: staffAsync,
          selectedStaff: _selectedStaff,
          pin: _pin,
          error: _error,
          loading: _loading,
          staffHasNoPin: _staffHasNoPin,
          requiredPinLength: _requiredPinLength,
          onSelectStaff: _selectStaff,
          onDigit: _onDigit,
          onDelete: _onDelete,
        )
            : _PhoneLayout(
          l10n: l10n,
          staffAsync: staffAsync,
          selectedStaff: _selectedStaff,
          pin: _pin,
          error: _error,
          loading: _loading,
          staffHasNoPin: _staffHasNoPin,
          requiredPinLength: _requiredPinLength,
          onSelectStaff: _selectStaff,
          onDigit: _onDigit,
          onDelete: _onDelete,
        ),
      ),
    );
  }
}

// ── Phone Layout ──────────────────────────────────────────────────────────────

class _PhoneLayout extends StatelessWidget {
  const _PhoneLayout({
    required this.l10n,
    required this.staffAsync,
    required this.selectedStaff,
    required this.pin,
    required this.error,
    required this.loading,
    required this.staffHasNoPin,
    required this.requiredPinLength,
    required this.onSelectStaff,
    required this.onDigit,
    required this.onDelete,
  });

  final AppLocalizations l10n;
  final AsyncValue<List<Staff>> staffAsync;
  final Staff? selectedStaff;
  final String pin;
  final bool error;
  final bool loading;
  final bool staffHasNoPin;
  final int requiredPinLength;
  final ValueChanged<Staff> onSelectStaff;
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          title: Text(l10n.welcome),
          pinned: true,
          centerTitle: false,
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _StaffGrid(
                  staffAsync: staffAsync,
                  selectedStaff: selectedStaff,
                  loading: loading,
                  onSelectStaff: onSelectStaff,
                  horizontal: true,
                ),
                const SizedBox(height: 28),
                if (selectedStaff != null)
                  _PinSection(
                    staff: selectedStaff!,
                    pin: pin,
                    error: error,
                    loading: loading,
                    staffHasNoPin: staffHasNoPin,
                    requiredPinLength: requiredPinLength,
                    l10n: l10n,
                    onDigit: onDigit,
                    onDelete: onDelete,
                    padButtonSize: const Size(72, 60),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tablet Layout ─────────────────────────────────────────────────────────────

class _TabletLayout extends StatelessWidget {
  const _TabletLayout({
    required this.l10n,
    required this.staffAsync,
    required this.selectedStaff,
    required this.pin,
    required this.error,
    required this.loading,
    required this.staffHasNoPin,
    required this.requiredPinLength,
    required this.onSelectStaff,
    required this.onDigit,
    required this.onDelete,
  });

  final AppLocalizations l10n;
  final AsyncValue<List<Staff>> staffAsync;
  final Staff? selectedStaff;
  final String pin;
  final bool error;
  final bool loading;
  final bool staffHasNoPin;
  final int requiredPinLength;
  final ValueChanged<Staff> onSelectStaff;
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);
    final isLandscape = size.width > size.height;

    return Row(
      children: [
        // ── Left panel: staff list ──────────────────────────────────────────
        Container(
          width: isLandscape ? size.width * 0.40 : size.width * 0.46,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            border: Border(
              right: BorderSide(
                  color: scheme.outlineVariant.withOpacity(0.4)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 4),
                child: Text(
                  l10n.welcome,
                  style:
                  Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Text(
                  'Select your profile',
                  style: TextStyle(
                      fontSize: 13, color: scheme.onSurfaceVariant),
                ),
              ),
              Expanded(
                child: _StaffGrid(
                  staffAsync: staffAsync,
                  selectedStaff: selectedStaff,
                  loading: loading,
                  onSelectStaff: onSelectStaff,
                  horizontal: false,
                  scrollPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                ),
              ),
            ],
          ),
        ),

        // ── Right panel: PIN ────────────────────────────────────────────────
        Expanded(
          child: Center(
            child: selectedStaff == null
                ? _SelectPrompt(scheme: scheme)
                : _PinSection(
              staff: selectedStaff!,
              pin: pin,
              error: error,
              loading: loading,
              staffHasNoPin: staffHasNoPin,
              requiredPinLength: requiredPinLength,
              l10n: l10n,
              onDigit: onDigit,
              onDelete: onDelete,
              padButtonSize: const Size(84, 68),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Staff Grid ────────────────────────────────────────────────────────────────

class _StaffGrid extends StatelessWidget {
  const _StaffGrid({
    required this.staffAsync,
    required this.selectedStaff,
    required this.loading,
    required this.onSelectStaff,
    required this.horizontal,
    this.scrollPadding,
  });

  final AsyncValue<List<Staff>> staffAsync;
  final Staff? selectedStaff;
  final bool loading;
  final ValueChanged<Staff> onSelectStaff;
  final bool horizontal;
  final EdgeInsets? scrollPadding;

  @override
  Widget build(BuildContext context) {
    return staffAsync.when(
      loading: () =>
      const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (staffList) {
        final active = staffList.where((s) => s.isActive).toList();
        if (active.isEmpty) return const _NoActiveStaff();

        if (horizontal) {
          return SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: active.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _StaffChip(
                staff: active[i],
                selected: selectedStaff?.id == active[i].id,
                loading: loading && selectedStaff?.id == active[i].id,
                onTap: loading ? null : () => onSelectStaff(active[i]),
                compact: true,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: scrollPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: active.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _StaffChip(
            staff: active[i],
            selected: selectedStaff?.id == active[i].id,
            loading: loading && selectedStaff?.id == active[i].id,
            onTap: loading ? null : () => onSelectStaff(active[i]),
            compact: false,
          ),
        );
      },
    );
  }
}

// ── PIN Section ───────────────────────────────────────────────────────────────

class _PinSection extends StatelessWidget {
  const _PinSection({
    required this.staff,
    required this.pin,
    required this.error,
    required this.loading,
    required this.staffHasNoPin,
    required this.requiredPinLength,
    required this.l10n,
    required this.onDigit,
    required this.onDelete,
    required this.padButtonSize,
  });

  final Staff staff;
  final String pin;
  final bool error;
  final bool loading;
  final bool staffHasNoPin;
  final int requiredPinLength;
  final AppLocalizations l10n;
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final Size padButtonSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (staffHasNoPin) {
      return _NoPinIndicator(
          name: staff.name, loading: loading, scheme: scheme);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${l10n.enterPinFor} ${staff.name}',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '$requiredPinLength-digit PIN',
          style:
          TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        _PinDots(
          total: requiredPinLength,
          filled: pin.length,
          error: error,
          scheme: scheme,
        ),
        if (error) ...[
          const SizedBox(height: 10),
          Text(
            l10n.wrongPin,
            style: TextStyle(
              color: scheme.error,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 24),
        _PinPad(
          onDigit: onDigit,
          onDelete: onDelete,
          buttonSize: padButtonSize,
        ),
      ],
    );
  }
}

// ── PIN Dots ──────────────────────────────────────────────────────────────────

class _PinDots extends StatelessWidget {
  const _PinDots({
    required this.total,
    required this.filled,
    required this.error,
    required this.scheme,
  });

  final int total;
  final int filled;
  final bool error;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final dotSize = total <= 8 ? 14.0 : 10.0;
    final spacing = total <= 8 ? 10.0 : 6.0;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: WrapAlignment.center,
      children: List.generate(
        total,
            (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < filled
                ? error
                ? scheme.error
                : scheme.primary
                : scheme.outlineVariant.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}

// ── PIN Pad ───────────────────────────────────────────────────────────────────

class _PinPad extends StatelessWidget {
  const _PinPad({
    required this.onDigit,
    required this.onDelete,
    required this.buttonSize,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final Size buttonSize;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', 'del'],
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              if (key.isEmpty) {
                return SizedBox(
                    width: buttonSize.width + 12,
                    height: buttonSize.height);
              }
              final isDel = key == 'del';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Material(
                  color: isDel
                      ? scheme.surfaceContainerHighest
                      : scheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => isDel ? onDelete() : onDigit(key),
                    child: Container(
                      width: buttonSize.width,
                      height: buttonSize.height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color:
                          scheme.outlineVariant.withOpacity(0.25),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: isDel
                          ? Icon(Icons.backspace_outlined,
                          color: scheme.onSurfaceVariant, size: 22)
                          : Text(
                        key,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

// ── Staff Chip ────────────────────────────────────────────────────────────────

class _StaffChip extends StatelessWidget {
  const _StaffChip({
    required this.staff,
    required this.selected,
    required this.loading,
    required this.onTap,
    required this.compact,
  });

  final Staff staff;
  final bool selected;
  final bool loading;
  final VoidCallback? onTap;
  final bool compact;

  bool get _hasPin => staff.pin != null && staff.pin!.isNotEmpty;
  bool get _isManager => staff.role == StaffRole.manager;

  @override
  Widget build(BuildContext context) =>
      compact ? _buildCompact(context) : _buildListTile(context);

  Widget _buildCompact(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? scheme.primary
                : _isManager
                ? Colors.amber.shade700.withOpacity(0.5)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: scheme.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Avatar(
              staff: staff,
              selected: selected,
              loading: loading,
              isManager: _isManager,
              radius: 20,
            ),
            const SizedBox(height: 8),
            Text(
              staff.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : scheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              staff.role.name,
              style: TextStyle(
                fontSize: 10,
                color: selected
                    ? Colors.white70
                    : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? scheme.primary
                : _isManager
                ? Colors.amber.shade700.withOpacity(0.4)
                : scheme.outlineVariant.withOpacity(0.3),
            width: selected ? 0 : 1.5,
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: scheme.primary.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ]
              : null,
        ),
        child: Row(
          children: [
            _Avatar(
              staff: staff,
              selected: selected,
              loading: loading,
              isManager: _isManager,
              radius: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    staff.role.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: selected
                          ? Colors.white70
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(0.15)
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _hasPin
                        ? Icons.lock_outline_rounded
                        : Icons.lock_open_rounded,
                    size: 11,
                    color: selected
                        ? Colors.white70
                        : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _hasPin ? '${staff.pin!.length}-digit' : 'No PIN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: selected
                          ? Colors.white70
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.staff,
    required this.selected,
    required this.loading,
    required this.isManager,
    required this.radius,
  });

  final Staff staff;
  final bool selected;
  final bool loading;
  final bool isManager;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: selected
              ? Colors.white.withOpacity(0.2)
              : isManager
              ? Colors.amber.shade700.withOpacity(0.1)
              : scheme.primary.withOpacity(0.1),
          child: loading
              ? SizedBox(
            width: radius,
            height: radius,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: selected ? Colors.white : scheme.primary,
            ),
          )
              : Text(
            staff.name[0].toUpperCase(),
            style: TextStyle(
              fontSize: radius * 0.8,
              fontWeight: FontWeight.w700,
              color: selected
                  ? Colors.white
                  : isManager
                  ? Colors.amber.shade700
                  : scheme.primary,
            ),
          ),
        ),
        if (isManager)
          Positioned(
            bottom: -2,
            right: -3,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.amber.shade700,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? scheme.primary
                      : scheme.surfaceContainerLow,
                  width: 1.5,
                ),
              ),
              child: const Icon(Icons.star_rounded,
                  size: 8, color: Colors.white),
            ),
          ),
      ],
    );
  }
}

// ── No-PIN Indicator ──────────────────────────────────────────────────────────

class _NoPinIndicator extends StatelessWidget {
  const _NoPinIndicator({
    required this.name,
    required this.loading,
    required this.scheme,
  });

  final String name;
  final bool loading;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding:
      const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: scheme.primary),
            )
          else
            Icon(Icons.login_rounded, color: scheme.primary, size: 22),
          const SizedBox(width: 14),
          Text(
            loading ? 'Signing in as $name…' : 'Signing in as $name',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Select Prompt (tablet idle) ───────────────────────────────────────────────

class _SelectPrompt extends StatelessWidget {
  const _SelectPrompt({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.touch_app_rounded,
              size: 48, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        Text(
          'Select a profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose a staff member on the left to continue',
          style:
          TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── No Active Staff ───────────────────────────────────────────────────────────

class _NoActiveStaff extends StatelessWidget {
  const _NoActiveStaff();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_alt_outlined,
              size: 40, color: scheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            'No active staff members',
            style: TextStyle(
                fontSize: 14, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}