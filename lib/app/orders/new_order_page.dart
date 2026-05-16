import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_v1/app/shared/cashed_menu_image.dart';
import 'package:pos_v1/core/appconstants.dart';
import 'package:pos_v1/core/models/order.dart';
import 'package:pos_v1/core/viewmodels/auth_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/combo_menu_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/inventory_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/menu_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/order_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/shift_viewmodel.dart';
import 'package:pos_v1/core/models/cart_item.dart';
import 'package:pos_v1/core/models/combo_menu.dart';
import 'package:pos_v1/core/models/combo_menu_item.dart';
import 'package:pos_v1/core/models/menu_item.dart';
import 'package:pos_v1/i10n/app_localizations.dart';
import '../../core/models/size_config.dart';

// ── State Provider for Category Filtering ────────────────────────────────────
final selectedCategoryIdProvider = StateProvider<String?>((ref) => null);
final selectedComboCategoryIdProvider = StateProvider<String?>((ref) => null);

/// Controls which tab is active in the New Order grid.
enum OrderViewTab { items, combos }

final orderViewTabProvider = StateProvider<OrderViewTab>((ref) => OrderViewTab.items);

class NewOrderPage extends ConsumerStatefulWidget {
  const NewOrderPage({super.key});

  @override
  ConsumerState<NewOrderPage> createState() => _NewOrderPageState();
}

class _NewOrderPageState extends ConsumerState<NewOrderPage> {
  /// Tracks whether we've already populated the cart for the current editing order.
  String? _editPopulatedForOrderId;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final categoriesAsync = ref.watch(categoryListProvider(AppConstants.shopId));
    final comboCategoriesAsync = ref.watch(comboCategoryListProvider(AppConstants.shopId));
    final itemsAsync = ref.watch(menuItemListProvider(AppConstants.shopId));
    final combosAsync = ref.watch(comboMenuListProvider(AppConstants.shopId));
    final cart = ref.watch(cartProvider);
    final editingOrder = ref.watch(editingOrderProvider);
    final l10n = AppLocalizations.of(context)!;

