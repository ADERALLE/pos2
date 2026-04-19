import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos_v1/app/shared/cashed_menu_image.dart';
import 'package:pos_v1/core/repositories/storage_repository.dart';

import '../../../core/appconstants.dart';
import '../../../core/models/combo_menu.dart';
import '../../../core/models/menu_item.dart';
import '../../../core/models/size_config.dart';
import '../../../core/viewmodels/combo_menu_viewmodel.dart';
import '../../../core/viewmodels/menu_viewmodel.dart';

class ComboMenuPage extends ConsumerWidget {
  const ComboMenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig().init(context);
    final combosAsync = ref.watch(comboMenuListProvider(AppConstants.shopId));
    final menuItemsAsync = ref.watch(menuItemListProvider(AppConstants.shopId));

    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig().cardPadd(25)),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                title: const Text('Combo Menus',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                floating: true,
                pinned: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showComboForm(
                      context,
                      ref,
                      menuItemsAsync.value ?? [],
                    ),
                  ),
                ],
              ),
              combosAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: Center(child: Text('Error: $e')),
                ),
                data: (combos) {
                  if (combos.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(child: Text('No combos yet. Tap + to create one.')),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _ComboTile(
                        combo: combos[i],
                        menuItems: menuItemsAsync.value ?? [],
                      ),
                      childCount: combos.length,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComboForm(
    BuildContext context,
    WidgetRef ref,
    List<MenuItem> menuItems, {
    ComboMenu? existing,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ComboFormSheet(
        ref: ref,
        menuItems: menuItems,
        existing: existing,
      ),
    );
  }
}

// ── Combo list tile ──────────────────────────────────────────────────────────

class _ComboTile extends ConsumerWidget {
  const _ComboTile({required this.combo, required this.menuItems});
  final ComboMenu combo;
  final List<MenuItem> menuItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final itemSummary = combo.comboMenuItems
        .where((ci) => ci.menuItem != null)
        .map((ci) =>
            ci.quantity > 1 ? '${ci.quantity}x ${ci.menuItem!.name}' : ci.menuItem!.name)
        .join(', ');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: combo.imageUrl != null && combo.imageUrl!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: CachedMenuImage(url: combo.imageUrl!),
                ),
              )
            : Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.restaurant_menu,
                    color: theme.colorScheme.onTertiaryContainer),
              ),
        title: Row(
          children: [
            Expanded(
              child:
                  Text(combo.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (!combo.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Inactive',
                    style: TextStyle(
                        fontSize: 11, color: theme.colorScheme.onErrorContainer)),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${combo.price.toStringAsFixed(2)} MAD',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
            if (itemSummary.isNotEmpty)
              Text(itemSummary,
                  style: TextStyle(fontSize: 12, color: theme.hintColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => _ComboFormSheet(
                  ref: ref,
                  menuItems: menuItems,
                  existing: combo,
                ),
              );
            } else if (value == 'toggle') {
              await ref
                  .read(comboMenuListProvider(AppConstants.shopId).notifier)
                  .edit(
                    comboId: combo.id,
                    shopId: AppConstants.shopId,
                    isActive: !combo.isActive,
                  );
            } else if (value == 'delete') {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete combo?'),
                  content: Text('Are you sure you want to delete "${combo.name}"?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete')),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref
                    .read(comboMenuListProvider(AppConstants.shopId).notifier)
                    .delete(comboId: combo.id, shopId: AppConstants.shopId);
              }
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(
              value: 'toggle',
              child: Text(combo.isActive ? 'Deactivate' : 'Activate'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}

// ── Combo form bottom sheet ──────────────────────────────────────────────────

class _ComboFormSheet extends StatefulWidget {
  const _ComboFormSheet({
    required this.ref,
    required this.menuItems,
    this.existing,
  });

  final WidgetRef ref;
  final List<MenuItem> menuItems;
  final ComboMenu? existing;

  @override
  State<_ComboFormSheet> createState() => _ComboFormSheetState();
}

class _ComboFormSheetState extends State<_ComboFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _descCtrl;
  String? _imageUrl;
  bool _uploading = false;
  bool _saving = false;

  /// Map of menuItemId → quantity for items included in the combo.
  late Map<String, int> _selectedItems;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _priceCtrl = TextEditingController(text: e != null ? e.price.toString() : '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _imageUrl = e?.imageUrl;

    _selectedItems = {};
    if (e != null) {
      for (final ci in e.comboMenuItems) {
        _selectedItems[ci.menuItemId] = ci.quantity;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final xFile = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 600);
    if (xFile == null) return;
    setState(() => _uploading = true);
    try {
      final url = await widget.ref
          .read(storageRepositoryProvider)
          .uploadMenuImage(file: File(xFile.path), shopId: AppConstants.shopId);
      setState(() => _imageUrl = url);
    } finally {
      setState(() => _uploading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one item to the combo')),
      );
      return;
    }

    setState(() => _saving = true);
    final items = _selectedItems.entries
        .map((e) => {'menu_item_id': e.key, 'quantity': e.value})
        .toList();

    try {
      final notifier =
          widget.ref.read(comboMenuListProvider(AppConstants.shopId).notifier);

      if (widget.existing != null) {
        await notifier.edit(
          comboId: widget.existing!.id,
          shopId: AppConstants.shopId,
          name: _nameCtrl.text.trim(),
          price: double.parse(_priceCtrl.text.trim()),
          description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          imageUrl: _imageUrl,
          items: items,
        );
      } else {
        await notifier.create(
          shopId: AppConstants.shopId,
          name: _nameCtrl.text.trim(),
          price: double.parse(_priceCtrl.text.trim()),
          description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          imageUrl: _imageUrl,
          items: items,
        );
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeItems = widget.menuItems.where((i) => i.isActive).toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              widget.existing != null ? 'Edit Combo' : 'New Combo',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Image picker
            GestureDetector(
              onTap: _uploading ? null : _pickImage,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ),
                child: _uploading
                    ? const Center(child: CircularProgressIndicator())
                    : _imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedMenuImage(url: _imageUrl!),
                          )
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_a_photo_outlined,
                                    color: theme.hintColor),
                                const SizedBox(height: 4),
                                Text('Add image',
                                    style: TextStyle(color: theme.hintColor)),
                              ],
                            ),
                          ),
              ),
            ),
            const SizedBox(height: 16),

            // Name
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Combo name'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            // Price
            TextFormField(
              controller: _priceCtrl,
              decoration: const InputDecoration(
                  labelText: 'Price (MAD)', prefixIcon: Icon(Icons.attach_money)),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (double.tryParse(v.trim()) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Description
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            // Item selection header
            Row(
              children: [
                const Text('Included items',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('${_selectedItems.length} selected',
                    style: TextStyle(color: theme.hintColor, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),

            // Item list
            ...activeItems.map((item) {
              final qty = _selectedItems[item.id];
              final isSelected = qty != null;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: isSelected
                      ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
                      : BorderSide.none,
                ),
                child: ListTile(
                  dense: true,
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedItems[item.id] = 1;
                        } else {
                          _selectedItems.remove(item.id);
                        }
                      });
                    },
                  ),
                  title: Text(item.name),
                  subtitle: Text('${item.price.toStringAsFixed(2)} MAD'),
                  trailing: isSelected
                      ? SizedBox(
                          width: 110,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    size: 20),
                                onPressed: qty! > 1
                                    ? () => setState(
                                        () => _selectedItems[item.id] = qty - 1)
                                    : null,
                              ),
                              Text('$qty',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              IconButton(
                                icon:
                                    const Icon(Icons.add_circle_outline, size: 20),
                                onPressed: () => setState(
                                    () => _selectedItems[item.id] = qty + 1),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
              );
            }),

            const SizedBox(height: 24),

            // Save button
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(
                      widget.existing != null ? 'Save Changes' : 'Create Combo',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
