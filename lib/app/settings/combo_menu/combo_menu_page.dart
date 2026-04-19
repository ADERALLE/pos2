import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos_v1/app/shared/cashed_menu_image.dart';
import 'package:pos_v1/core/repositories/storage_repository.dart';

import '../../../core/appconstants.dart';
import '../../../core/models/category.dart';
import '../../../core/models/combo_menu.dart';
import '../../../core/models/menu_item.dart';
import '../../../core/models/size_config.dart';
import '../../../core/viewmodels/combo_menu_viewmodel.dart';
import '../../../core/viewmodels/menu_viewmodel.dart';

// ── Category filter for the combo list ───────────────────────────────────────
final _comboListCategoryFilterProvider = StateProvider<String?>((ref) => null);

class ComboMenuPage extends ConsumerWidget {
  const ComboMenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig().init(context);
    final combosAsync = ref.watch(comboMenuListProvider(AppConstants.shopId));
    final menuItemsAsync = ref.watch(menuItemListProvider(AppConstants.shopId));
    final categoriesAsync = ref.watch(comboCategoryListProvider(AppConstants.shopId));
    final itemCategoriesAsync = ref.watch(categoryListProvider(AppConstants.shopId));
    final selectedCategoryId = ref.watch(_comboListCategoryFilterProvider);

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
                    icon: const Icon(Icons.category_outlined),
                    tooltip: 'Manage combo categories',
                    onPressed: () => _showComboCategoriesSheet(
                      context,
                      ref,
                      categoriesAsync.value ?? [],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showComboForm(
                      context,
                      ref,
                      menuItemsAsync.value ?? [],
                      categories: categoriesAsync.value ?? [],
                      itemCategories: itemCategoriesAsync.value ?? [],
                    ),
                  ),
                ],
              ),
              // ── Category filter chips ──────────────────────────────────────
              categoriesAsync.maybeWhen(
                data: (cats) {
                  if (cats.isEmpty) return const SliverToBoxAdapter(child: SizedBox());
                  return SliverToBoxAdapter(
                    child: Container(
                      height: 48,
                      margin: const EdgeInsets.only(bottom: 4),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: cats.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          if (i == 0) {
                            final isSelected = selectedCategoryId == null;
                            return ChoiceChip(
                              label: const Text('All'),
                              selected: isSelected,
                              onSelected: (_) => ref
                                  .read(_comboListCategoryFilterProvider.notifier)
                                  .state = null,
                            );
                          }
                          final cat = cats[i - 1];
                          final isSelected = selectedCategoryId == cat.id;
                          return ChoiceChip(
                            label: Text(cat.label),
                            selected: isSelected,
                            onSelected: (_) => ref
                                .read(_comboListCategoryFilterProvider.notifier)
                                .state = isSelected ? null : cat.id,
                          );
                        },
                      ),
                    ),
                  );
                },
                orElse: () => const SliverToBoxAdapter(child: SizedBox()),
              ),
              combosAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: Center(child: Text('Error: $e')),
                ),
                data: (combos) {
                  final filtered = combos.where((c) =>
                      selectedCategoryId == null ||
                      c.categoryId == selectedCategoryId).toList();
                  if (filtered.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(child: Text('No combos yet. Tap + to create one.')),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _ComboTile(
                        combo: filtered[i],
                        menuItems: menuItemsAsync.value ?? [],
                        categories: categoriesAsync.value ?? [],
                        itemCategories: itemCategoriesAsync.value ?? [],
                      ),
                      childCount: filtered.length,
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

  void _showComboCategoriesSheet(
    BuildContext context,
    WidgetRef ref,
    List<Category> categories,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ComboCategoriesSheet(
        ref: ref,
        categories: categories,
      ),
    );
  }

  void _showComboForm(
    BuildContext context,
    WidgetRef ref,
    List<MenuItem> menuItems, {
    List<Category> categories = const [],
    List<Category> itemCategories = const [],
    ComboMenu? existing,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ComboFormSheet(
        ref: ref,
        menuItems: menuItems,
        categories: categories,
        itemCategories: itemCategories,
        existing: existing,
      ),
    );
  }
}

