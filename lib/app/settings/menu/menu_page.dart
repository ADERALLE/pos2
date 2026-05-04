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
final menuCategoryFilterProvider = StateProvider<String?>((ref) => null);

class MenuPage extends ConsumerWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig().init(context);
    final scheme = Theme.of(context).colorScheme;
    final categoriesAsync = ref.watch(categoryListProvider(AppConstants.shopId));
    final itemsAsync = ref.watch(menuItemListProvider(AppConstants.shopId));
    final selectedCategoryId = ref.watch(menuCategoryFilterProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: const Text('Menu'),
            floating: true,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.category_outlined),
                tooltip: 'Manage categories',
                onPressed: () => _showCategoriesSheet(
                    context, ref, categoriesAsync.value ?? []),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilledButton.icon(
                  onPressed: () =>
                      _showItemForm(context, ref, categoriesAsync.value ?? []),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Item'),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ),

          // ── Category filter chips ──────────────────────────────────────────
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

          // ── Menu items ────────────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig().cardPadd(25),
              vertical: 8,
            ),
            sliver: itemsAsync.when(
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
                      Text(
                        e is PostgrestException
                            ? e.message
                            : 'Something went wrong',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
              data: (items) {
                final filtered = items.where((item) {
                  return selectedCategoryId == null ||
                      item.categoryId == selectedCategoryId;
                }).toList();

                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyState(
                      message: selectedCategoryId != null
                          ? 'No items in this category'
                          : 'No menu items yet',
                      onAdd: () => _showItemForm(
                          context, ref, categoriesAsync.value ?? []),
                    ),
                  );
                }

                // Group items by category
                final grouped = <String, List<MenuItem>>{};
                final catMap = {
                  for (final c in categoriesAsync.value ?? <Category>[])
                    c.id: c
                };

                for (final item in filtered) {
                  final key = item.categoryId ?? '__none__';
                  grouped.putIfAbsent(key, () => []).add(item);
                }

                final sections = grouped.entries.toList();

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final entry = sections[index];
                      final cat = catMap[entry.key];
                      final sectionItems = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(
                              title: cat?.label ?? 'Uncategorised',
                              count: sectionItems.length,
                              isSupp: cat?.isSupp ?? false,
                            ),
                            const SizedBox(height: 8),
                            _MenuCard(
                              children: [
                                for (int i = 0; i < sectionItems.length; i++) ...[
                                  _MenuItemTile(
                                    item: sectionItems[i],
                                    categories: categoriesAsync.value ?? [],
                                  ),
                                  if (i < sectionItems.length - 1)
                                    const Divider(height: 1, indent: 76),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: sections.length,
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

  void _showItemForm(
      BuildContext context, WidgetRef ref, List<Category> categories,
      {MenuItem? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _MenuItemFormSheet(
          categories: categories, existing: existing),
    );
  }

  void _showCategoriesSheet(
      BuildContext context, WidgetRef ref, List<Category> categories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CategoriesSheet(categories: categories),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    this.isSupp = false,
  });
  final String title;
  final int count;
  final bool isSupp;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
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
        if (isSupp) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: scheme.errorContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'SUPP',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: scheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});
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

InputDecoration _sharedInputDecoration(
    BuildContext context, {
      required String hint,
      required IconData icon,
      String? suffixText,
      Widget? suffixWidget,
    }) {
  final scheme = Theme.of(context).colorScheme;
  return InputDecoration(
    hintText: hint,
    suffixText: suffixText,
    suffix: suffixWidget,
    prefixIcon: Icon(icon, size: 20, color: scheme.onSurfaceVariant),
    filled: true,
    fillColor: scheme.surfaceContainerHighest.withOpacity(0.5),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.outlineVariant.withOpacity(0.5)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.outlineVariant.withOpacity(0.4)),
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
  const _EmptyState({required this.message, required this.onAdd});
  final String message;
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
        Text(
          message,
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface),
        ),
        const SizedBox(height: 8),
        Text('Tap below to add your first item',
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add Menu Item'),
        ),
      ],
    );
  }
}

