import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/appconstants.dart';
import '../../../core/models/size_config.dart';
import '../../../core/models/staff.dart';
import '../../../core/viewmodels/staff_viewmodel.dart';

class StaffListPage extends ConsumerWidget {
  const StaffListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig().init(context);
    final staffAsync = ref.watch(staffListProvider(AppConstants.shopId));

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStaffForm(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig().cardPadd(25)),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverAppBar(
                title: Text('Staff'),
                floating: true,
                pinned: true,
              ),
              staffAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) {
                  print(e);
                  return SliverFillRemaining(
                  child: Center(child: Text('Error: $e')),
                );
                },
                data: (staffList) {
                  return staffList.isEmpty
                    ? const SliverFillRemaining(
                  child: Center(child: Text('No staff yet')),
                )
                    : SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, i) => Column(
                      children: [
                        _StaffTile(staff: staffList[i]),
                        const Divider(height: 1),
                      ],
                    ),
                    childCount: staffList.length,
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

  void _showStaffForm(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _StaffFormSheet(ref: ref),
    );
  }
}

class _StaffTile extends ConsumerWidget {
  const _StaffTile({required this.staff});
  final Staff staff;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: CircleAvatar(child: Text(staff.name[0].toUpperCase())),
      title: Text(staff.name),
      subtitle: Text(staff.role.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: staff.isActive,
            onChanged: (val) => ref
                .read(staffListProvider(AppConstants.shopId).notifier)
                .update2(
              staffId: staff.id,
              shopId: AppConstants.shopId,
              isActive: val,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => _StaffFormSheet(ref: ref, existing: staff),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete staff?'),
        content: Text('Remove ${staff.name} from the team?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(staffListProvider(AppConstants.shopId).notifier)
                  .delete(
                staffId: staff.id,
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

class _StaffFormSheet extends StatefulWidget {
  const _StaffFormSheet({required this.ref, this.existing});
  final WidgetRef ref;
  final Staff? existing;

  @override
  State<_StaffFormSheet> createState() => _StaffFormSheetState();
}

class _StaffFormSheetState extends State<_StaffFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _pinController;
  late StaffRole _role;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name);
    _pinController = TextEditingController(text: widget.existing?.pin);
    _role = widget.existing?.role ?? StaffRole.cashier;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final notifier =
    widget.ref.read(staffListProvider(AppConstants.shopId).notifier);

    if (widget.existing == null) {
      await notifier.create(
        shopId: AppConstants.shopId,
        name: _nameController.text.trim(),
        role: _role,
        pin: _pinController.text.trim().isEmpty
            ? null
            : _pinController.text.trim(),
      );
    } else {
      await notifier.update2(
        staffId: widget.existing!.id,
        shopId: AppConstants.shopId,
        name: _nameController.text.trim(),
        role: _role,
        pin: _pinController.text.trim().isEmpty
            ? null
            : _pinController.text.trim(),
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit staff' : 'Add staff'),
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
            16, 16, 16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<StaffRole>(
              value: _role,
              decoration: const InputDecoration(labelText: 'Role'),
              items: StaffRole.values
                  .map((r) => DropdownMenuItem(
                value: r,
                child: Text(r.name),
              ))
                  .toList(),
              onChanged: (v) => setState(() => _role = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pinController,
              decoration: const InputDecoration(
                labelText: 'PIN (optional)',
                hintText: '4-digit PIN',
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEdit ? 'Save' : 'Add'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
