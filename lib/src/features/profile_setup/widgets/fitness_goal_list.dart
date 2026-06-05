import 'package:flutter/material.dart';
import 'package:gym_member_app/src/features/profile_setup/models/profile_setup_data.dart';

class FitnessGoalList extends StatelessWidget {
  const FitnessGoalList({
    super.key,
    required this.selectedKey,
    required this.onSelected,
    required this.accentColor,
  });

  final String selectedKey;
  final ValueChanged<String> onSelected;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      itemCount: fitnessGoalOptions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final option = fitnessGoalOptions[index];
        final selected = option.key == selectedKey;

        return Material(
          color: selected ? accentColor.withValues(alpha: 0.12) : const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => onSelected(option.key),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? accentColor : const Color(0xFF2A2A2A),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: selected
                          ? accentColor.withValues(alpha: 0.2)
                          : const Color(0xFF222222),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      option.icon,
                      color: selected ? accentColor : Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          option.subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check_circle_rounded, color: accentColor, size: 22),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
