import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_v1/core/appconstants.dart';
import 'package:pos_v1/core/models/inventory_item.dart';
import 'package:pos_v1/core/models/inventory_recipe.dart';
import 'package:pos_v1/core/models/menu_item.dart';
import 'package:pos_v1/core/models/size_config.dart';
import 'package:pos_v1/core/repositories/inventory_repository.dart';
import 'package:pos_v1/core/viewmodels/auth_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/inventory_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/menu_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/shift_viewmodel.dart';
import 'package:pos_v1/i10n/app_localizations.dart';

class InventoryDetailPage extends ConsumerWidget {
  const InventoryDetailPage({super.key, required this.itemId});
  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig().init(context);
    final scheme = Theme.of(context).colorScheme;
    final itemsAsync =
        ref.watch(inventoryItemListProvider(AppConstants.shopId));
    final recipesAsync =
        ref.watch(inventoryRecipeListProvider(AppConstants.shopId));
    final menuItemsAsync =
        ref.watch(menuItemListProvider(AppConstants.shopId));

    final item = itemsAsync.valueOrNull
        ?.where((i) => i.id == itemId)
        .firstOrNull;

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.inventory)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final recipes = (recipesAsync.valueOrNull ?? [])
        .where((r) => r.inventoryItemId == itemId)
        .toList();

    final menuItems = menuItemsAsync.valueOrNull ?? [];

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: Text(item.label),
            floating: true,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: AppLocalizations.of(context)!.editInventoryItem,
                onPressed: () => _showEditForm(context, ref, item),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    color: scheme.error),
                tooltip: AppLocalizations.of(context)!.deleteInventoryItemQuestion,
                onPressed: () => _confirmDelete(context, ref, item),
              ),
            ],
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig().cardPadd(16),
              vertical: 8,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Stock card ──
                _StockCard(item: item),
                const SizedBox(height: 16),

                // ── Ajustement manuel ──
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.tune_rounded),
                  label: Text(AppLocalizations.of(context)!.manualAdjustment),
                  onPressed: () => _showAdjustmentSheet(context, ref, item),
                ),
                const SizedBox(height: 24),

                // ── Recettes liées ──
                Row(
                  children: [
                    Text(AppLocalizations.of(context)!.linkedRecipes,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(AppLocalizations.of(context)!.linkMenuItem),
                      onPressed: () =>
                          _showRecipeForm(context, ref, item, menuItems, null),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (recipes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      AppLocalizations.of(context)!.noLinkedRecipes,
                      style: TextStyle(
                          color: scheme.onSurface.withOpacity(0.5)),
                    ),
                  )
                else
                  ...recipes.map((recipe) {
                    final menuItem = menuItems
                        .where((m) => m.id == recipe.menuItemId)
                        .firstOrNull;
                    return _RecipeTile(
                      recipe: recipe,
                      menuItem: menuItem,
                      inventoryItem: item,
                      onEdit: () => _showRecipeForm(
                          context, ref, item, menuItems, recipe),
                      onDelete: () => _deleteRecipe(context, ref, recipe),
                    );
                  }),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditForm(
      BuildContext context, WidgetRef ref, InventoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditItemForm(item: item),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, InventoryItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteInventoryItemQuestion),
        content:
            Text('${AppLocalizations.of(context)!.deleteInventoryItemMessage}\n"${item.label}"'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel)),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(inventoryItemListProvider(AppConstants.shopId).notifier)
                  .delete(item.id, AppConstants.shopId);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showAdjustmentSheet(
      BuildContext context, WidgetRef ref, InventoryItem item) {
    final staff = ref.read(currentStaffProvider);
    final shift =
        ref.read(activeShiftProvider(staff!.id)).valueOrNull;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AdjustmentSheet(
          item: item, shiftId: shift?.id ?? ''),
    );
  }

  void _showRecipeForm(BuildContext context, WidgetRef ref,
      InventoryItem item, List<MenuItem> menuItems, InventoryRecipe? editing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RecipeForm(
          inventoryItem: item, menuItems: menuItems, editing: editing),
    );
  }

  Future<void> _deleteRecipe(
      BuildContext context, WidgetRef ref, InventoryRecipe recipe) async {
    await ref
        .read(inventoryRecipeListProvider(AppConstants.shopId).notifier)
        .delete(recipe.id, AppConstants.shopId);
  }
}

// ── Stock Card ────────────────────────────────────────────────────────────────