    // When both menu data is available and an order is being edited, populate
    // the cart exactly once per editing session.
    if (editingOrder != null && _editPopulatedForOrderId != editingOrder.id) {
      itemsAsync.whenData((items) {
        combosAsync.whenData((combos) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ref.read(cartProvider.notifier).loadOrderForEdit(editingOrder, items, combos);
            setState(() => _editPopulatedForOrderId = editingOrder.id);
          });
        });
      });
    }

    // Reset flag when edit mode is cleared.
    if (editingOrder == null && _editPopulatedForOrderId != null) {
      _editPopulatedForOrderId = null;
    }

    // Watch the filter state
    final selectedCategoryId = ref.watch(selectedCategoryIdProvider);
    final selectedComboCategoryId = ref.watch(selectedComboCategoryIdProvider);
    final activeTab = ref.watch(orderViewTabProvider);

    // Responsive breakpoints
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 800;
    final showSideCart = isLargeScreen && cart.isNotEmpty;

    // Adjust grid columns based on screen width — POS needs more items visible
    final int crossAxisCount = screenWidth > 1400
        ? 7
        : screenWidth > 1100
        ? 6
        : screenWidth > 800
        ? 5
        : screenWidth > 600
        ? 4
        : 3;

    Widget mainContent = Container(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig().cardPadd(6)),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: Text(
              editingOrder != null ? l10n.editOrder : l10n.newOrder,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            pinned: true,
            floating: true,
            elevation: 0,
            scrolledUnderElevation: 2,
            actions: [
              if (editingOrder != null)
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: l10n.cancelEdit,
                  onPressed: () {
                    ref.read(editingOrderProvider.notifier).state = null;
                    ref.read(cartProvider.notifier).clear();
                    context.go('/orders');
                  },
                ),
              if (!showSideCart && cart.isNotEmpty)
                _CartBadgeButton(
                    count: cart.length,
                    onPressed: () => _showCartSheet(context)
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(92),
              child: Column(
                children: [
                  // ── Items / Combos toggle ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _TabChip(
                          label: l10n.items,
                          isSelected: activeTab == OrderViewTab.items,
                          onPressed: () => ref.read(orderViewTabProvider.notifier).state = OrderViewTab.items,
                        ),
                        const SizedBox(width: 8),
                        _TabChip(
                          label: l10n.combos,
                          isSelected: activeTab == OrderViewTab.combos,
                          onPressed: () => ref.read(orderViewTabProvider.notifier).state = OrderViewTab.combos,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // ── Category chips (items tab OR combos tab) ──
                  if (activeTab == OrderViewTab.items)
                    categoriesAsync.maybeWhen(
                      data: (cats) {
                        // Supp categories never appear in the All filter — only non-supp items show there.
                        // Supp category chips are shown separately with a distinct color.
                        final nonSuppCats = cats.where((c) => !c.isSupp).toList();
                        final suppCats = cats.where((c) => c.isSupp).toList();
                        final allCats = [...nonSuppCats, ...suppCats];
                        return Container(
                          height: 48,
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            // +1 for the All chip
                            itemCount: allCats.length + 1,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              if (i == 0) {
                                final isSelected = selectedCategoryId == null;
                                return _CategoryChip(
                                  label: l10n.all,
                                  isSelected: isSelected,
                                  onPressed: () => ref.read(selectedCategoryIdProvider.notifier).state = null,
                                );
                              }
                              final category = allCats[i - 1];
                              final isSelected = selectedCategoryId == category.id;
                              return _CategoryChip(
                                label: category.label,
                                isSelected: isSelected,
                                isSupp: category.isSupp,
                                onPressed: () => ref.read(selectedCategoryIdProvider.notifier).state =
                                isSelected ? null : category.id,
                              );
                            },
                          ),
                        );
                      },
                      orElse: () => const SizedBox(height: 48),
                    )
                  else
                    comboCategoriesAsync.maybeWhen(
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
                              final isSelected = selectedComboCategoryId == null;
                              return _CategoryChip(
                                label: l10n.all,
                                isSelected: isSelected,
                                onPressed: () => ref.read(selectedComboCategoryIdProvider.notifier).state = null,
                              );
                            }
                            final category = cats[i - 1];
                            final isSelected = selectedComboCategoryId == category.id;
                            return _CategoryChip(
                              label: category.label,
                              isSelected: isSelected,
                              onPressed: () => ref.read(selectedComboCategoryIdProvider.notifier).state =
                              isSelected ? null : category.id,
                            );
                          },
                        ),
                      ),
                      orElse: () => const SizedBox(height: 48),
                    ),
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
                child: Center(child: Text('${l10n.errorLoadingMenu}: $e')),
              ),
              data: (items) {
                final cats = categoriesAsync.value ?? [];
                final suppCatIds = cats.where((c) => c.isSupp).map((c) => c.id).toSet();
                final filteredItems = items.where((i) {
                  if (!i.isActive) return false;
                  // When "All" is selected, exclude supp-category items.
                  if (selectedCategoryId == null) {
                    return !suppCatIds.contains(i.categoryId);
                  }
                  return i.categoryId == selectedCategoryId;
                }).toList();

                if (filteredItems.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(child: Text(l10n.noItemsFoundInCategory)),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(8),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
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
                child: Center(child: Text('${l10n.errorLoadingCombos}: $e')),
              ),
              data: (combos) {
                final activeCombos = combos
                    .where((c) =>
                c.isActive &&
                    (selectedComboCategoryId == null ||
                        c.categoryId == selectedComboCategoryId))
                    .toList();
                if (activeCombos.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(child: Text(l10n.noCombosAvailable)),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(8),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.88,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
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
  final bool isSupp;
  final VoidCallback onPressed;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onPressed,
    this.isSupp = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color bgColor;
    final Color labelColor;
    final Color borderColor;

    if (isSupp) {
      bgColor = isSelected
          ? theme.colorScheme.error
          : theme.colorScheme.errorContainer.withOpacity(0.4);
      labelColor = isSelected
          ? theme.colorScheme.onError
          : theme.colorScheme.onErrorContainer;
      borderColor = theme.colorScheme.error.withOpacity(0.4);
    } else {
      bgColor = isSelected ? theme.colorScheme.primary : Colors.transparent;
      labelColor = isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
      borderColor = theme.dividerColor.withOpacity(0.2);
    }

    return ActionChip(
      label: Text(label),
      backgroundColor: bgColor,
      labelStyle: TextStyle(fontWeight: FontWeight.w600, color: labelColor),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isSelected ? BorderSide.none : BorderSide(color: borderColor),
      ),
      onPressed: onPressed,
    );
  }
}

// ── menu item card ────────────────────────────────────────────────────────────

