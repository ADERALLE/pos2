import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
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
    final scheme = Theme.of(context).colorScheme;
    final combosAsync = ref.watch(comboMenuListProvider(AppConstants.shopId));
    final menuItemsAsync =
    ref.watch(menuItemListProvider(AppConstants.shopId));
    final categoriesAsync =
    ref.watch(comboCategoryListProvider(AppConstants.shopId));
    final itemCategoriesAsync =
    ref.watch(categoryListProvider(AppConstants.shopId));
    final selectedCategoryId =
    ref.watch(_comboListCategoryFilterProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: const Text('Combo Menus'),
            floating: true,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.category_outlined),
                tooltip: 'Manage combo categories',
                onPressed: () => _showComboCategoriesSheet(
                    context, ref, categoriesAsync.value ?? []),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilledButton.icon(
                  onPressed: () => _showComboForm(
                    context, ref,
                    menuItemsAsync.value ?? [],
                    categories: categoriesAsync.value ?? [],
                    itemCategories: itemCategoriesAsync.value ?? [],
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Combo'),
                  style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact),
                ),
              ),
            ],
          ),

          // ── Category filter chips ──────────────────────────────────────────
          categoriesAsync.maybeWhen(
            data: (cats) {
              if (cats.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox());
              }
              return SliverToBoxAdapter(
                child: _CategoryChips(
                  categories: cats,
                  selectedId: selectedCategoryId,
                  onSelect: (id) => ref
                      .read(_comboListCategoryFilterProvider.notifier)
                      .state = id,
                ),
              );
            },
            orElse: () => const SliverToBoxAdapter(child: SizedBox()),
          ),

          // ── Combo list ─────────────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig().cardPadd(25),
              vertical: 8,
            ),
            sliver: combosAsync.when(
              loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator())),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 48, color: scheme.error),
                      const SizedBox(height: 12),
                      Text('Error: $e',
                          style:
                          TextStyle(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
              data: (combos) {
                final filtered = combos
                    .where((c) =>
                selectedCategoryId == null ||
                    c.categoryId == selectedCategoryId)
                    .toList();

                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyState(
                      onAdd: () => _showComboForm(
                        context, ref,
                        menuItemsAsync.value ?? [],
                        categories: categoriesAsync.value ?? [],
                        itemCategories: itemCategoriesAsync.value ?? [],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ComboCard(
                        combo: filtered[i],
                        menuItems: menuItemsAsync.value ?? [],
                        categories: categoriesAsync.value ?? [],
                        itemCategories: itemCategoriesAsync.value ?? [],
                      ),
                    ),
                    childCount: filtered.length,
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  void _showComboCategoriesSheet(
      BuildContext context, WidgetRef ref, List<Category> categories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) =>
          _ComboCategoriesSheet(ref: ref, categories: categories),
    );
  }

  void _showComboForm(
      BuildContext context, WidgetRef ref, List<MenuItem> menuItems, {
        List<Category> categories = const [],
        List<Category> itemCategories = const [],
        ComboMenu? existing,
      }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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

// ── Shared helpers ────────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });
  final List<Category> categories;
  final String? selectedId;
  final void Function(String?) onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig().cardPadd(25), vertical: 8),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (i == 0) {
            final selected = selectedId == null;
            return _FilterChip(
              label: 'All',
              selected: selected,
              onTap: () => onSelect(null),
            );
          }
          final cat = categories[i - 1];
          final selected = selectedId == cat.id;
          return _FilterChip(
            label: cat.label,
            selected: selected,
            onTap: () => onSelect(selected ? null : cat.id),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label,
        required this.selected,
        required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? scheme.primary
                : scheme.outlineVariant.withOpacity(0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(
    BuildContext context, {
      required String hint,
      required IconData icon,
      String? suffixText,
      Widget? prefix,
    }) {
  final scheme = Theme.of(context).colorScheme;
  return InputDecoration(
    hintText: hint,
    suffixText: suffixText,
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
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.error, width: 1.5),
    ),
  );
}

class _FormLabel extends StatelessWidget {
  const _FormLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

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
          child: Icon(Icons.restaurant_menu_rounded,
              size: 48, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        Text('No combos yet',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface)),
        const SizedBox(height: 8),
        Text('Create your first combo menu',
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Create Combo'),
        ),
      ],
    );
  }
}

// ── Combo Card ────────────────────────────────────────────────────────────────

