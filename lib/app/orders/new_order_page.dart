import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_v1/app/shared/cashed_menu_image.dart';
import 'package:pos_v1/core/appconstants.dart';
import 'package:pos_v1/core/viewmodels/auth_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/combo_menu_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/menu_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/order_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/shift_viewmodel.dart';
import 'package:pos_v1/core/models/cart_item.dart';
import 'package:pos_v1/core/models/combo_menu.dart';
import 'package:pos_v1/core/models/combo_menu_item.dart';
import 'package:pos_v1/core/models/menu_item.dart';
import '../../core/models/size_config.dart';

// ── State Provider for Category Filtering ────────────────────────────────────
final selectedCategoryIdProvider = StateProvider<String?>((ref) => null);

/// Controls which tab is active in the New Order grid.
enum OrderViewTab { items, combos }

final orderViewTabProvider = StateProvider<OrderViewTab>((ref) => OrderViewTab.items);

class NewOrderPage extends ConsumerWidget {
  const NewOrderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig().init(context);
    final categoriesAsync = ref.watch(categoryListProvider(AppConstants.shopId));
    final itemsAsync = ref.watch(menuItemListProvider(AppConstants.shopId));
    final combosAsync = ref.watch(comboMenuListProvider(AppConstants.shopId));
    final cart = ref.watch(cartProvider);

    // Watch the filter state
    final selectedCategoryId = ref.watch(selectedCategoryIdProvider);
    final activeTab = ref.watch(orderViewTabProvider);

    // Responsive breakpoints
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 800;
    final showSideCart = isLargeScreen && cart.isNotEmpty;

    // Adjust grid columns based on screen width
    final int crossAxisCount = screenWidth > 1200 ? 4 : (screenWidth > 600 ? 3 : 2);

    Widget mainContent = Container(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig().cardPadd(15)),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: const Text('New Order', style: TextStyle(fontWeight: FontWeight.bold)),
            pinned: true,
            floating: true,
            elevation: 0,
            scrolledUnderElevation: 2,
            actions: [
              if (!showSideCart && cart.isNotEmpty)
                _CartBadgeButton(
                    count: cart.length,
                    onPressed: () => _showCartSheet(context)
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(108),
              child: Column(
                children: [
                  // ── Items / Combos toggle ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _TabChip(
                          label: 'Items',
                          isSelected: activeTab == OrderViewTab.items,
                          onPressed: () => ref.read(orderViewTabProvider.notifier).state = OrderViewTab.items,
                        ),
                        const SizedBox(width: 8),
                        _TabChip(
                          label: 'Combos',
                          isSelected: activeTab == OrderViewTab.combos,
                          onPressed: () => ref.read(orderViewTabProvider.notifier).state = OrderViewTab.combos,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // ── Category chips (only visible in Items tab) ──
                  if (activeTab == OrderViewTab.items)
                    categoriesAsync.maybeWhen(
                      data: (cats) => Container(
                        height: 48,
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: cats.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            if (i == 0) {
                              final isSelected = selectedCategoryId == null;
                              return _CategoryChip(
                                label: 'All',
                                isSelected: isSelected,
                                onPressed: () => ref.read(selectedCategoryIdProvider.notifier).state = null,
                              );
                            }
                            final category = cats[i - 1];
                            final isSelected = selectedCategoryId == category.id;
                            return _CategoryChip(
                              label: category.label,
                              isSelected: isSelected,
                              onPressed: () => ref.read(selectedCategoryIdProvider.notifier).state =
                                  isSelected ? null : category.id,
                            );
                          },
                        ),
                      ),
                      orElse: () => const SizedBox(height: 48),
                    )
                  else
                    const SizedBox(height: 48),
                ],
              ),
            ),
          ),
          // ── Grid content: items OR combos ──
          if (activeTab == OrderViewTab.items)
            itemsAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Error loading menu: $e')),
              ),
              data: (items) {
                final filteredItems = items.where((i) {
                  final matchesCategory = selectedCategoryId == null || i.categoryId == selectedCategoryId;
                  return i.isActive && matchesCategory;
                }).toList();

                if (filteredItems.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('No items found in this category')),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.80,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, i) => _MenuItemCard(item: filteredItems[i]),
                      childCount: filteredItems.length,
                    ),
                  ),
                );
              },
            )
          else
            combosAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Error loading combos: $e')),
              ),
              data: (combos) {
                final activeCombos = combos.where((c) => c.isActive).toList();
                if (activeCombos.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('No combos available')),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, i) => _ComboMenuCard(combo: activeCombos[i]),
                      childCount: activeCombos.length,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: mainContent),
            if (showSideCart)
              Container(
                width: 350,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    left: BorderSide(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                ),
                child: const CartContent(isSheet: false),
              ),
          ],
        ),
      ),
    );
  }

  void _showCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const CartContent(isSheet: true),
      ),
    );
  }
}

