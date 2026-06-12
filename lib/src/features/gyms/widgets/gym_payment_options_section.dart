import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';

class GymPaymentOptionsSection extends StatelessWidget {
  const GymPaymentOptionsSection({
    super.key,
    required this.options,
    required this.imageUrlForPath,
    this.primaryOnly = false,
  });

  final List<Map<String, dynamic>> options;
  final String? Function(String? path) imageUrlForPath;
  final bool primaryOnly;

  List<Map<String, dynamic>> get _visibleOptions {
    if (!primaryOnly) return options;
    final primary = options.where((o) => o['is_primary'] == true).toList();
    return primary.isNotEmpty ? primary.take(1).toList() : const [];
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleOptions;
    if (visible.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final semantics = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < visible.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: semantics.cardBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.payments_outlined, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _titleFor(visible[i], i),
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (!primaryOnly && visible[i]['is_primary'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: semantics.accentLime.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Primary',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: semantics.onAccentLime,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                if (_hasText(visible[i]['upi_id'])) ...[
                  const SizedBox(height: 10),
                  _UpiRow(upiId: visible[i]['upi_id'] as String),
                ],
                if (_hasText(visible[i]['qr_image_path'])) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      child: Image.network(
                        imageUrlForPath(visible[i]['qr_image_path'] as String?) ?? '',
                        height: 180,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox(
                          height: 80,
                          child: Center(child: Text('Could not load QR image')),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  static String _titleFor(Map<String, dynamic> option, int index) {
    final label = option['label'];
    if (label is String && label.trim().isNotEmpty) return label.trim();
    return 'Payment ${index + 1}';
  }

  static bool _hasText(dynamic value) => value is String && value.trim().isNotEmpty;
}

class _UpiRow extends StatelessWidget {
  const _UpiRow({required this.upiId});

  final String upiId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UPI ID',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  upiId,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
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
    );
  }
}