class _ComboCard extends ConsumerWidget {
  const _ComboCard({
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
    final scheme = Theme.of(context).colorScheme;
    final itemSummary = combo.comboMenuItems
        .where((ci) => ci.menuItem != null)
        .map((ci) => ci.quantity > 1
        ? '${ci.quantity}× ${ci.menuItem!.name}'
        : ci.menuItem!.name)
        .join(' · ');

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: scheme.outlineVariant.withOpacity(0.4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          shape: const RoundedRectangleBorder(
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
          builder: (_) => _ComboFormSheet(
            ref: ref,
            menuItems: menuItems,
            categories: categories,
            itemCategories: itemCategories,
            existing: combo,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: combo.imageUrl != null &&
                      combo.imageUrl!.isNotEmpty
                      ? CachedMenuImage(url: combo.imageUrl!)
                      : Container(
                    color: scheme.tertiaryContainer,
                    child: Icon(Icons.restaurant_menu_rounded,
                        color: scheme.onTertiaryContainer),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            combo.name,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (!combo.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                              scheme.errorContainer.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Inactive',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: scheme.error),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${combo.price.toStringAsFixed(2)} MAD',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: scheme.primary),
                    ),
                    if (itemSummary.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        itemSummary,
                        style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Actions
              Column(
                children: [
                  Switch(
                    value: combo.isActive,
                    onChanged: (val) => ref
                        .read(comboMenuListProvider(AppConstants.shopId)
                        .notifier)
                        .edit(
                      comboId: combo.id,
                      shopId: AppConstants.shopId,
                      isActive: val,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded,
                        color: scheme.error, size: 20),
                    onPressed: () => _confirmDelete(context, ref),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove combo?'),
        content: Text(
            'This will permanently remove "${combo.name}" from your menu.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: scheme.error),
            onPressed: () async {
              await ref
                  .read(comboMenuListProvider(AppConstants.shopId).notifier)
                  .delete(
                  comboId: combo.id, shopId: AppConstants.shopId);
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

// ── Combo Form Sheet ──────────────────────────────────────────────────────────

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
  late Map<String, int> _selectedItems;
  late Map<String, String?> _choiceGroups;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _priceCtrl = TextEditingController(
        text: e != null ? e.price.toString() : '');
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
    final xFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 600);
    if (xFile == null) return;
    setState(() => _uploading = true);
    try {
      final url = await widget.ref
          .read(storageRepositoryProvider)
          .uploadMenuImage(
          file: File(xFile.path), shopId: AppConstants.shopId);
      setState(() => _imageUrl = url);
    } finally {
      setState(() => _uploading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
          const Text('Add at least one item to the combo'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    final items = _selectedItems.entries
        .map((e) => {
      'menu_item_id': e.key,
      'quantity': e.value,
      if (_choiceGroups[e.key] != null)
        'choice_group': _choiceGroups[e.key],
    })
        .toList();

    try {
      final notifier = widget.ref
          .read(comboMenuListProvider(AppConstants.shopId).notifier);

      if (_isEdit) {
        await notifier.edit(
          comboId: widget.existing!.id,
          shopId: AppConstants.shopId,
          name: _nameCtrl.text.trim(),
          price: double.parse(_priceCtrl.text.trim()),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
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
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
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
    final scheme = Theme.of(context).colorScheme;
    final activeItems =
    widget.menuItems.where((i) => i.isActive).toList();
    final filteredItems = _itemCategoryFilter == null
        ? activeItems
        : activeItems
        .where((i) => i.categoryId == _itemCategoryFilter)
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
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
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isEdit ? 'Edit Combo' : 'New Combo',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  _saving
                      ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2)),
                  )
                      : FilledButton(
                    onPressed: _save,
                    child: Text(_isEdit ? 'Save' : 'Create'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Body
            Flexible(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                      20, 24, 20,
                      MediaQuery.of(context).viewInsets.bottom + 32),
                  children: [
                    // Image picker
                    GestureDetector(
                      onTap: _uploading ? null : _pickImage,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest
                              .withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                            scheme.outlineVariant.withOpacity(0.4),
                          ),
                          image: _imageUrl != null
                              ? DecorationImage(
                              image: NetworkImage(_imageUrl!),
                              fit: BoxFit.cover)
                              : null,
                        ),
                        child: _uploading
                            ? const Center(
                            child: CircularProgressIndicator())
                            : _imageUrl != null
                            ? Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              padding:
                              const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black
                                    .withOpacity(0.5),
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                  Icons.edit_rounded,
                                  size: 16,
                                  color: Colors.white),
                            ),
                          ),
                        )
                            : Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Container(
                              padding:
                              const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: scheme.primary
                                    .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                  Icons
                                      .add_photo_alternate_outlined,
                                  size: 28,
                                  color: scheme.primary),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Tap to add photo',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Name
                    _FormLabel(label: 'Combo Name'),
                    TextFormField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(context,
                          hint: 'e.g. Family Meal',
                          icon: Icons.restaurant_menu_rounded),
                      validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),

                    // Price
                    _FormLabel(label: 'Price'),
                    TextFormField(
                      controller: _priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: _inputDecoration(context,
                          hint: '0.00',
                          icon: Icons.payments_outlined,
                          suffixText: 'MAD'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Required';
                        if (double.tryParse(v.trim()) == null)
                          return 'Invalid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Description
                    _FormLabel(label: 'Description (optional)'),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 2,
                      decoration: _inputDecoration(context,
                          hint: 'Short description…',
                          icon: Icons.notes_rounded),
                    ),
                    const SizedBox(height: 20),

                    // Category
                    _FormLabel(label: 'Category (optional)'),
                    DropdownButtonFormField<String?>(
                      value: _selectedCategoryId,
                      decoration: _inputDecoration(context,
                          hint: 'No category',
                          icon: Icons.category_outlined),
                      items: [
                        const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('— No category —')),
                        ...widget.categories.map((cat) =>
                            DropdownMenuItem<String?>(
                                value: cat.id,
                                child: Text(cat.label))),
                      ],
                      onChanged: (v) =>
                          setState(() => _selectedCategoryId = v),
                    ),
                    const SizedBox(height: 24),

                    // Items section header
                    Row(
                      children: [
                        Text(
                          'INCLUDED ITEMS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: _selectedItems.isNotEmpty
                                ? scheme.primaryContainer
                                : scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_selectedItems.length} selected',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _selectedItems.isNotEmpty
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Item category filter chips
                    if (widget.itemCategories.isNotEmpty) ...[
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.itemCategories.length + 1,
                          separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            if (i == 0) {
                              return _FilterChip(
                                label: 'All',
                                selected: _itemCategoryFilter == null,
                                onTap: () => setState(
                                        () => _itemCategoryFilter = null),
                              );
                            }
                            final cat = widget.itemCategories[i - 1];
                            final sel = _itemCategoryFilter == cat.id;
                            return _FilterChip(
                              label: cat.label,
                              selected: sel,
                              onTap: () => setState(() =>
                              _itemCategoryFilter =
                              sel ? null : cat.id),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Items grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
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
                              ? () =>
                              _showChoiceGroupDialog(item.id)
                              : null,
                          child: AnimatedContainer(
                            duration:
                            const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? scheme.primaryContainer
                                  .withOpacity(0.15)
                                  : scheme.surfaceContainerHighest
                                  .withOpacity(0.5),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? (choiceGroup != null
                                    ? scheme.tertiary
                                    : scheme.primary)
                                    : scheme.outlineVariant
                                    .withOpacity(0.3),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: scheme.primary
                                      .withOpacity(0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                                  : [],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      item.imageUrl != null &&
                                          item.imageUrl!.isNotEmpty
                                          ? CachedMenuImage(
                                          url: item.imageUrl!)
                                          : Container(
                                        color: scheme
                                            .surfaceContainerHighest,
                                        child: Icon(
                                            Icons.fastfood_rounded,
                                            size: 32,
                                            color: scheme
                                                .onSurfaceVariant
                                                .withOpacity(0.4)),
                                      ),
                                      // Quantity badge
                                      if (isSelected)
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: Container(
                                            padding:
                                            const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: choiceGroup != null
                                                  ? scheme.tertiary
                                                  : scheme.primary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '$qty',
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      // Choice group badge
                                      if (isSelected &&
                                          choiceGroup != null)
                                        Positioned(
                                          top: 5,
                                          left: 5,
                                          child: Container(
                                            padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 5,
                                                vertical: 2),
                                            decoration: BoxDecoration(
                                              color: scheme.tertiary,
                                              borderRadius:
                                              BorderRadius.circular(
                                                  5),
                                            ),
                                            child: Text(
                                              choiceGroup,
                                              style: TextStyle(
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                scheme.onTertiary,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 5),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${item.price.toStringAsFixed(2)} MAD',
                                        style: TextStyle(
                                            color: scheme.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                // Quantity stepper
                                if (isSelected)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: scheme.primaryContainer
                                          .withOpacity(0.3),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                      children: [
                                        InkWell(
                                          onTap: qty! > 1
                                              ? () => setState(() =>
                                          _selectedItems[
                                          item.id] = qty - 1)
                                              : null,
                                          child: Padding(
                                            padding:
                                            const EdgeInsets.all(6),
                                            child: Icon(Icons.remove,
                                                size: 16,
                                                color: qty > 1
                                                    ? scheme.primary
                                                    : scheme.outlineVariant),
                                          ),
                                        ),
                                        Text('$qty',
                                            style: const TextStyle(
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize: 13)),
                                        InkWell(
                                          onTap: () => setState(() =>
                                          _selectedItems[item.id] =
                                              qty + 1),
                                          child: Padding(
                                            padding:
                                            const EdgeInsets.all(6),
                                            child: Icon(Icons.add,
                                                size: 16,
                                                color: scheme.primary),
                                          ),
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
                    const SizedBox(height: 10),

                    // Choice group hint
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                        scheme.surfaceContainerHighest.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: scheme.outlineVariant.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 15,
                              color: scheme.onSurfaceVariant),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Long-press a selected item to assign a choice group (e.g. "drink"). Items sharing the same group become pick-one options.',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChoiceGroupDialog(String menuItemId) {
    final scheme = Theme.of(context).colorScheme;
    final ctrl =
    TextEditingController(text: _choiceGroups[menuItemId] ?? '');
    final existingGroups = _choiceGroups.values
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Choice group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Items sharing the same group name become pick-one choices. Leave empty for a fixed item.',
              style: TextStyle(
                  fontSize: 13, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.none,
              decoration: _inputDecoration(ctx,
                  hint: 'e.g. drink, dessert…',
                  icon: Icons.swap_horiz_rounded),
            ),
            if (existingGroups.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: existingGroups
                    .map((g) => ActionChip(
                  label: Text(g),
                  onPressed: () => ctrl.text = g,
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

// ── Combo Categories Sheet ────────────────────────────────────────────────────

class _ComboCategoriesSheet extends StatefulWidget {
  const _ComboCategoriesSheet(
      {required this.ref, required this.categories});
  final WidgetRef ref;
  final List<Category> categories;

  @override
  State<_ComboCategoriesSheet> createState() =>
      _ComboCategoriesSheetState();
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
        .create(
        shopId: AppConstants.shopId,
        label: _controller.text.trim());
    _controller.clear();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final categoriesAsync =
    widget.ref.watch(comboCategoryListProvider(AppConstants.shopId));

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
            // Handle
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
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text('Combo Categories',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    20, 20, 20,
                    MediaQuery.of(context).viewInsets.bottom + 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Add new
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color:
                            scheme.outlineVariant.withOpacity(0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NEW CATEGORY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  textCapitalization:
                                  TextCapitalization.words,
                                  decoration: _inputDecoration(context,
                                      hint: 'Category name',
                                      icon: Icons.label_outline_rounded),
                                  onSubmitted: (_) => _add(),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                height: 50,
                                child: FilledButton(
                                  onPressed: _loading ? null : _add,
                                  child: _loading
                                      ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child:
                                      CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white))
                                      : const Icon(Icons.add_rounded),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Existing categories
                    categoriesAsync.when(
                      loading: () => const Center(
                          child: CircularProgressIndicator()),
                      error: (e, _) => const SizedBox(),
                      data: (cats) {
                        if (cats.isEmpty) {
                          return Center(
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 16),
                              child: Text('No categories yet',
                                  style: TextStyle(
                                      color: scheme.onSurfaceVariant)),
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EXISTING CATEGORIES',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Card(
                              elevation: 0,
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                    color: scheme.outlineVariant
                                        .withOpacity(0.4)),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  for (int i = 0;
                                  i < cats.length;
                                  i++) ...[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding:
                                            const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: scheme.tertiaryContainer
                                                  .withOpacity(0.5),
                                              borderRadius:
                                              BorderRadius.circular(
                                                  10),
                                            ),
                                            child: Icon(
                                                Icons.label_rounded,
                                                size: 18,
                                                color: scheme.tertiary),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(cats[i].label,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                    FontWeight.w500)),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                                Icons
                                                    .delete_outline_rounded,
                                                size: 20,
                                                color: scheme.error),
                                            onPressed: () => widget.ref
                                                .read(comboCategoryListProvider(
                                                AppConstants.shopId)
                                                .notifier)
                                                .deleteCategory(
                                              categoryId: cats[i].id,
                                              shopId:
                                              AppConstants.shopId,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (i < cats.length - 1)
                                      const Divider(height: 1),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}