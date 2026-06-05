import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/core/utils/height_units.dart';
import 'package:gym_member_app/src/features/profile_setup/widgets/ruler_value_picker.dart';
import 'package:gym_member_app/src/features/profile_setup/widgets/unit_toggle.dart';

enum MetricEditKind { weight, height, age }

Future<double?> showEditWeightDialog(
  BuildContext context, {
  required double weightKg,
}) {
  return showDialog<double>(
    context: context,
    builder: (context) => _MetricEditDialog(
      kind: MetricEditKind.weight,
      initialWeightKg: weightKg,
    ),
  );
}

Future<double?> showEditHeightDialog(
  BuildContext context, {
  required double heightCm,
}) {
  return showDialog<double>(
    context: context,
    builder: (context) => _MetricEditDialog(
      kind: MetricEditKind.height,
      initialHeightCm: heightCm,
    ),
  );
}

Future<int?> showEditAgeDialog(
  BuildContext context, {
  required int age,
}) {
  return showDialog<int>(
    context: context,
    builder: (context) => _MetricEditDialog(
      kind: MetricEditKind.age,
      initialAge: age,
    ),
  );
}

class _MetricEditDialog extends StatefulWidget {
  const _MetricEditDialog({
    required this.kind,
    this.initialWeightKg,
    this.initialHeightCm,
    this.initialAge,
  });

  final MetricEditKind kind;
  final double? initialWeightKg;
  final double? initialHeightCm;
  final int? initialAge;

  @override
  State<_MetricEditDialog> createState() => _MetricEditDialogState();
}

class _MetricEditDialogState extends State<_MetricEditDialog> {
  late double _weightKg;
  late double _heightCm;
  late int _age;
  bool _useKg = true;
  bool _useCm = true;

  @override
  void initState() {
    super.initState();
    _weightKg = widget.initialWeightKg ?? 65;
    _heightCm = widget.initialHeightCm ?? 170;
    _age = widget.initialAge ?? 25;
  }

  String get _title => switch (widget.kind) {
        MetricEditKind.weight => 'Edit weight',
        MetricEditKind.height => 'Edit height',
        MetricEditKind.age => 'Edit age',
      };

  String get _subtitle => switch (widget.kind) {
        MetricEditKind.weight => 'Scroll to select your current weight.',
        MetricEditKind.height => 'Scroll to select your height.',
        MetricEditKind.age => 'Scroll to select your age.',
      };

  int get _weightDisplay => _useKg ? _weightKg.round() : (_weightKg * 2.20462).round();

  int get _heightInches => HeightUnits.totalInchesFromCm(_heightCm);

  void _save() {
    switch (widget.kind) {
      case MetricEditKind.weight:
        Navigator.of(context).pop(_weightKg);
      case MetricEditKind.height:
        Navigator.of(context).pop(_heightCm);
      case MetricEditKind.age:
        Navigator.of(context).pop(_age);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final semantics = context.appColors;

    final dialogWidth = MediaQuery.sizeOf(context).width * 0.88;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: semantics.cardBackground,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        _title,
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      content: SizedBox(
        width: dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _subtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: semantics.mutedText,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: ColoredBox(
                color: colorScheme.onSurface.withValues(alpha: 0.92),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    width: dialogWidth,
                    child: _buildPicker(),
                  ),
                ),
              ),
            ),
            if (widget.kind == MetricEditKind.weight || widget.kind == MetricEditKind.height) ...[
              const SizedBox(height: 14),
              Center(child: _buildUnitToggle(semantics)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildPicker() {
    return switch (widget.kind) {
      MetricEditKind.weight => RulerValuePicker(
          min: _useKg ? 35 : 80,
          max: _useKg ? 180 : 400,
          value: _weightDisplay,
          onChanged: (value) {
            final kg = _useKg ? value.toDouble() : value / 2.20462;
            setState(() => _weightKg = kg);
          },
        ),
      MetricEditKind.height => _useCm
          ? RulerValuePicker(
              min: 120,
              max: 220,
              value: _heightCm.round(),
              onChanged: (value) => setState(() => _heightCm = value.toDouble()),
            )
          : RulerValuePicker(
              min: HeightUnits.minTotalInches,
              max: HeightUnits.maxTotalInches,
              value: _heightInches,
              itemWidth: 76,
              pickerHeight: 148,
              selectedFontSize: 24,
              labelBuilder: HeightUnits.formatFeetInchesShort,
              selectedLabelBuilder: HeightUnits.formatFeetInches,
              onChanged: (totalInches) => setState(
                () => _heightCm = HeightUnits.cmFromTotalInches(totalInches),
              ),
            ),
      MetricEditKind.age => RulerValuePicker(
          min: 16,
          max: 80,
          value: _age,
          onChanged: (value) => setState(() => _age = value),
        ),
    };
  }

  Widget _buildUnitToggle(AppSemanticColors semantics) {
    if (widget.kind == MetricEditKind.weight) {
      return UnitToggle(
        leftLabel: 'Kg',
        rightLabel: 'Lb',
        isLeftSelected: _useKg,
        activeColor: semantics.accentCoral,
        onChanged: (useKg) => setState(() => _useKg = useKg),
      );
    }
    return UnitToggle(
      leftLabel: 'Cm',
      rightLabel: 'Ft',
      isLeftSelected: _useCm,
      activeColor: semantics.accentCoral,
      onChanged: (useCm) => setState(() => _useCm = useCm),
    );
  }
}
