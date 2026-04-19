import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos_v1/core/repositories/storage_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/appconstants.dart';
import '../../../core/models/category.dart';
import '../../../core/models/menu_item.dart';
import '../../../core/models/size_config.dart';
import '../../../core/viewmodels/menu_viewmodel.dart';

// ── State Provider for Category Filtering ────────────────────────────────────
// Tracks the currently selected category ID. Null represents "All".
final menuCategoryFilterProvider = StateProvider<String?>((ref) => null);

class MenuPage extends ConsumerWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig().init(context);
    final categoriesAsync = ref.watch(categoryListProvider(AppConstants.shopId));
    final itemsAsync = ref.watch(menuItemListProvider(AppConstants.shopId));

    // Watch the selected filter state
    final selectedCategoryId = ref.watch(menuCategoryFilterProvider);

    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig().cardPadd(25)),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                title: const Text('Menu', style: TextStyle(fontWeight: FontWeight.bold)),
                floating: true,
                pinned: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.category_outlined),
                    tooltip: 'Manage categories',
                    onPressed: () => _showCategoriesSheet(
                        context, ref, categoriesAsync.value ?? []),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showItemForm(
                        context, ref, categoriesAsync.value ?? []),
                  ),
                ],
              ),
              // Category filter chips
              categoriesAsync.when(
                loading: () => const SliverToBoxAdapter(child: SizedBox()),
                error: (e, _) => const SliverToBoxAdapter(child: SizedBox()),
                data: (cats) => SliverToBoxAdapter(
                  child: _CategoryChips(
                    categories: cats,
                    selectedId: selectedCategoryId,
                  ),
                ),
              ),
              // Menu items list
              itemsAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: Center(
                    child: Text(
                      e is PostgrestException ? e.message : 'Something went wrong',
                    ),
                  ),
                ),
                data: (items) {
                  // Filter items based on the selected category
                  final filteredItems = items.where((item) {
                    return selectedCategoryId == null || item.categoryId == selectedCategoryId;
                  }).toList();

                  if (filteredItems.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(child: Text('No items found in this category')),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, i) => _MenuItemTile(
                        item: filteredItems[i],
                        categories: categoriesAsync.value ?? [],
                      ),
                      childCount: filteredItems.length,
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

  void _showItemForm(
      BuildContext context, WidgetRef ref, List<Category> categories,
      {MenuItem? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _MenuItemFormSheet(ref: ref, categories: categories, existing: existing),
    );
  }

  void _showCategoriesSheet(
      BuildContext context, WidgetRef ref, List<Category> categories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CategoriesSheet(ref: ref, categories: categories),
    );
  }
}

// ── category filter chips ───────────────────────────────────────────────────

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips({required this.categories, this.selectedId});
  final List<Category> categories;
  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categories.isEmpty) return const SizedBox();

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        // +1 for the "All" chip
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (i == 0) {
            final isSelected = selectedId == null;
            return ChoiceChip(
              label: const Text('All'),
              selected: isSelected,
              onSelected: (_) => ref.read(menuCategoryFilterProvider.notifier).state = null,
            );
          }

          final cat = categories[i - 1];
          final isSelected = selectedId == cat.id;

          return ChoiceChip(
            label: Text(cat.label),
            selected: isSelected,
            onSelected: (selected) {
              // Toggle: if already selected, clicking again de-selects it (sets to null/All)
              ref.read(menuCategoryFilterProvider.notifier).state = isSelected ? null : cat.id;
            },
          );
        },
      ),
    );
  }
}

// ── menu item tile ──────────────────────────────────────────────────────────