// ── Combo list tile ──────────────────────────────────────────────────────────

class _ComboTile extends ConsumerWidget {
  const _ComboTile({
    required this.combo,
    required this.menuItems,
    required this.categories,
    this.itemCategories = const [],
  });
  final ComboMenu combo;
  final List<MenuItem> menuItems;
  final List<Category> categories;
  final List<Category> itemCategories;

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
                  categories: categories,
                  itemCategories: itemCategories,
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
    this.categories = const [],
    this.itemCategories = const [],
    this.existing,
  });

  final WidgetRef ref;
  final List<MenuItem> menuItems;
  final List<Category> categories;
  final List<Category> itemCategories;
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
  String? _selectedCategoryId;
  String? _itemCategoryFilter;

  /// Map of menuItemId → quantity for items included in the combo.
  late Map<String, int> _selectedItems;

  /// Map of menuItemId → choice group name (nullable = fixed item).
  late Map<String, String?> _choiceGroups;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _priceCtrl = TextEditingController(text: e != null ? e.price.toString() : '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _imageUrl = e?.imageUrl;
    _selectedCategoryId = e?.categoryId;

    _selectedItems = {};
    _choiceGroups = {};
    if (e != null) {
      for (final ci in e.comboMenuItems) {
        _selectedItems[ci.menuItemId] = ci.quantity;
        _choiceGroups[ci.menuItemId] = ci.choiceGroup;
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
        .map((e) => {
              'menu_item_id': e.key,
              'quantity': e.value,
              if (_choiceGroups[e.key] != null) 'choice_group': _choiceGroups[e.key],
            })
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
          categoryId: _selectedCategoryId,
          clearCategory: _selectedCategoryId == null &&
              widget.existing?.categoryId != null,
        );
      } else {
        await notifier.create(
          shopId: AppConstants.shopId,
          name: _nameCtrl.text.trim(),
          price: double.parse(_priceCtrl.text.trim()),
          description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          imageUrl: _imageUrl,
          items: items,
          categoryId: _selectedCategoryId,
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
    final filteredItems = _itemCategoryFilter == null
        ? activeItems
        : activeItems.where((i) => i.categoryId == _itemCategoryFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing != null ? 'Edit Combo' : 'New Combo'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _saving
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: _save,
                  child: Text(
                    widget.existing != null ? 'Save' : 'Create',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
              24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          children: [

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
            const SizedBox(height: 12),

            // Category
            DropdownButtonFormField<String?>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(labelText: 'Category (optional)'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('— No category —'),
                ),
                ...widget.categories.map(
                  (cat) => DropdownMenuItem<String?>(
                    value: cat.id,
                    child: Text(cat.label),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _selectedCategoryId = v),
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
            // Item category filter chips
            if (widget.itemCategories.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.itemCategories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    if (i == 0) {
                      return ChoiceChip(
                        label: const Text('All'),
                        selected: _itemCategoryFilter == null,
                        onSelected: (_) =>
                            setState(() => _itemCategoryFilter = null),
                      );
                    }
                    final cat = widget.itemCategories[i - 1];
                    final isSelected = _itemCategoryFilter == cat.id;
                    return ChoiceChip(
                      label: Text(cat.label),
                      selected: isSelected,
                      onSelected: (_) => setState(() =>
                          _itemCategoryFilter = isSelected ? null : cat.id),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 8),

            // Item grid – mirrors the New Order visual style
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, i) {
                final item = filteredItems[i];
                final qty = _selectedItems[item.id];
                final isSelected = qty != null;
                final choiceGroup = _choiceGroups[item.id];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedItems.remove(item.id);
                        _choiceGroups.remove(item.id);
                      } else {
                        _selectedItems[item.id] = 1;
                      }
                    });
                  },
                  onLongPress: isSelected
                      ? () => _showChoiceGroupDialog(item.id)
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? Border.all(
                              color: choiceGroup != null
                                  ? theme.colorScheme.tertiary
                                  : theme.colorScheme.primary,
                              width: 2,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
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
                                  ? CachedMenuImage(url: item.imageUrl!)
                                  : Container(
                                      color: theme.colorScheme
                                          .surfaceContainerHighest
                                          .withOpacity(0.5),
                                      child: Center(
                                        child: Icon(Icons.fastfood,
                                            size: 32,
                                            color: theme.colorScheme.primary
                                                .withOpacity(0.4)),
                                      ),
                                    ),
                              if (isSelected)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$qty',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              // Choice group badge
                              if (isSelected && choiceGroup != null)
                                Positioned(
                                  top: 6,
                                  left: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.tertiary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      choiceGroup,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onTertiary,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text('${item.price.toStringAsFixed(2)} MAD',
                                  style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11)),
                            ],
                          ),
                        ),
                        // Quantity stepper (visible only when selected)
                        if (isSelected)
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withOpacity(0.3),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(14),
                                bottomRight: Radius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 18),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: qty! > 1
                                      ? () => setState(() =>
                                          _selectedItems[item.id] = qty - 1)
                                      : null,
                                ),
                                Text('$qty',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 18),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => setState(
                                      () => _selectedItems[item.id] = qty + 1),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Choice group hint
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: theme.hintColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Long press a selected item to assign a choice group (e.g. "drink"). '
                      'Items with the same group name become pick-one options.',
                      style: TextStyle(fontSize: 11, color: theme.hintColor),
                    ),
                  ),
                ],
              ),
            ),

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
  void _showChoiceGroupDialog(String menuItemId) {
    final ctrl = TextEditingController(text: _choiceGroups[menuItemId] ?? '');

    // Collect existing group names as quick suggestions.
    final existingGroups = _choiceGroups.values
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Choice group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Items sharing the same group name become pick-one choices '
              'for the customer. Leave empty for a fixed (always included) item.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                labelText: 'Group name',
                hintText: 'e.g. drink, dessert…',
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.none,
            ),
            if (existingGroups.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: existingGroups
                    .map((g) => ActionChip(
                          label: Text(g),
                          onPressed: () {
                            ctrl.text = g;
                          },
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _choiceGroups.remove(menuItemId));
              Navigator.pop(ctx);
            },
            child: const Text('Remove group'),
          ),
          FilledButton(
            onPressed: () {
              final value = ctrl.text.trim();
              setState(() {
                if (value.isEmpty) {
                  _choiceGroups.remove(menuItemId);
                } else {
                  _choiceGroups[menuItemId] = value;
                }
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ── Combo categories management sheet ───────────────────────────────────────

class _ComboCategoriesSheet extends StatefulWidget {
  const _ComboCategoriesSheet({required this.ref, required this.categories});
  final WidgetRef ref;
  final List<Category> categories;

  @override
  State<_ComboCategoriesSheet> createState() => _ComboCategoriesSheetState();
}

class _ComboCategoriesSheetState extends State<_ComboCategoriesSheet> {
  final _controller = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _loading = true);
    await widget.ref
        .read(comboCategoryListProvider(AppConstants.shopId).notifier)
        .create(shopId: AppConstants.shopId, label: _controller.text.trim());
    _controller.clear();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync =
        widget.ref.watch(comboCategoryListProvider(AppConstants.shopId));

    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Combo Categories',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration:
                      const InputDecoration(hintText: 'New category name'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.add),
                onPressed: _loading ? null : _add,
              ),
            ],
          ),
          const SizedBox(height: 12),
          categoriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const SizedBox(),
            data: (cats) => Column(
              children: cats
                  .map((c) => ListTile(
                        title: Text(c.label),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => widget.ref
                              .read(comboCategoryListProvider(
                                      AppConstants.shopId)
                                  .notifier)
                              .deleteCategory(
                                categoryId: c.id,
                                shopId: AppConstants.shopId,
                              ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