// ── category chip ─────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ActionChip(
      label: Text(label),
      backgroundColor: isSelected ? theme.colorScheme.primary : null,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: isSelected ? theme.colorScheme.onPrimary : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isSelected ? BorderSide.none : BorderSide(color: theme.dividerColor.withOpacity(0.2)),
      ),
      onPressed: onPressed,
    );
  }
}

// ── menu item card ────────────────────────────────────────────────────────────

class _MenuItemCard extends ConsumerWidget {
  const _MenuItemCard({required this.item});
  final MenuItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inCart = ref.watch(cartProvider).where((c) => c.cartKey == item.id).firstOrNull;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => ref.read(cartProvider.notifier).addItem(item),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? CachedMenuImage(url: item.imageUrl!, )
                      : _buildPlaceholder(theme),
                  if (inCart != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${inCart.quantity}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('${item.price.toStringAsFixed(2)} MAD', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
      child: Center(
        child: Icon(Icons.fastfood, size: 40, color: theme.colorScheme.primary.withOpacity(0.4)),
      ),
    );
  }
}

// ── cart badge button ─────────────────────────────────────────────────────────

class _CartBadgeButton extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;
  const _CartBadgeButton({required this.count, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, size: 28),
            onPressed: onPressed,
          ),
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── cart content ──────────────────────────────────────────────────────────────

class CartContent extends ConsumerStatefulWidget {
  final bool isSheet;
  const CartContent({super.key, required this.isSheet});

  @override
  ConsumerState<CartContent> createState() => _CartContentState();
}

class _CartContentState extends ConsumerState<CartContent> {
  final _tableLabelController = TextEditingController();
  final _noteController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _tableLabelController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    final staff = ref.read(currentStaffProvider);
    final shift = ref.read(activeShiftProvider(staff!.id)).value;

    await ref.read(cartProvider.notifier).submitOrder(
      shopId: AppConstants.shopId,
      cashierId: staff.id,
      shiftId: shift?.id,
      tableLabel: _tableLabelController.text.trim().isEmpty ? null : _tableLabelController.text.trim(),
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    // Refreshing state
    ref.invalidate(activeOrdersProvider(AppConstants.shopId));
    ref.read(activeOrdersProvider(AppConstants.shopId).notifier).refresh(AppConstants.shopId);
     ref.read(myActiveOrdersProvider(staff.id).notifier).refresh(staff.id);
    if (shift != null) ref.invalidate(shiftOrdersProvider(shift.id));

    if (mounted) {
      setState(() => _loading = false);
      _tableLabelController.clear();
      _noteController.clear();
      if (widget.isSheet) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final total = ref.read(cartProvider.notifier).total;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, widget.isSheet ? MediaQuery.of(context).viewInsets.bottom + 24 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Current Order', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              if (widget.isSheet) IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: cart.isEmpty
                ? const Center(child: Text('Cart is empty'))
                : ListView.separated(
              itemCount: cart.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final c = cart[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: c.isCombo
                      ? Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.restaurant_menu, size: 18),
                        )
                      : null,
                  title: Text(c.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (c.choicesSummary.isNotEmpty)
                        Text(
                          c.choicesSummary,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.tertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      Text('${c.subtotal.toStringAsFixed(2)} MAD'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => ref.read(cartProvider.notifier).updateQuantity(c.cartKey, c.quantity - 1),
                      ),
                      Text('${c.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => ref.read(cartProvider.notifier).updateQuantity(c.cartKey, c.quantity + 1),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (cart.isNotEmpty) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _tableLabelController,
              decoration: InputDecoration(
                hintText: 'Table / Customer label',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontSize: 16)),
                Text('${total.toStringAsFixed(2)} MAD',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Place Order', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ]
        ],
      ),
    );
  }
}

// ── tab chip (Items / Combos toggle) ─────────────────────────────────────────

class _TabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _TabChip({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: isSelected ? theme.colorScheme.onPrimaryContainer : null,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (_) => onPressed(),
    );
  }
}