class _MenuItemTile extends ConsumerWidget {
  const _MenuItemTile({required this.item, required this.categories});
  final MenuItem item;
  final List<Category> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = categories.where((c) => c.id == item.categoryId).firstOrNull;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          ListTile(
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(category?.label ?? 'No category'),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(
                item.imageUrl!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
              )
                  : _buildPlaceholder(theme),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${item.price.toStringAsFixed(2)} MAD',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: item.isActive,
                  onChanged: (val) => ref
                      .read(menuItemListProvider(AppConstants.shopId).notifier)
                      .editItem(
                    itemId: item.id,
                    shopId: AppConstants.shopId,
                    isActive: val,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => _MenuItemFormSheet(
                      ref: ref,
                      categories: categories,
                      existing: item,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(context, ref),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      width: 50,
      height: 50,
      color: theme.colorScheme.surfaceVariant,
      child: const Icon(Icons.fastfood, size: 24),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('Remove "${item.name}" from the menu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(menuItemListProvider(AppConstants.shopId).notifier)
                  .deleteItem(
                itemId: item.id,
                shopId: AppConstants.shopId,
              );
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ── menu item form ──────────────────────────────────────────────────────────

class _MenuItemFormSheet extends StatefulWidget {
  const _MenuItemFormSheet({
    required this.ref,
    required this.categories,
    this.existing,
  });
  final WidgetRef ref;
  final List<Category> categories;
  final MenuItem? existing;

  @override
  State<_MenuItemFormSheet> createState() => _MenuItemFormSheetState();
}

class _MenuItemFormSheetState extends State<_MenuItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  String? _categoryId;
  bool _loading = false;
  File? _imageFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name);
    _priceController = TextEditingController(
        text: widget.existing?.price.toStringAsFixed(2) ?? '');
    _categoryId = widget.existing?.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    String? imageUrl = widget.existing?.imageUrl;

    if (_imageFile != null) {
      imageUrl = await widget.ref.read(storageRepositoryProvider).uploadMenuImage(
        file: _imageFile!,
        shopId: AppConstants.shopId,
      );
    }

    final notifier =
    widget.ref.read(menuItemListProvider(AppConstants.shopId).notifier);
    final price = double.parse(_priceController.text.trim());

    if (widget.existing == null) {
      await notifier.create(
        shopId: AppConstants.shopId,
        name: _nameController.text.trim(),
        price: price,
        categoryId: _categoryId,
        imageUrl: imageUrl,
      );
    } else {
      await notifier.editItem(
        itemId: widget.existing!.id,
        shopId: AppConstants.shopId,
        name: _nameController.text.trim(),
        price: price,
        categoryId: _categoryId,
        imageUrl: imageUrl,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
      requestFullMetadata: false,
    );
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit item' : 'Add item'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _loading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: _submit,
                  child: Text(
                    isEdit ? 'Save' : 'Add',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Text(isEdit ? 'Edit item' : 'Add item',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  image: _imageFile != null
                      ? DecorationImage(
                    image: FileImage(_imageFile!),
                    fit: BoxFit.cover,
                  )
                      : widget.existing?.imageUrl != null
                      ? DecorationImage(
                    image: NetworkImage(widget.existing!.imageUrl!),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: _imageFile == null && widget.existing?.imageUrl == null
                    ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 36),
                    SizedBox(height: 8),
                    Text('Tap to add image'),
                  ],
                )
                    : Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.black54,
                      child: const Icon(Icons.edit, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                  labelText: 'Price', suffixText: 'MAD'),
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (double.tryParse(v.trim()) == null) return 'Invalid price';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              value: _categoryId,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                const DropdownMenuItem(value: null, child: Text('None')),
                ...widget.categories.map((c) =>
                    DropdownMenuItem(value: c.id, child: Text(c.label))),
              ],
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(isEdit ? 'Save' : 'Add'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── categories management sheet ─────────────────────────────────────────────

class _CategoriesSheet extends StatefulWidget {
  const _CategoriesSheet({required this.ref, required this.categories});
  final WidgetRef ref;
  final List<Category> categories;

  @override
  State<_CategoriesSheet> createState() => _CategoriesSheetState();
}

class _CategoriesSheetState extends State<_CategoriesSheet> {
  final _controller = TextEditingController();
  bool _loading = false;
  bool _isSupp = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _loading = true);
    await widget.ref
        .read(categoryListProvider(AppConstants.shopId).notifier)
        .create(
          shopId: AppConstants.shopId,
          label: _controller.text.trim(),
          isSupp: _isSupp,
        );
    _controller.clear();
    setState(() {
      _loading = false;
      _isSupp = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync =
        widget.ref.watch(categoryListProvider(AppConstants.shopId));
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Categories', style: theme.textTheme.titleLarge),
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
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Supplement category'),
            subtitle: const Text('Items in this category cannot be ordered alone'),
            value: _isSupp,
            onChanged: (v) => setState(() => _isSupp = v),
          ),
          const SizedBox(height: 12),
          categoriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const SizedBox(),
            data: (cats) => Column(
              children: cats
                  .map((c) => ListTile(
                        title: Row(
                          children: [
                            Text(c.label),
                            if (c.isSupp) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'SUPP',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _showEditDialog(context, c),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => widget.ref
                                  .read(categoryListProvider(AppConstants.shopId)
                                      .notifier)
                                  .deleteCategory(
                                    categoryId: c.id,
                                    shopId: AppConstants.shopId,
                                  ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, Category category) async {
    final labelCtrl = TextEditingController(text: category.label);
    bool isSupp = category.isSupp;
    bool saving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: labelCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Supplement category'),
                  value: isSupp,
                  onChanged: (v) => setDialogState(() => isSupp = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (labelCtrl.text.trim().isEmpty) return;
                      setDialogState(() => saving = true);
                      await widget.ref
                          .read(categoryListProvider(AppConstants.shopId)
                              .notifier)
                          .editCategory(
                            categoryId: category.id,
                            shopId: AppConstants.shopId,
                            label: labelCtrl.text.trim(),
                            isSupp: isSupp,
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
              child: saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
    labelCtrl.dispose();
  }
}
}