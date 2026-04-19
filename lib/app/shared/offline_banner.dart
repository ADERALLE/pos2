import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_v1/core/services/connectivity_service.dart';
import 'package:pos_v1/core/services/sync_service.dart';
import 'package:pos_v1/i10n/app_localizations.dart';

/// Drop this anywhere above your page body (e.g. inside a Column above the
/// main content) to show an offline / syncing banner automatically.
///
/// Usage:
///   Column(children: [const OfflineBanner(), Expanded(child: yourPage)])
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online       = ref.watch(isOnlineProvider);
    final pendingAsync = ref.watch(pendingOpsCountProvider);
    final pending      = pendingAsync.value ?? 0;

    // Nothing to show when fully online and nothing queued
    if (online && pending == 0) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final opWord = pending == 1 ? l10n.operation : l10n.operations;

    final (bg, icon, label) = online
        ? (
    Colors.blue.shade700,
    Icons.sync_rounded,
    '${l10n.backOnlineSyncing} $pending $opWord…',
    )
        : (
    Colors.orange.shade700,
    Icons.wifi_off_rounded,
    pending == 0
        ? l10n.offlineNoQueue
        : '${l10n.offline} $pending $opWord ${l10n.queued}',
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (online && pending > 0)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}