// ── combo menu card ──────────────────────────────────────────────────────────

class _ComboMenuCard extends ConsumerWidget {
  const _ComboMenuCard({required this.combo});
  final ComboMenu combo;

  /// Whether this combo contains at least one choice group.
  bool get _hasChoices =>
      combo.comboMenuItems.any((ci) => ci.choiceGroup != null);

  /// Returns choice groups: groupName → list of ComboMenuItems in that group.
  Map<String, List<ComboMenuItem>> get _choiceGroups {
    final map = <String, List<ComboMenuItem>>{};
    for (final ci in combo.comboMenuItems) {
      if (ci.choiceGroup != null) {
        map.putIfAbsent(ci.choiceGroup!, () => []).add(ci);
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For combos with choices, count all matching cart entries
    final allInCart = ref.watch(cartProvider).where(
        (c) => c.isCombo && c.comboMenu?.id == combo.id);
    final totalInCart = allInCart.fold<int>(0, (s, c) => s + c.quantity);
    final theme = Theme.of(context);

    // Build a short summary: fixed items + choice group labels
    final parts = <String>[];
    for (final ci in combo.comboMenuItems) {
      if (ci.choiceGroup == null && ci.menuItem != null) {
        parts.add(ci.quantity > 1
            ? '${ci.quantity}x ${ci.menuItem!.name}'
            : ci.menuItem!.name);
      }
    }
    for (final group in _choiceGroups.keys) {
      final options = _choiceGroups[group]!
          .where((ci) => ci.menuItem != null)
          .map((ci) => ci.menuItem!.name)
          .join(' / ');
      parts.add('$group: $options');
    }
    final itemSummary = parts.join(', ');

    return GestureDetector(
      onTap: () {
        if (_hasChoices) {
          _showChoiceDialog(context, ref);
        } else {
          ref.read(cartProvider.notifier).addCombo(combo);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  combo.imageUrl != null && combo.imageUrl!.isNotEmpty
                      ? CachedMenuImage(url: combo.imageUrl!)
                      : Container(
                          color: theme.colorScheme.tertiaryContainer
                              .withOpacity(0.4),
                          child: Center(
                            child: Icon(Icons.restaurant_menu,
                                size: 40,
                                color: theme.colorScheme.tertiary
                                    .withOpacity(0.6)),
                          ),
                        ),
                  // COMBO badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _hasChoices ? 'COMBO + CHOICE' : 'COMBO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onTertiary,
                        ),
                      ),
                    ),
                  ),
                  if (totalInCart > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$totalInCart',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Text area
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(combo.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (itemSummary.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      itemSummary,
                      style: TextStyle(fontSize: 11, color: theme.hintColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${combo.price.toStringAsFixed(2)} MAD',
                    style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChoiceDialog(BuildContext context, WidgetRef ref) {
    final groups = _choiceGroups;
    // Pre-select the first option in each group.
    final selections = <String, String>{};
    for (final entry in groups.entries) {
      final first = entry.value.firstOrNull;
      if (first != null) selections[entry.key] = first.menuItemId;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final theme = Theme.of(ctx);
            return AlertDialog(
              title: Text('Customize ${combo.name}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: groups.entries.map((entry) {
                    final groupName = entry.key;
                    final options = entry.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          child: Text(
                            'Choose your ${groupName.toLowerCase()}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ),
                        ...options.map((ci) {
                          final mi = ci.menuItem;
                          if (mi == null) return const SizedBox.shrink();
                          final isChosen =
                              selections[groupName] == ci.menuItemId;
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: isChosen
                                  ? BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 2)
                                  : BorderSide.none,
                            ),
                            child: RadioListTile<String>(
                              value: ci.menuItemId,
                              groupValue: selections[groupName],
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() =>
                                      selections[groupName] = val);
                                }
                              },
                              title: Text(mi.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                              secondary: mi.imageUrl != null &&
                                      mi.imageUrl!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: SizedBox(
                                        width: 44,
                                        height: 44,
                                        child:
                                            CachedMenuImage(url: mi.imageUrl!),
                                      ),
                                    )
                                  : null,
                              dense: true,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }),
                      ],
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    ref
                        .read(cartProvider.notifier)
                        .addComboWithChoices(combo, selections);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Add to order'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}