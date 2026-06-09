import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/diet/member_diet_plans_provider.dart';
import 'package:gym_member_app/src/features/diet/models/member_diet_models.dart';
import 'package:gym_member_app/src/features/diet/widgets/diet_plan_card.dart';
import 'package:gym_member_app/src/features/home/widgets/home_section_label.dart';

class MemberDietPlansPage extends ConsumerStatefulWidget {
  const MemberDietPlansPage({super.key});

  @override
  ConsumerState<MemberDietPlansPage> createState() => _MemberDietPlansPageState();
}

class _MemberDietPlansPageState extends ConsumerState<MemberDietPlansPage> {
  String? _goalFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
    final plansAsync = ref.watch(myDietPlansProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('My diet plans'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(myDietPlansProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(err.toString(), textAlign: TextAlign.center),
          ),
        ),
        data: (plans) {
          final filtered = _goalFilter == null
              ? plans
              : plans.where((p) => p.goalKey == _goalFilter).toList();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myDietPlansProvider),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.14),
                        colorScheme.secondary.withValues(alpha: 0.08),
                      ],
                    ),
                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.restaurant_menu_rounded, color: colorScheme.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Meal plans from your gym, matched to your membership and goals.',
                          style: theme.textTheme.labelMedium?.copyWith(height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const HomeSectionLabel(title: 'Filter by goal', icon: Icons.filter_list_rounded),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _GoalChip(
                        label: 'All',
                        selected: _goalFilter == null,
                        onTap: () => setState(() => _goalFilter = null),
                      ),
                      for (final goal in ['weight_loss', 'muscle_gain', 'healthy'])
                        _GoalChip(
                          label: DietGoalInfo.forKey(goal)?.shortLabel ?? goal,
                          selected: _goalFilter == goal,
                          onTap: () => setState(() => _goalFilter = goal),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                HomeSectionLabel(
                  title: filtered.isEmpty ? 'Plans' : '${filtered.length} plan${filtered.length == 1 ? '' : 's'}',
                  icon: Icons.menu_book_rounded,
                ),
                if (filtered.isEmpty)
                  _EmptyPlans(semantics: semantics, colorScheme: colorScheme, theme: theme)
                else
                  ...filtered.map(
                    (plan) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: DietPlanCard(
                        plan: plan,
                        onTap: () => context.push('/profile/diet/${plan.id}'),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  const _GoalChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: colorScheme.primary.withValues(alpha: 0.15),
        labelStyle: TextStyle(
          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          color: selected ? colorScheme.primary : null,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyPlans extends StatelessWidget {
  const _EmptyPlans({
    required this.semantics,
    required this.colorScheme,
    required this.theme,
  });

  final AppSemanticColors semantics;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: semantics.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Icon(Icons.no_meals_rounded, size: 40, color: semantics.mutedText),
          const SizedBox(height: 12),
          Text(
            'No diet plans available',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Your gym may add plans soon, or your membership may unlock specific plans. Ask staff if you expected a plan here.',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText, height: 1.4),
          ),
        ],
      ),
    );
  }
}
