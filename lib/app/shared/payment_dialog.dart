import 'package:flutter/material.dart';
import 'package:pos_v1/i10n/app_localizations.dart';

/// Result of a completed payment dialog.
class PaymentResult {
  const PaymentResult({
    required this.paymentMethod,
    required this.cashAmount,
    required this.cardAmount,
    required this.tip,
  });

  /// 'cash' | 'card' | 'split'
  final String paymentMethod;
  final double cashAmount;
  final double cardAmount;

  /// Tips are always card-side only.
  final double tip;
}

class PaymentDialog extends StatefulWidget {
  const PaymentDialog({super.key, required this.total, required this.onConfirm});
  final double total;
  final Future<void> Function(PaymentResult result) onConfirm;

  static Future<void> show({
    required BuildContext context,
    required double total,
    required Future<void> Function(PaymentResult result) onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (_) => PaymentDialog(total: total, onConfirm: onConfirm),
    );
  }

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  /// 'cash' | 'card' | 'split'
  String _mode = 'cash';

  // split-mode controllers
  final _cashCtrl = TextEditingController(text: '0');
  final _cardCtrl = TextEditingController(text: '0');
  final _tipCtrl  = TextEditingController(text: '0');

  bool _cardConfirmed = false;
  bool _loading = false;

  @override
  void dispose() {
    _cashCtrl.dispose();
    _cardCtrl.dispose();
    _tipCtrl.dispose();
    super.dispose();
  }

  // ── derived values ──────────────────────────────────────────────────────────

  double get _splitCash => double.tryParse(_cashCtrl.text.trim()) ?? 0.0;
  double get _splitCard => double.tryParse(_cardCtrl.text.trim()) ?? 0.0;
  double get _splitSum  => _splitCash + _splitCard;

  bool get _splitBalanced =>
      (_splitSum - widget.total).abs() < 0.01;

  bool get _canSubmit {
    if (_loading) return false;
    switch (_mode) {
      case 'cash':  return true;
      case 'card':  return _cardConfirmed;
      case 'split': return _cardConfirmed && _splitBalanced;
    }
    return false;
  }

  // ── helpers ─────────────────────────────────────────────────────────────────

  /// Pre-fill the split fields so they sum to total.
  void _prefillSplit() {
    final total = widget.total;
    _cashCtrl.text = total.toStringAsFixed(2);
    _cardCtrl.text = '0.00';
    _tipCtrl.text  = '0';
  }

  /// Rebalance card amount whenever cash changes so sum == total.
  void _onCashChanged(String val) {
    final cash = double.tryParse(val) ?? 0.0;
    final card = (widget.total - cash).clamp(0.0, widget.total);
    _cardCtrl.text = card.toStringAsFixed(2);
    setState(() {});
  }

  /// Rebalance cash amount whenever card changes so sum == total.
  void _onCardChanged(String val) {
    final card = double.tryParse(val) ?? 0.0;
    final cash = (widget.total - card).clamp(0.0, widget.total);
    _cashCtrl.text = cash.toStringAsFixed(2);
    setState(() {});
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    final tip = _mode != 'cash'
        ? (double.tryParse(_tipCtrl.text.trim()) ?? 0.0)
        : 0.0;

    late final PaymentResult result;
    switch (_mode) {
      case 'cash':
        result = PaymentResult(
          paymentMethod: 'cash',
          cashAmount: widget.total,
          cardAmount: 0,
          tip: 0,
        );
      case 'card':
        result = PaymentResult(
          paymentMethod: 'card',
          cashAmount: 0,
          cardAmount: widget.total,
          tip: tip,
        );
      case 'split':
        result = PaymentResult(
          paymentMethod: 'split',
          cashAmount: _splitCash,
          cardAmount: _splitCard,
          tip: tip,
        );
      default:
        result = PaymentResult(paymentMethod: 'cash', cashAmount: widget.total, cardAmount: 0, tip: 0);
    }

    await widget.onConfirm(result);
    if (mounted) Navigator.pop(context);
  }

