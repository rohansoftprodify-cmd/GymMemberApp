import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/gyms/models/gym_amenity.dart';

class GymsDirectoryHeader extends StatelessWidget {
  const GymsDirectoryHeader({
    super.key,
    required this.totalCount,
    required this.showingCount,
    required this.searchController,
    required this.query,
    required this.onQueryChanged,
    required this.onClearQuery,
    this.selectedFacilityKey,
    required this.onFacilitySelected,
  });

  final int totalCount;
  final int showingCount;
  final TextEditingController searchController;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final String? selectedFacilityKey;
  final ValueChanged<String?> onFacilitySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final semantics = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        /*Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: BoxDecoration(
            color: semantics.cardBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.45)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DISCOVER',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalCount gyms on the platform',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                showingCount == totalCount
                    ? 'Browse facilities, hours, and offers before you join.'
                    : '$showingCount of $totalCount match your filters',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: semantics.mutedText,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),*/
        TextField(
          controller: searchController,
          onChanged: onQueryChanged,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Search gym, area, phone, or facility…',
            prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary),
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: onClearQuery,
                  )
                : null,
            filled: true,
            fillColor: semantics.cardBackground,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _FacilityFilterChip(
                label: 'All',
                selected: selectedFacilityKey == null,
                onTap: () => onFacilitySelected(null),
              ),
              for (final amenity in gymAmenitiesCatalog) ...[
                const SizedBox(width: 8),
                _FacilityFilterChip(
                  label: amenity.label,
                  icon: amenity.icon,
                  selected: selectedFacilityKey == amenity.key,
                  onTap: () => onFacilitySelected(
                    selectedFacilityKey == amenity.key ? null : amenity.key,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FacilityFilterChip extends StatelessWidget {
  const _FacilityFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: selected ? colorScheme.onPrimary : colorScheme.primary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
          ),
        ],
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      selectedColor: colorScheme.primary,
      side: BorderSide(
        color: selected ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.45),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
