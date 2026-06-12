import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class ExclusiveOfferCard extends StatelessWidget {
  const ExclusiveOfferCard({
    super.key,
    required this.offer,
    this.height = 148,
    this.margin = EdgeInsets.zero,
  });

  final Map<String, dynamic> offer;
  final double height;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final endAt = DateTime.tryParse(offer['end_at'] as String? ?? '');
    final rawDesign = offer['card_design'];
    final design = rawDesign is Map ? Map<String, dynamic>.from(rawDesign) : null;

    final primary = Color(design?['primary_color'] as int? ?? AppTheme.wellnessPrimary.value);
    final secondary = Color(design?['secondary_color'] as int? ?? 0xFF4DD0E1);
    final textColor = Color(design?['text_color'] as int? ?? 0xFFFFFFFF);
    final badgeText = design?['badge_text'] as String? ?? 'LIMITED OFFER';
    final positions = design?['positions'] as Map<String, dynamic>?;

    Offset pos(String key, Offset fallback) {
      final raw = positions?[key] as Map<String, dynamic>?;
      if (raw == null) return fallback;
      return Offset(
        (raw['x'] as num?)?.toDouble() ?? fallback.dx,
        (raw['y'] as num?)?.toDouble() ?? fallback.dy,
      );
    }

    final decorationCode = int.tryParse(design?['decoration_icon'] as String? ?? '');
    final decorationIcon = decorationCode != null
        ? IconData(decorationCode, fontFamily: 'MaterialIcons')
        : Icons.water_drop_outlined;

    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, secondary],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          Widget placed(String key, Offset fallback, Widget child) {
            final p = pos(key, fallback);
            return Positioned(
              left: p.dx.clamp(0.0, 0.92) * w,
              top: p.dy.clamp(0.0, 0.88) * h,
              child: child,
            );
          }

          return Stack(
            children: [
              Positioned(
                right: -8,
                top: -12,
                child: Icon(
                  decorationIcon,
                  size: 120,
                  color: textColor.withValues(alpha: 0.12),
                ),
              ),
              placed(
                'badge',
                const Offset(0.05, 0.08),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 9,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              placed(
                'title',
                const Offset(0.05, 0.48),
                SizedBox(
                  width: w * 0.88,
                  child: Text(
                    offer['title'] as String? ?? 'Deal',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              placed(
                'description',
                const Offset(0.05, 0.62),
                SizedBox(
                  width: w * 0.72,
                  child: Text(
                    offer['description'] as String? ?? '',
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.92),
                      fontSize: 11,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              placed(
                'date',
                const Offset(0.05, 0.82),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule_rounded, size: 13, color: textColor.withValues(alpha: 0.85)),
                    const SizedBox(width: 4),
                    Text(
                      'Until ${endAt == null ? '-' : DateFormat.yMMMd().format(endAt)}',
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