class _StockCard extends StatelessWidget {
  const _StockCard({required this.item});
  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isLow = item.stopOrdersOnEmpty && item.currentStock <= 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.currentStock,
                    style: TextStyle(
                        color: scheme.onSurface.withOpacity(0.6),
                        fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  '${item.currentStock.toStringAsFixed(item.unitType == "unit" ? 0 : 1)} ${item.unitType}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isLow ? scheme.error : scheme.primary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _UnitBadge(unitType: item.unitType),
                const SizedBox(height: 8),
                if (item.stopOrdersOnEmpty)
                  Row(
                    children: [
                      Icon(Icons.block_rounded,
                          size: 14, color: scheme.error),
                      const SizedBox(width: 4),
                      Text(l10n.stopOrdersOnEmpty,
                          style: TextStyle(
                              fontSize: 11, color: scheme.error)),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitBadge extends StatelessWidget {
  const _UnitBadge({required this.unitType});
  final String unitType;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = switch (unitType) {
      'ml' => AppLocalizations.of(context)!.unitMl,
      'g' => AppLocalizations.of(context)!.unitGrams,
      _ => AppLocalizations.of(context)!.unitUnit,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(l10n,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: scheme.onSecondaryContainer)),
    );
  }
}

// ── Recipe Tile ───────────────────────────────────────────────────────────────

class _RecipeTile extends StatelessWidget {
  const _RecipeTile({
    required this.recipe,
    required this.menuItem,
    required this.inventoryItem,
    required this.onEdit,
    required this.onDelete,
  });

  final InventoryRecipe recipe;
  final MenuItem? menuItem;
  final InventoryItem inventoryItem;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.restaurant_menu_rounded),
        title: Text(menuItem?.name ?? recipe.menuItemId,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
            '${recipe.usageValue} ${inventoryItem.unitType} — ${AppLocalizations.of(context)!.usagePerUnit}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  size: 18, color: scheme.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Adjustment Sheet ─────────────────────────────────────────────────────────

class _AdjustmentSheet extends ConsumerStatefulWidget {
  const _AdjustmentSheet({required this.item, required this.shiftId});
  final InventoryItem item;
  final String shiftId;

  @override
  ConsumerState<_AdjustmentSheet> createState() => _AdjustmentSheetState();
}

class _AdjustmentSheetState extends ConsumerState<_AdjustmentSheet> {
  final _amountCtrl = TextEditingController();
  String _type = 'refill';
  bool _loading = false;

  // Pour correction : sous-mode
  bool _correctionIsSet = true; // true = set absolu, false = delta signé

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final raw = double.tryParse(_amountCtrl.text.trim());
    if (raw == null) return;

    final effectiveType = _type == 'correction'
        ? (_correctionIsSet ? 'correction_set' : 'correction_delta')
        : _type;

    setState(() => _loading = true);
    try {
      await ref.read(inventoryRepositoryProvider).manualStockAdjustment(
            inventoryItemId: widget.item.id,
            shopId: AppConstants.shopId,
            shiftId: widget.shiftId,
            type: effectiveType,
            amount: raw,
          );
      // Rafraîchir la liste
      await ref
          .read(inventoryItemListProvider(AppConstants.shopId).notifier)
          .refresh(AppConstants.shopId);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Ajustement manuel',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('${widget.item.label} — stock actuel : '
              '${widget.item.currentStock.toStringAsFixed(1)} ${widget.item.unitType}',
              style:
                  TextStyle(color: scheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 20),

          // Type selector
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'refill', label: Text('Refill'), icon: Icon(Icons.add_circle_outline)),
              ButtonSegment(value: 'waste', label: Text('Perte'), icon: Icon(Icons.remove_circle_outline)),
              ButtonSegment(value: 'correction', label: Text('Correction'), icon: Icon(Icons.tune_rounded)),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 16),

          // Correction sous-mode
          if (_type == 'correction') ...[
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                    value: true,
                    label: Text('Nouveau stock'),
                    icon: Icon(Icons.pin_outlined)),
                ButtonSegment(
                    value: false,
                    label: Text('Delta +/-'),
                    icon: Icon(Icons.compare_arrows_rounded)),
              ],
              selected: {_correctionIsSet},
              onSelectionChanged: (s) =>
                  setState(() => _correctionIsSet = s.first),
            ),
            const SizedBox(height: 12),
          ],

          // Amount field
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true, signed: !true), // signed only for correction_delta
            decoration: InputDecoration(
              labelText: _amountLabel(),
              suffixText: widget.item.unitType,
              hintText: _amountHint(),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  String _amountLabel() {
    if (_type == 'refill') return 'Quantité ajoutée';
    if (_type == 'waste') return 'Quantité perdue';
    if (_correctionIsSet) return 'Stock réel constaté';
    return 'Ajustement (+/-)';
  }

  String _amountHint() {
    if (_type == 'refill') return 'ex: 10';
    if (_type == 'waste') return 'ex: 1.5';
    if (_correctionIsSet) return 'ex: 42  (remplace le stock actuel)';
    return 'ex: -3  (perte) ou +2  (retour)';
  }
}