  // ── build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(l10n.completeOrder, style: const TextStyle(fontWeight: FontWeight.w600)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // total
            Text(
              '${l10n.total}: ${widget.total.toStringAsFixed(2)} MAD',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: scheme.primary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // mode selector (3 buttons)
            Row(
              children: [
                Expanded(child: _ModeButton(label: l10n.cash,  icon: Icons.payments_rounded,     mode: 'cash',  selected: _mode == 'cash',  color: Colors.green, onTap: () => setState(() { _mode = 'cash';  _cardConfirmed = false; }))),
                const SizedBox(width: 8),
                Expanded(child: _ModeButton(label: l10n.card,  icon: Icons.credit_card_rounded,  mode: 'card',  selected: _mode == 'card',  color: Colors.blue,  onTap: () => setState(() { _mode = 'card';  _cardConfirmed = false; }))),
                const SizedBox(width: 8),
                Expanded(child: _ModeButton(label: l10n.split, icon: Icons.call_split_rounded,   mode: 'split', selected: _mode == 'split', color: Colors.purple, onTap: () { _prefillSplit(); setState(() { _mode = 'split'; _cardConfirmed = false; }); })),
              ],
            ),

            // ── card fields ──
            if (_mode == 'card') ...[
              const SizedBox(height: 14),
              _TipField(controller: _tipCtrl, label: l10n.tipCardSide, onChanged: (_) => setState(() {})),
              const SizedBox(height: 12),
              _CardConfirmBox(value: _cardConfirmed, label: l10n.cardConfirmed, onChanged: (v) => setState(() => _cardConfirmed = v!)),
            ],

            // ── split fields ──
            if (_mode == 'split') ...[
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _AmountField(label: l10n.cash, controller: _cashCtrl, color: Colors.green,
                    onChanged: _onCashChanged)),
                const SizedBox(width: 10),
                Expanded(child: _AmountField(label: l10n.card, controller: _cardCtrl, color: Colors.blue,
                    onChanged: _onCardChanged)),
              ]),
              const SizedBox(height: 6),
              // balance indicator
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: _splitBalanced
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Row(children: [
                  const Icon(Icons.check_circle_rounded, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(AppLocalizations.of(context)!.amountsMatchTotal, style: TextStyle(fontSize: 12, color: Colors.green.shade700)),
                ]),
                secondChild: Row(children: [
                  Icon(Icons.warning_amber_rounded, size: 14, color: scheme.error),
                  const SizedBox(width: 4),
                  Text(
                    'Sum: ${_splitSum.toStringAsFixed(2)} / ${widget.total.toStringAsFixed(2)} MAD',
                    style: TextStyle(fontSize: 12, color: scheme.error),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              _TipField(controller: _tipCtrl, label: AppLocalizations.of(context)!.tipCardSide, onChanged: (_) => setState(() {})),
              const SizedBox(height: 12),
              _CardConfirmBox(value: _cardConfirmed, label: AppLocalizations.of(context)!.cardConfirmed, onChanged: (v) => setState(() => _cardConfirmed = v!)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
        FilledButton(
          onPressed: _canSubmit ? _submit : null,
          child: _loading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(AppLocalizations.of(context)!.markDone),
        ),
      ],
    );
  }
}

// ── sub-widgets ───────────────────────────────────────────────────────────────

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label, required this.icon, required this.mode,
    required this.selected, required this.color, required this.onTap,
  });
  final String label, mode;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : Theme.of(context).colorScheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(
              color: selected ? color : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 12,
            )),
          ],
        ),
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({required this.label, required this.controller, required this.color, required this.onChanged});
  final String label;
  final TextEditingController controller;
  final Color color;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: 'MAD',
        labelStyle: TextStyle(color: color),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

class _TipField extends StatelessWidget {
  const _TipField({required this.controller, required this.label, required this.onChanged});
  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: 'MAD',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

class _CardConfirmBox extends StatelessWidget {
  const _CardConfirmBox({required this.value, required this.label, required this.onChanged});
  final bool value;
  final String label;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Checkbox(value: value, onChanged: onChanged, activeColor: Colors.blue),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}