/// Returns a comma-separated string of the inventory ingredient labels that are
/// blocking an order for the given [menuItemIds].
/// Uses the local Riverpod state (no RPC) — covers both the `stopOrdersOnEmpty`
/// case and the "effective stock exhausted by pending orders" case, since in
/// both cases the offending ingredients are those with `stopOrdersOnEmpty = true`
/// linked to the menu item(s).
/// Falls back to [fallback] when no such ingredient is found locally
/// (should not happen in practice).
String _blockingIngredientLabel(
  List<String> menuItemIds,
  WidgetRef ref, {
  required String fallback,
}) {
  final recipes =
      ref.read(inventoryRecipeListProvider(AppConstants.shopId)).value ?? [];
  final items =
      ref.read(inventoryItemListProvider(AppConstants.shopId)).value ?? [];

  final linkedInventoryIds = recipes
      .where((r) => menuItemIds.contains(r.menuItemId))
      .map((r) => r.inventoryItemId)
      .toSet();

  final blocking = items
      .where((i) => linkedInventoryIds.contains(i.id) && i.stopOrdersOnEmpty)
      .map((i) => i.label)
      .toList();

  return blocking.isNotEmpty ? blocking.join(', ') : fallback;
}

class _MenuItemCard extends ConsumerStatefulWidget {
  const _MenuItemCard({required this.item});
  final MenuItem item;