// ── Category filter chips ─────────────────────────────────────────────────────

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips({required this.categories, this.selectedId});
  final List<Category> categories;
  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categories.isEmpty) return const SizedBox();
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
              onTap: () =>
              ref.read(menuCategoryFilterProvider.notifier).state = null,
            );
          }
          final cat = categories[i - 1];
          final selected = selectedId == cat.id;
          return _FilterChip(
            label: cat.label,
            selected: selected,
            isSupp: cat.isSupp,
            onTap: () => ref.read(menuCategoryFilterProvider.notifier).state =
            selected ? null : cat.id,
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.isSupp = false,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isSupp;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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

// ── Menu Item Tile ────────────────────────────────────────────────────────────

class _MenuItemTile extends ConsumerWidget {
  const _MenuItemTile({required this.item, required this.categories});
  final MenuItem item;
  final List<Category> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final category =
        categories.where((c) => c.id == item.categoryId).firstOrNull;

    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => _MenuItemFormSheet(
            categories: categories, existing: item),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 52,
                height: 52,
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? Image.network(
                  item.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _ItemImagePlaceholder(scheme: scheme),
                )
                    : _ItemImagePlaceholder(scheme: scheme),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        '${item.price.toStringAsFixed(2)} MAD',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                        ),
                      ),
                      if (!item.isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: scheme.errorContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Inactive',
                            style: TextStyle(
                              fontSize: 10,
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
            // Actions
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
              icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
              tooltip: 'Remove',
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove menu item?'),
        content: Text(
            'This will permanently remove "${item.name}" from the menu.'),
        actions: [
          TextButton(
              onPressed: () {
                FocusScope.of(context).unfocus();

                Navigator.of(context, rootNavigator: true).pop();
              },
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: scheme.error),
            onPressed: () {
              ref
                  .read(menuItemListProvider(AppConstants.shopId).notifier)
                  .deleteItem(
                  itemId: item.id, shopId: AppConstants.shopId);
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _ItemImagePlaceholder extends StatelessWidget {
  const _ItemImagePlaceholder({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: scheme.surfaceContainerHighest,
      child: Icon(Icons.fastfood_rounded,
          size: 24, color: scheme.onSurfaceVariant.withOpacity(0.5)),
    );
  }
}

// ── Menu Item Form Sheet ──────────────────────────────────────────────────────

class _MenuItemFormSheet extends ConsumerStatefulWidget {
  const _MenuItemFormSheet({
    required this.categories,
    this.existing,
  });
  final List<Category> categories;
  final MenuItem? existing;

  @override
  ConsumerState<_MenuItemFormSheet> createState() => _MenuItemFormSheetState();
}

class _MenuItemFormSheetState extends ConsumerState<_MenuItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  String? _categoryId;
  bool _loading = false;
  File? _imageFile;
  final _picker = ImagePicker();

  bool get _isEdit => widget.existing != null;

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
      imageUrl = await ref
          .read(storageRepositoryProvider)
          .uploadMenuImage(file: _imageFile!, shopId: AppConstants.shopId);
    }

    final notifier =
    ref.read(menuItemListProvider(AppConstants.shopId).notifier);
    final price = double.parse(_priceController.text.trim());

    if (!_isEdit) {
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
    final scheme = Theme.of(context).colorScheme;

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
                    _isEdit ? 'Edit Menu Item' : 'Add Menu Item',
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
                        CircularProgressIndicator(strokeWidth: 2)),
                  )
                      : FilledButton(
                    onPressed: _submit,
                    child: Text(_isEdit ? 'Save' : 'Add'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    20, 24, 20,
                    MediaQuery.of(context).viewInsets.bottom + 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image picker
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 160,
                          decoration: BoxDecoration(
                            color:
                            scheme.surfaceContainerHighest.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: scheme.outlineVariant.withOpacity(0.4),
                            ),
                            image: _imageFile != null
                                ? DecorationImage(
                                image: FileImage(_imageFile!),
                                fit: BoxFit.cover)
                                : widget.existing?.imageUrl != null
                                ? DecorationImage(
                                image: NetworkImage(
                                    widget.existing!.imageUrl!),
                                fit: BoxFit.cover)
                                : null,
                          ),
                          child: _imageFile == null &&
                              widget.existing?.imageUrl == null
                              ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: scheme.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                    Icons.add_photo_alternate_outlined,
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
                          )
                              : Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                    Icons.edit_rounded,
                                    size: 16,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Name
                      _FormLabel(label: 'Item Name'),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: _sharedInputDecoration(context,
                            hint: 'e.g. Chicken Burger',
                            icon: Icons.fastfood_rounded),
                        validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),

                      // Price
                      _FormLabel(label: 'Price'),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: _sharedInputDecoration(context,
                            hint: '0.00',
                            icon: Icons.payments_outlined,
                            suffixText: 'MAD'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (double.tryParse(v.trim()) == null)
                            return 'Invalid price';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Category
                      _FormLabel(label: 'Category'),
                      DropdownButtonFormField<String?>(
                        value: _categoryId,
                        decoration: _sharedInputDecoration(context,
                            hint: 'Select a category',
                            icon: Icons.category_outlined),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('No category')),
                          ...widget.categories.map((c) => DropdownMenuItem(
                              value: c.id, child: Text(c.label))),
                        ],
                        onChanged: (v) => setState(() => _categoryId = v),
                      ),
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
}

