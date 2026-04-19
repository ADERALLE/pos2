import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_v1/app/shared/payment_dialog.dart';
import 'package:pos_v1/core/appconstants.dart';
import 'package:pos_v1/core/models/staff.dart';
import 'package:pos_v1/core/viewmodels/auth_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/order_viewmodel.dart';
import 'package:pos_v1/core/viewmodels/shift_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pos_v1/core/models/order.dart';
import 'package:pos_v1/core/models/order_item.dart';
import '../../core/models/size_config.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig().cardPadd(25)),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              title: const Text('Orders', style: TextStyle(fontWeight: FontWeight.bold)),
              pinned: true,
              floating: true,
              elevation: 0,
              scrolledUnderElevation: 2,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search_rounded),
                  tooltip: 'Search orders',
                  onPressed: () {
                    final staff = ref.read(currentStaffProvider)!;
                    final isManager = staff.role == StaffRole.manager;
                    showSearch(
                      context: context,
                      delegate: _OrderSearchDelegate(
                        shopId: isManager ? AppConstants.shopId : null,
                        cashierId: isManager ? null : staff.id,
                        providerContainer: ProviderScope.containerOf(context),
                      ),
                    );
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tab,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelColor: scheme.onPrimary,
                      unselectedLabelColor: scheme.onSurfaceVariant,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Active Orders'),
                        Tab(text: 'History'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: 16, bottom: 32),
              sliver: SliverFillRemaining(
                child: TabBarView(
                  controller: _tab,
                  children: const [
                    _ActiveOrdersTab(),
                    _OrderHistoryTab(),
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

// ── active orders ─────────────────────────────────────────────────────────────

class _ActiveOrdersTab extends ConsumerWidget {
  const _ActiveOrdersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = ref.watch(currentStaffProvider)!;
    final isManager = staff.role == StaffRole.manager;
    print(staff);

    final ordersAsync = isManager
        ? ref.watch(activeOrdersProvider(AppConstants.shopId))
        : ref.watch(myActiveOrdersProvider(staff.id));

    return ordersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(e is PostgrestException ? e.message : 'Error'),
      ),
      data: (orders) => orders.isEmpty
          ? const _EmptyState(icon: Icons.receipt_long, message: 'No active orders')
          : ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: orders.length,
        itemBuilder: (_, i) => _OrderCard(order: orders[i],),
      ),
    );
  }
}

// ── order history ─────────────────────────────────────────────────────────────

class _OrderHistoryTab extends ConsumerStatefulWidget {
  const _OrderHistoryTab();

  @override
  ConsumerState<_OrderHistoryTab> createState() => _OrderHistoryTabState();
}