// ── Recipe Form ───────────────────────────────────────────────────────────────

class _RecipeForm extends ConsumerStatefulWidget {
  const _RecipeForm({
    required this.inventoryItem,
    required this.menuItems,
    this.editing,
  });
  final InventoryItem inventoryItem;
  final List<MenuItem> menuItems;
  final InventoryRecipe? editing;

  @override
  ConsumerState<_RecipeForm> createState() => _RecipeFormState();
}

class _RecipeFormState extends ConsumerState<_RecipeForm> {
  final _usageCtrl = TextEditingController();
  String? _selectedMenuItemId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editing != null) {
      _selectedMenuItemId = widget.editing!.menuItemId;
      _usageCtrl.text = widget.editing!.usageValue.toString();
    }
  }

  @override
  void dispose() {
    _usageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedMenuItemId == null) return;
    final usage = double.tryParse(_usageCtrl.text.trim());
    if (usage == null || usage <= 0) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(inventoryRecipeListProvider(AppConstants.shopId).notifier)
          .upsert(
            id: widget.editing?.id,
            shopId: AppConstants.shopId,
            menuItemId: _selectedMenuItemId!,
            inventoryItemId: widget.inventoryItem.id,
            usageValue: usage,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editing != null;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
              isEdit ? l10n.editRecipe : l10n.linkMenuItem,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Menu item selector
          DropdownButtonFormField<String>(
            value: _selectedMenuItemId,
            decoration: InputDecoration(
              labelText: l10n.inventoryItem,
              border: const OutlineInputBorder(),
            ),
            items: widget.menuItems
                .map((m) => DropdownMenuItem(
                    value: m.id,
                    child: Text(m.name,
                        overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: isEdit
                ? null // ne pas changer l'article en mode édition
                : (v) => setState(() => _selectedMenuItemId = v),
          ),
          const SizedBox(height: 16),

          // Usage value
          TextField(
            controller: _usageCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.usagePerUnit,
              suffixText: widget.inventoryItem.unitType,
              hintText: 'ex: 2.5',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(isEdit ? 'Enregistrer' : l10n.linkMenuItem),
          ),
        ],
      ),
    );
  }
}

// ── Edit Item Form ────────────────────────────────────────────────────────────

class _EditItemForm extends ConsumerStatefulWidget {
  const _EditItemForm({required this.item});
  final InventoryItem item;

  @override
  ConsumerState<_EditItemForm> createState() => _EditItemFormState();
}

class _EditItemFormState extends ConsumerState<_EditItemForm> {
  late final TextEditingController _labelCtrl;
  late String _unitType;
  late bool _stopOnEmpty;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.item.label);
    _unitType = widget.item.unitType;
    _stopOnEmpty = widget.item.stopOrdersOnEmpty;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final label = _labelCtrl.text.trim();
    if (label.isEmpty) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(inventoryItemListProvider(AppConstants.shopId).notifier)
          .update(widget.item.copyWith(
            label: label,
            unitType: _unitType,
            stopOrdersOnEmpty: _stopOnEmpty,
          ));
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.editInventoryItem,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: _labelCtrl,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nom',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _unitType,
            decoration: InputDecoration(
              labelText: l10n.unitType,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'unit', child: Text(l10n.unitUnit)),
              DropdownMenuItem(value: 'g', child: Text(l10n.unitGrams)),
              DropdownMenuItem(value: 'ml', child: Text(l10n.unitMl)),
            ],
            onChanged: (v) => setState(() => _unitType = v!),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _stopOnEmpty,
            onChanged: (v) => setState(() => _stopOnEmpty = v),
            title: Text(l10n.stopOrdersOnEmpty),
            activeColor: scheme.error,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
