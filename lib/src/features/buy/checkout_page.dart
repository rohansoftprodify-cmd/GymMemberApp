import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
import 'package:gym_member_app/src/core/ui/shimmer_placeholders.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/core/utils/upi_payment.dart';
import 'package:gym_member_app/src/features/buy/cart_provider.dart';
import 'package:gym_member_app/src/features/buy/widgets/cart_item_tile.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  bool _loadingPayment = true;
  bool _placingOrder = false;
  bool _paidViaUpi = false;
  String? _error;
  Map<String, dynamic>? _paymentOption;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPaymentOption());
  }

  Future<void> _loadPaymentOption() async {
    final member = ref.read(memberContextProvider).valueOrNull;
    final cart = ref.read(cartProvider);
    if (member == null || cart.isEmpty) {
      setState(() {
        _loadingPayment = false;
        _error = 'Cart is empty or membership not found.';
      });
      return;
    }

    if (cart.gymId != member.gymId) {
      ref.read(cartProvider.notifier).clear();
      setState(() {
        _loadingPayment = false;
        _error = 'Cart cleared — you can only buy from your own gym.';
      });
      return;
    }

    try {
      final option = await ref.read(memberRepositoryProvider).primaryPaymentOption(member.gymId);
      if (!mounted) return;
      setState(() {
        _paymentOption = option;
        _loadingPayment = false;
        if (option == null || !_hasUpi(option['upi_id'])) {
          _error = 'Your gym has not set up a primary UPI ID for payments yet.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingPayment = false;
        _error = 'Unable to load payment details.';
      });
    }
  }

  Future<void> _payWithUpi({
    required String upiId,
    required String gymName,
    required double amount,
  }) async {
    final uri = Uri.parse(
      UpiPayment.buildUri(
        upiId: upiId,
        payeeName: gymName,
        amount: amount,
        note: 'Gym shop order',
      ),
    );

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (launched) {
      setState(() => _paidViaUpi = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open a UPI app. Copy the UPI ID and pay manually.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _placeOrder() async {
    final member = ref.read(memberContextProvider).valueOrNull;
    final cart = ref.read(cartProvider);
    if (member == null || cart.isEmpty) return;

    if (cart.gymId != member.gymId) {
      setState(() => _error = 'You can only buy products from your own gym.');
      return;
    }

    setState(() {
      _placingOrder = true;
      _error = null;
    });

    try {
      final repo = ref.read(memberRepositoryProvider);
      final items = cart.items.values.map((e) => e.toOrderJson()).toList();
      final result = await repo.createMemberProductOrder(items);
      if (!mounted) return;

      ref.read(cartProvider.notifier).clear();

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.check_circle_outline_rounded),
          title: const Text('Order placed'),
          content: Text(
            'Your order #${result.orderId.substring(0, 8)} was submitted for '
            '₹${result.totalAmount.toStringAsFixed(0)}. '
            'Your gym will confirm the payment shortly.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      );

      if (mounted) context.go('/');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _placingOrder = false;
        _error = e.toString().replaceFirst('Exception: ', '').replaceFirst('PostgrestException: ', '');
      });
      return;
    }

    if (mounted) setState(() => _placingOrder = false);
  }

  static bool _hasUpi(dynamic value) => value is String && value.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final member = ref.watch(memberContextProvider).valueOrNull;
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(
          child: FilledButton(
            onPressed: () => context.go('/'),
            child: const Text('Back to shop'),
          ),
        ),
      );
    }

    final upiId = _paymentOption?['upi_id'] as String?;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: _loadingPayment
          ? const ShimmerCheckoutPage()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                for (final item in cart.items.values) CartItemTile(item: item),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: semantics.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order total',
                        style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${cart.subtotal.toStringAsFixed(0)}',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (upiId != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pay to ${member?.gymName ?? 'your gym'}',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'UPI ID',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: semantics.mutedText,
                                    ),
                                  ),
                                  Text(
                                    upiId,
                                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Copy UPI ID',
                              onPressed: () async {
                                await Clipboard.setData(ClipboardData(text: upiId));
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('UPI ID copied'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy_rounded, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: member == null
                                ? null
                                : () => _payWithUpi(
                                      upiId: upiId,
                                      gymName: member.gymName,
                                      amount: cart.subtotal,
                                    ),
                            icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                            label: const Text('Pay with UPI'),
                          ),
                        ),
                        if (_paidViaUpi) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Complete payment in your UPI app, then submit your order for gym confirmation.',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: colorScheme.error, fontSize: 12)),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: (_placingOrder || upiId == null || !_paidViaUpi) ? null : _placeOrder,
                    child: _placingOrder
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit for confirmation'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pay the exact total via UPI, then submit. Your gym will verify and confirm the order.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText, height: 1.35),
                ),
              ],
            ),
    );
  }
}