class _OrderHistoryTabState extends ConsumerState<_OrderHistoryTab> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final staff = ref.read(currentStaffProvider)!;
    final isManager = staff.role == StaffRole.manager;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (isManager) {
        ref.read(shopOrderHistoryProvider(AppConstants.shopId).notifier)
            .loadMore(AppConstants.shopId);
      } else {
        ref.read(myOrderHistoryProvider(staff.id).notifier)
            .loadMore(staff.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(currentStaffProvider)!;
    final isManager = staff.role == StaffRole.manager;

    final ordersAsync = isManager
        ? ref.watch(shopOrderHistoryProvider(AppConstants.shopId))
        : ref.watch(myOrderHistoryProvider(staff.id));

    return ordersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(e is PostgrestException ? e.message : 'Error'),
      ),
      data: (orders) => orders.isEmpty
          ? const Center(child: Text('No order history'))
          : ListView.separated(
        controller: _scrollController,
        itemCount: orders.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) => _OrderCard(order: orders[i], readonly: true),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64, color: scheme.onSurface.withOpacity(0.2)),
        const SizedBox(height: 16),
        Text(
          message,
          style: TextStyle(
            color: scheme.onSurface.withOpacity(0.5),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── order card ────────────────────────────────────────────────────────────────

class _OrderCard extends ConsumerWidget {
  const _OrderCard({required this.order, this.readonly = false, this.query = ''});
  final Order order;
  final bool readonly;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final staff = ref.watch(currentStaffProvider)!;
    final isManager = staff.role == StaffRole.manager;
    final statusColor = switch (order.status) {
      OrderStatus.pending    => Colors.orange,
      OrderStatus.inprogress => Colors.blue,
      OrderStatus.done       => Colors.green,
      OrderStatus.cancelled  => Colors.red,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withOpacity(0.4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.receipt_long_rounded, color: statusColor, size: 24),
          ),
          title: _HighlightText(
            text: order.tableLabel ?? '#${order.id.substring(order.id.length - 6).toUpperCase()}',
            query: query,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isManager && order.cashierName != null)
                  Row(
                    children: [
                      Icon(Icons.person_rounded, size: 12, color: scheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        order.cashierName!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                Text(
                  '${order.orderItems.length} items · ${order.total.toStringAsFixed(2)} MAD',
                  style: TextStyle(fontSize: 13, color: scheme.onSurface.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          trailing: readonly
              ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: statusColor.withOpacity(0.2)),
            ),
            child: Text(
              order.status.name.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 0.5,
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green.withOpacity(0.1),
                ),
                icon: Icon(Icons.check_rounded, color: Colors.green.shade700, size: 20),
                tooltip: 'Mark Done',
                onPressed: () => PaymentDialog.show(
                  context: context,
                  total: order.total,
                  onConfirm: (payment) async {
                    if (isManager) {
                      await ref.read(activeOrdersProvider(AppConstants.shopId).notifier)
                          .markDone(order.id, AppConstants.shopId, payment: payment);
                    } else {
                      await ref.read(myActiveOrdersProvider(staff.id).notifier)
                          .markDone(order.id, staff.id, payment: payment);
                    }
                    if (query.isNotEmpty) {
                      ref.read(orderSearchProvider.notifier).search(
                        query,
                        shopId: isManager ? AppConstants.shopId : null,
                        cashierId: isManager ? null : staff.id,
                      );
                    }
                  },
                ),
              ),
              if (isManager) ...[
                const SizedBox(width: 8),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                  ),
                  icon: Icon(Icons.close_rounded, color: Colors.red.shade700, size: 20),
                  tooltip: 'Cancel Order',
                  onPressed: () {
                    if (isManager) {
                      ref.read(activeOrdersProvider(AppConstants.shopId).notifier)
                          .cancel(order.id, AppConstants.shopId);
                    } else {
                      ref.read(myActiveOrdersProvider(staff.id).notifier)
                          .cancel(order.id, staff.id);
                    }
                    if (query.isNotEmpty) {
                      ref.read(orderSearchProvider.notifier).search(
                        query,
                        shopId: isManager ? AppConstants.shopId : null,
                        cashierId: isManager ? null : staff.id,
                      );
                    }
                  },
                ),
              ],
            ],
          ),
          children: [
            Container(
              color: scheme.surfaceContainerHighest.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _OrderItemsGrouped(orderItems: order.orderItems),
            ),
          ],
        ),
      ),
    );
  }
}

// ── grouped order items (combo-aware) ─────────────────────────────────────────

const _comboSeparator = ' \u2013 '; // " – " used in order_viewmodel

class _OrderItemsGrouped extends StatelessWidget {
  const _OrderItemsGrouped({required this.orderItems});
  final List<OrderItem> orderItems;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Partition items: those whose name contains " – " belong to a combo,
    // others are standalone.
    final List<Widget> rows = [];
    final Map<String, List<OrderItem>> comboGroups = {};
    final List<OrderItem> standaloneItems = [];

    for (final item in orderItems) {
      final sepIdx = item.name.indexOf(_comboSeparator);
      if (sepIdx > 0) {
        final comboName = item.name.substring(0, sepIdx);
        comboGroups.putIfAbsent(comboName, () => []).add(item);
      } else {
        standaloneItems.add(item);
      }
    }