// ── Categories Management Sheet ───────────────────────────────────────────────

class _CategoriesSheet extends ConsumerStatefulWidget {
  const _CategoriesSheet({required this.categories});
  final List<Category> categories;

  @override
  ConsumerState<_CategoriesSheet> createState() => _CategoriesSheetState();
}

class _CategoriesSheetState extends ConsumerState<_CategoriesSheet> {
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
    await ref
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
    final scheme = Theme.of(context).colorScheme;
    final categoriesAsync =
    ref.watch(categoryListProvider(AppConstants.shopId));

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
            // Header
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text('Categories',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    20, 20, 20,
                    MediaQuery.of(context).viewInsets.bottom + 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Add new category
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: scheme.outlineVariant.withOpacity(0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ADD NEW CATEGORY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  textCapitalization:
                                  TextCapitalization.words,
                                  decoration: _sharedInputDecoration(context,
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
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white))
                                      : const Icon(Icons.add_rounded),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Supplement toggle
                          Container(
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color:
                                  scheme.outlineVariant.withOpacity(0.4)),
                            ),
                            child: SwitchListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              title: const Text('Supplement category',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              subtitle: const Text(
                                  'Items cannot be ordered alone',
                                  style: TextStyle(fontSize: 12)),
                              value: _isSupp,
                              onChanged: (v) => setState(() => _isSupp = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Existing categories
                    categoriesAsync.when(
                      loading: () =>
                      const Center(child: CircularProgressIndicator()),
                      error: (e, _) => const SizedBox(),
                      data: (cats) {
                        if (cats.isEmpty) {
                          return Center(
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'No categories yet',
                                style: TextStyle(
                                    color: scheme.onSurfaceVariant),
                              ),
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
                                  color:
                                  scheme.outlineVariant.withOpacity(0.4),
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  for (int i = 0; i < cats.length; i++) ...[
                                    _CategoryListTile(
                                      category: cats[i],
                                      onEdit: () =>
                                          _showEditDialog(context, cats[i]),
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

  // FIX: `scheme` is now derived from the dialog's own `ctx` (inside builder),
  // not from the sheet's build context which may be deactivated when the
  // keyboard opens and triggers a sheet resize/rebuild.
  Future<void> _showEditDialog(
      BuildContext context, Category category) async {
    final labelCtrl = TextEditingController(text: category.label);
    bool isSupp = category.isSupp;
    bool saving = false;

    await showDialog(
      context: context,
      useRootNavigator: true,
      builder: (ctx) {
        // ↓ Moved here — uses ctx (dialog's context), not the sheet's context
        final scheme = Theme.of(ctx).colorScheme;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text('Edit category'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: labelCtrl,
                    decoration: _sharedInputDecoration(ctx,
                        hint: 'Category name',
                        icon: Icons.label_outline_rounded),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: scheme.outlineVariant.withOpacity(0.4)),
                    ),
                    child: SwitchListTile(
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      title: const Text('Supplement',
                          style: TextStyle(fontSize: 14)),
                      value: isSupp,
                      onChanged: (v) => setDialogState(() => isSupp = v),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    FocusScope.of(ctx).unfocus();

                    Navigator.of(ctx, rootNavigator: true).pop();
                  },
                  child: const Text('Cancel')),
              FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                  if (labelCtrl.text.trim().isEmpty) return;
                  setDialogState(() => saving = true);
                  await ref
                      .read(categoryListProvider(AppConstants.shopId)
                      .notifier)
                      .editCategory(
                    categoryId: category.id,
                    shopId: AppConstants.shopId,
                    label: labelCtrl.text.trim(),
                    isSupp: isSupp,
                  );
                  if (ctx.mounted)
                    Navigator.of(ctx, rootNavigator: true).pop();
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
        );
      },
    );
    labelCtrl.dispose();
  }
}

class _CategoryListTile extends ConsumerWidget {
  const _CategoryListTile({
    required this.category,
    required this.onEdit,
  });
  final Category category;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.label_rounded,
                size: 18, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Text(category.label,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500)),
                if (category.isSupp) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: scheme.errorContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'SUPP',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: scheme.error,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 20, color: scheme.primary),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded,
                size: 20, color: scheme.error),
            onPressed: () => ref
                .read(categoryListProvider(AppConstants.shopId).notifier)
                .deleteCategory(
              categoryId: category.id,
              shopId: AppConstants.shopId,
            ),
          ),
        ],
      ),
    );
  }
}