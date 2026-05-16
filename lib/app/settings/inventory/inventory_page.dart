import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_v1/core/appconstants.dart';
import 'package:pos_v1/core/models/inventory_item.dart';
import 'package:pos_v1/core/models/size_config.dart';
import 'package:pos_v1/core/viewmodels/inventory_viewmodel.dart';
import 'package:pos_v1/i10n/app_localizations.dart';

class InventoryPage extends ConsumerWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig().init(context);
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final itemsAsync =
        ref.watch(inventoryItemListProvider(AppConstants.shopId));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(inventoryItemListProvider(AppConstants.shopId).notifier)
            .refresh(AppConstants.shopId),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
          SliverAppBar(
            title: Text(l10n.inventory),
            floating: true,
            pinned: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilledButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.addInventoryItem),
                  style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact),
                  onPressed: () => _showItemForm(context, ref),
                ),
              ),
            ],
          ),
          itemsAsync.when(
            loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('${e}'))),
            data: (items) {
              if (items.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 56,
                            color: scheme.onSurface.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(l10n.noInventoryItems,
                            style: TextStyle(
                                color: scheme.onSurface.withOpacity(0.5))),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _showItemForm(context, ref),
                          child: Text(l10n.addFirstInventoryItem),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig().cardPadd(16),
                  vertical: 8,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _InventoryItemTile(item: items[i]),
                    childCount: items.length,
                  ),
                ),
              );
            },
          ),
        ],
        ),
      ),
    );
  }

  void _showItemForm(BuildContext context, WidgetRef ref,
      {InventoryItem? editing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _InventoryItemForm(editing: editing),
    );
  }
}

// ── Item Tile ─────────────────────────────────────────────────────────────────

class _InventoryItemTile extends ConsumerWidget {
  const _InventoryItemTile({required this.item});
  final InventoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isLow = item.stopOrdersOnEmpty && item.currentStock <= 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isLow ? scheme.errorContainer : scheme.primaryContainer,
          child: Icon(
            _unitIcon(item.unitType),
            color: isLow ? scheme.error : scheme.primary,
            size: 20,
          ),
        ),
        title: Text(item.label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${item.currentStock.toStringAsFixed(item.unitType == "unit" ? 0 : 1)} ${item.unitType}',
          style: TextStyle(
            color: isLow ? scheme.error : scheme.onSurface.withOpacity(0.6),
            fontWeight: isLow ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLow)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(l10n.outOfStock,
                    style: TextStyle(
                        color: scheme.error,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            if (item.stopOrdersOnEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(Icons.block_rounded,
                    size: 16, color: scheme.error.withOpacity(0.6)),
              ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
        onTap: () => context.go('/settings/inventory/${item.id}'),
      ),
    );
  }

  IconData _unitIcon(String unitType) {
    return switch (unitType) {
      'ml' => Icons.local_drink_outlined,
      'g' => Icons.scale_outlined,
      _ => Icons.numbers_rounded,
    };
  }
}

// ── Item Form (create / edit) ─────────────────────────────────────────────────

class _InventoryItemForm extends ConsumerStatefulWidget {
  const _InventoryItemForm({this.editing});
  final InventoryItem? editing;

  @override
  ConsumerState<_InventoryItemForm> createState() => _InventoryItemFormState();
}

class _InventoryItemFormState extends ConsumerState<_InventoryItemForm> {
  final _labelCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  String _unitType = 'unit';
  bool _stopOnEmpty = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editing != null) {
      _labelCtrl.text = widget.editing!.label;
      _stockCtrl.text = widget.editing!.currentStock.toString();
      _unitType = widget.editing!.unitType;
      _stopOnEmpty = widget.editing!.stopOrdersOnEmpty;
    }
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final label = _labelCtrl.text.trim();
    if (label.isEmpty) return;
    final stock = double.tryParse(_stockCtrl.text.trim()) ?? 0;

    setState(() => _loading = true);
    try {
      final notifier =
          ref.read(inventoryItemListProvider(AppConstants.shopId).notifier);
      if (widget.editing != null) {
        await notifier.updateItem(widget.editing!.copyWith(
          label: label,
          unitType: _unitType,
          currentStock: stock,
          stopOrdersOnEmpty: _stopOnEmpty,
        ));
      } else {
        await notifier.create(
          shopId: AppConstants.shopId,
          label: label,
          unitType: _unitType,
          currentStock: stock,
          stopOrdersOnEmpty: _stopOnEmpty,
        );
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isEdit = widget.editing != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(isEdit ? l10n.editInventoryItem : l10n.newInventoryItem,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Label
          TextField(
            controller: _labelCtrl,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Nom',
              hintText: 'ex: Café, Lait, Sucre...',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Unit type
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
          const SizedBox(height: 16),

          // Current stock
          TextField(
            controller: _stockCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.currentStock,
              suffixText: _unitType,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Stop orders on empty
          SwitchListTile(
            value: _stopOnEmpty,
            onChanged: (v) => setState(() => _stopOnEmpty = v),
            title: Text(l10n.stopOrdersOnEmpty,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(l10n.stopOrdersOnEmptySubtitle),
            activeColor: scheme.error,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 20),

          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(isEdit ? 'Enregistrer' : 'Créer'),
          ),
        ],
      ),
    );
  }
}
