import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';

class ProfileActionItem {
  const ProfileActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
}

class ProfileActionsCard extends StatelessWidget {
  const ProfileActionsCard({super.key, required this.actions});

  final List<ProfileActionItem> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: semantics.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 52,
                color: colorScheme.outlineVariant.withValues(alpha: 0.35),
              ),
            _ActionTile(action: actions[i]),
          ],
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action});

  final ProfileActionItem action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final semantics = context.appColors;
    final color = action.destructive ? colorScheme.error : colorScheme.primary;

    return ListTile(
      onTap: action.onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(action.icon, size: 20, color: color),
      ),
      title: Text(
        action.label,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: action.destructive ? colorScheme.error : null,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: semantics.mutedText, size: 20),
    );
  }
}