    // Render combo groups
    for (final entry in comboGroups.entries) {
      final comboName = entry.key;
      final items = entry.value;
      // The combo price is stored on the last item of the group (see order_viewmodel).
      final comboPrice = items.fold<double>(0, (s, i) => s + i.unitPrice * i.quantity);

      rows.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.tertiary.withOpacity(0.35)),
            color: scheme.tertiaryContainer.withOpacity(0.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Combo header
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: scheme.tertiary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'COMBO',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: scheme.onTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        comboName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      '${comboPrice.toStringAsFixed(2)} MAD',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, indent: 14, endIndent: 14),
              // Individual items inside the combo
              ...items.map((item) {
                final subName = item.name.substring(
                    item.name.indexOf(_comboSeparator) + _comboSeparator.length);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  child: Row(
                    children: [
                      Text(
                        '${item.quantity}x',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: scheme.primary.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          subName,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 6),
            ],
          ),
        ),
      );
    }

    // Render standalone items
    for (final item in standaloneItems) {
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.quantity}x',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (item.orderNotes.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Notes: ${item.orderNotes.map((n) => n.note).join(', ')}',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: scheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '${(item.unitPrice * item.quantity).toStringAsFixed(2)} MAD',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }
}

// ── search delegate ───────────────────────────────────────────────────────────

class _OrderSearchDelegate extends SearchDelegate<Order?> {
  _OrderSearchDelegate({required this.shopId, required this.cashierId, required this.providerContainer});
  final String? shopId;
  final String? cashierId;
  final ProviderContainer providerContainer;

  @override
  String get searchFieldLabel => 'Search by order ID…';

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        icon: const Icon(Icons.clear_rounded),
        onPressed: () {
          query = '';
          providerContainer.read(orderSearchProvider.notifier).search('');
        },
      ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back_rounded),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildSuggestions(BuildContext context) {
    Future.microtask(() => providerContainer.read(orderSearchProvider.notifier).search(
      query,
      shopId: shopId,
      cashierId: cashierId,
    ));
    return _buildBody(context);
  }

  @override
  Widget buildResults(BuildContext context) => _buildBody(context);

  Widget _buildBody(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (query.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, size: 56, color: scheme.onSurface.withOpacity(0.2)),
            const SizedBox(height: 12),
            Text('Type to search orders',
                style: TextStyle(color: scheme.onSurface.withOpacity(0.4))),
          ],
        ),
      );
    }

    return Consumer(
      builder: (context, ref, _) {
        final searchAsync = ref.watch(orderSearchProvider);
        return searchAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (orders) {
            if (orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 56,
                        color: scheme.onSurface.withOpacity(0.2)),
                    const SizedBox(height: 12),
                    Text('No orders match "$query"',
                        style: TextStyle(color: scheme.onSurface.withOpacity(0.4))),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final order = orders[i];
                final isDone = order.status == OrderStatus.done || order.status == OrderStatus.cancelled;
                return _OrderCard(order: order, readonly: isDone, query: query);
              },
            );
          },
        );
      },
    );
  }
}

// ── highlight matching text ───────────────────────────────────────────────────

class _HighlightText extends StatelessWidget {
  const _HighlightText({required this.text, required this.query, required this.style});
  final String text;
  final String query;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (query.isEmpty) return Text(text, style: style);
    final lower = text.toLowerCase();
    final lowerQ = query.toLowerCase();
    final index = lower.indexOf(lowerQ);
    if (index == -1) return Text(text, style: style);
    return Text.rich(TextSpan(children: [
      if (index > 0) TextSpan(text: text.substring(0, index), style: style),
      TextSpan(
        text: text.substring(index, index + query.length),
        style: style.copyWith(
          color: scheme.primary,
          backgroundColor: scheme.primary.withOpacity(0.12),
          fontWeight: FontWeight.w800,
        ),
      ),
      if (index + query.length < text.length)
        TextSpan(text: text.substring(index + query.length), style: style),
    ]));
  }
}