  @override
  ConsumerState<_MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends ConsumerState<_MenuItemCard> {
  bool _tapping = false;

  @override
  Widget build(BuildContext context) {
    final inCart = ref
        .watch(cartProvider)
        .where((c) => c.cartKey == widget.item.id)
        .firstOrNull;
    final blockedIds =
        ref.watch(outOfStockMenuItemIdsProvider(AppConstants.shopId));
    final isOutOfStock = blockedIds.contains(widget.item.id);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isOutOfStock
          ? null
          : () async {
              if (_tapping) return;
              setState(() => _tapping = true);
              final ok = await ref
                  .read(cartProvider.notifier)
                  .tryAddItem(widget.item);
              if (!ok && mounted) {
                final ingredient = _blockingIngredientLabel(
                  [widget.item.id], ref, fallback: widget.item.name);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      '$ingredient — ${AppLocalizations.of(context)!.outOfStock}'),
                  backgroundColor: theme.colorScheme.error,
                  duration: const Duration(seconds: 2),
                ));
              }
              if (mounted) setState(() => _tapping = false);
            },
      child: Opacity(
        opacity: isOutOfStock ? 0.45 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
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
                    widget.item.imageUrl != null &&
                            widget.item.imageUrl!.isNotEmpty
                        ? CachedMenuImage(url: widget.item.imageUrl!)
                        : _buildPlaceholder(theme),
                    if (inCart != null)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${inCart.quantity}',
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    // Épuisé overlay
                    if (isOutOfStock)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withOpacity(0.15),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Épuisé',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                        '${widget.item.price.toStringAsFixed(2)} MAD',
                        style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
      child: Center(
        child: Icon(Icons.fastfood,
            size: 28,
            color: theme.colorScheme.primary.withOpacity(0.35)),
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
  void initState() {
    super.initState();
    // Pre-fill immediately if already in edit mode when this widget is first created.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final order = ref.read(editingOrderProvider);
      if (order != null) {
        _tableLabelController.text = order.tableLabel ?? '';
        _noteController.text = order.note ?? '';
      }
    });
  }

  @override
  void dispose() {
    _tableLabelController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool _isCartItemBlocked(CartItem c, Set<String> blockedIds) {
    if (!c.isCombo) return blockedIds.contains(c.menuItem?.id);
    // For combos: blocked if any fixed item is blocked
    return c.comboMenu!.comboMenuItems
        .where((ci) => ci.choiceGroup == null)
        .any((ci) => blockedIds.contains(ci.menuItemId));
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    final staff = ref.read(currentStaffProvider);
    final shift = ref.read(activeShiftProvider(staff!.id)).value;
    final editingOrder = ref.read(editingOrderProvider);
    final tableLabel = _tableLabelController.text.trim().isEmpty ? null : _tableLabelController.text.trim();
    final note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

    if (editingOrder != null) {
      // Update the existing order in-place (same id, same status).
      await ref.read(cartProvider.notifier).updateExistingOrder(
        orderId: editingOrder.id,
        tableLabel: tableLabel,
        note: note,
      );
      ref.read(editingOrderProvider.notifier).state = null;
    } else {
      await ref.read(cartProvider.notifier).submitOrder(
        shopId: AppConstants.shopId,
        cashierId: staff.id,
        shiftId: shift?.id,
        tableLabel: tableLabel,
        note: note,
      );
    }

    // Refresh active orders and shift orders.
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
    // Pre-fill table label and note when entering edit mode.
    ref.listen<Order?>(editingOrderProvider, (previous, next) {
      if (next != null && previous?.id != next.id) {
        _tableLabelController.text = next.tableLabel ?? '';
        _noteController.text = next.note ?? '';
      }
    });

    final editingOrder = ref.watch(editingOrderProvider);
    final cart = ref.watch(cartProvider);
    final total = ref.read(cartProvider.notifier).total;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final blockedIds = ref.watch(outOfStockMenuItemIdsProvider(AppConstants.shopId));

    // Block order placement only when every item in the cart is a supplement
    // (i.e. belongs to a supp category). Combo items always count as main items
    // and therefore always satisfy the requirement on their own.
    final categories = ref.watch(categoryListProvider(AppConstants.shopId)).value ?? [];
    final suppCatIds = categories.where((c) => c.isSupp).map((c) => c.id).toSet();
    final hasOnlySupps = cart.isNotEmpty &&
        cart.every((c) =>
        !c.isCombo && suppCatIds.contains(c.menuItem?.categoryId));

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, widget.isSheet ? MediaQuery.of(context).viewInsets.bottom + 24 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  l10n.currentOrder,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (widget.isSheet)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              if (cart.isNotEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                  label: Text(
                    l10n.clearAll,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: Text(l10n.clearCartQuestion, style: const TextStyle(fontWeight: FontWeight.w600)),
                      content: Text(l10n.clearCartMessage),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(l10n.cancel),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                          onPressed: () {
                            ref.read(cartProvider.notifier).clear();
                            Navigator.pop(dialogContext);
                            if (widget.isSheet) Navigator.pop(context);
                          },
                          child: Text(l10n.clear),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: cart.isEmpty
                ? Center(child: Text(l10n.cartIsEmpty))
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
                  title: Text(c.displayName, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1),
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
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: _isCartItemBlocked(c, blockedIds)
                              ? theme.colorScheme.onSurface.withOpacity(0.3)
                              : null,
                        ),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final bool ok;
                          if (!c.isCombo) {
                            ok = await ref.read(cartProvider.notifier).tryAddItem(c.menuItem!);
                          } else if (c.selectedChoices.isNotEmpty) {
                            ok = await ref.read(cartProvider.notifier).tryAddComboWithChoices(c.comboMenu!, c.selectedChoices);
                          } else {
                            ok = await ref.read(cartProvider.notifier).tryAddCombo(c.comboMenu!);
                          }
                          if (!ok && mounted) {
                            final menuItemIds = c.isCombo
                                ? (c.selectedChoices.isNotEmpty
                                    ? [
                                        ...c.comboMenu!.comboMenuItems
                                            .where((ci) => ci.choiceGroup == null)
                                            .map((ci) => ci.menuItemId),
                                        ...c.selectedChoices.values,
                                      ]
                                    : c.comboMenu!.comboMenuItems
                                        .map((ci) => ci.menuItemId)
                                        .toList())
                                : [c.menuItem!.id];
                            final ingredient = _blockingIngredientLabel(
                                menuItemIds, ref, fallback: c.displayName);
                            messenger.showSnackBar(SnackBar(
                              content: Text(
                                  '$ingredient — ${AppLocalizations.of(context)!.outOfStock}'),
                              backgroundColor: theme.colorScheme.error,
                              duration: const Duration(seconds: 2),
                            ));
                          }
                        },
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
                hintText: l10n.tableCustomerLabel,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    l10n.total,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '${total.toStringAsFixed(2)} MAD',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (hasOnlySupps)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  l10n.addNonSupplementItem,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              onPressed: (_loading || hasOnlySupps) ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(
                editingOrder != null ? l10n.updateOrder : l10n.placeOrder,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
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

class _ComboMenuCard extends ConsumerStatefulWidget {
  const _ComboMenuCard({required this.combo});
  final ComboMenu combo;

  @override
  ConsumerState<_ComboMenuCard> createState() => _ComboMenuCardState();
}

class _ComboMenuCardState extends ConsumerState<_ComboMenuCard> {
  bool _tapping = false;

  bool get _hasChoices =>
      widget.combo.comboMenuItems.any((ci) => ci.choiceGroup != null);

  Map<String, List<ComboMenuItem>> get _choiceGroups {
    final map = <String, List<ComboMenuItem>>{};
    for (final ci in widget.combo.comboMenuItems) {
      if (ci.choiceGroup != null) {
        map.putIfAbsent(ci.choiceGroup!, () => []).add(ci);
      }
    }
    return map;
  }

  /// Un combo est bloqué si :
  /// - un de ses items fixes est épuisé, OU
  /// - TOUS les choix d'un groupe sont épuisés (aucun choix disponible)
  bool _isComboBlocked(Set<String> blockedIds) {
    if (blockedIds.isEmpty) return false;
    final fixedItems =
        widget.combo.comboMenuItems.where((ci) => ci.choiceGroup == null);
    if (fixedItems.any((ci) => blockedIds.contains(ci.menuItemId))) return true;
    for (final group in _choiceGroups.values) {
      if (group.every((ci) => blockedIds.contains(ci.menuItemId))) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final allInCart = ref.watch(cartProvider).where(
        (c) => c.isCombo && c.comboMenu?.id == widget.combo.id);
    final totalInCart = allInCart.fold<int>(0, (s, c) => s + c.quantity);
    final blockedIds =
        ref.watch(outOfStockMenuItemIdsProvider(AppConstants.shopId));
    final isBlocked = _isComboBlocked(blockedIds);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final parts = <String>[];
    for (final ci in widget.combo.comboMenuItems) {
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
      onTap: isBlocked
          ? null
          : () async {
              if (_tapping) return;
              if (_hasChoices) {
                _showChoiceDialog(context, ref);
              } else {
                setState(() => _tapping = true);
                final ok = await ref
                    .read(cartProvider.notifier)
                    .tryAddCombo(widget.combo);
                if (!ok && mounted) {
                  final allMenuItemIds = widget.combo.comboMenuItems
                      .map((ci) => ci.menuItemId)
                      .toList();
                  final ingredient = _blockingIngredientLabel(
                      allMenuItemIds, ref, fallback: widget.combo.name);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        '$ingredient — ${AppLocalizations.of(context)!.outOfStock}'),
                    backgroundColor: theme.colorScheme.error,
                    duration: const Duration(seconds: 2),
                  ));
                }
                if (mounted) setState(() => _tapping = false);
              }
            },
      child: Opacity(
        opacity: isBlocked ? 0.45 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
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
                    widget.combo.imageUrl != null && widget.combo.imageUrl!.isNotEmpty
                        ? CachedMenuImage(url: widget.combo.imageUrl!)
                        : Container(
                      color: theme.colorScheme.tertiaryContainer.withOpacity(0.4),
                      child: Center(
                        child: Icon(Icons.restaurant_menu,
                            size: 28,
                            color: theme.colorScheme.tertiary.withOpacity(0.6)),
                      ),
                    ),
                    // COMBO badge
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _hasChoices ? 'COMBO+' : 'COMBO',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onTertiary,
                          ),
                        ),
                      ),
                    ),
                    if (totalInCart > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$totalInCart',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    // Épuisé overlay
                    if (isBlocked)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withOpacity(0.15),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Épuisé',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Text area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.combo.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (itemSummary.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        itemSummary,
                        style: TextStyle(fontSize: 9, color: theme.hintColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      '${widget.combo.price.toStringAsFixed(2)} MAD',
                      style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
            final l10n = AppLocalizations.of(ctx)!;
            return AlertDialog(
              title: Text('${l10n.customize} ${widget.combo.name}'),
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
                            '${l10n.chooseYour} ${groupName.toLowerCase()}',
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
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () async {
                    final ok = await ref
                        .read(cartProvider.notifier)
                        .tryAddComboWithChoices(widget.combo, selections);
                    Navigator.pop(ctx);
                    if (!ok && context.mounted) {
                      final fixedIds = widget.combo.comboMenuItems
                          .where((ci) => ci.choiceGroup == null)
                          .map((ci) => ci.menuItemId)
                          .toList();
                      final selectedIds = selections.values.toList();
                      final ingredient = _blockingIngredientLabel(
                          [...fixedIds, ...selectedIds], ref,
                          fallback: widget.combo.name);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            '$ingredient — ${AppLocalizations.of(context)!.outOfStock}'),
                        backgroundColor:
                            Theme.of(context).colorScheme.error,
                        duration: const Duration(seconds: 2),
                      ));
                    }
                  },
                  child: Text(l10n.addToOrder),
                ),
              ],
            );
          },
        );
      },
    );
  }
}