import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/core/utils/height_units.dart';
import 'package:gym_member_app/src/core/onboarding/profile_setup_prefs.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
import 'package:gym_member_app/src/core/tenant/member_profile_provider.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/profile_setup/models/profile_setup_data.dart';
import 'package:gym_member_app/src/features/profile_setup/widgets/fitness_goal_list.dart';
import 'package:gym_member_app/src/features/profile_setup/widgets/profile_setup_scaffold.dart';
import 'package:gym_member_app/src/features/profile_setup/widgets/ruler_value_picker.dart';
import 'package:gym_member_app/src/features/profile_setup/widgets/unit_toggle.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  static const _stepCount = 4;

  final _controller = PageController();
  int _step = 0;
  bool _useKg = true;
  bool _useCm = true;
  bool _saving = false;
  late ProfileSetupData _data;

  @override
  void initState() {
    super.initState();
    _data = ProfileSetupData.defaults();
    _loadSavedDraft();
  }

  Future<void> _loadSavedDraft() async {
    final saved = await ProfileSetupPrefs.load();
    if (!mounted || saved == null) return;
    setState(() => _data = saved);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _weightDisplay => _useKg
      ? _data.weightKg.round()
      : (_data.weightKg * 2.20462).round();

  int get _heightInches => HeightUnits.totalInchesFromCm(_data.heightCm);

  void _setWeightDisplay(int value) {
    final kg = _useKg ? value.toDouble() : value / 2.20462;
    setState(() => _data = _data.copyWith(weightKg: kg));
  }

  Widget _heightPicker() {
    if (_useCm) {
      return RulerValuePicker(
        min: 120,
        max: 220,
        value: _data.heightCm.round(),
        onChanged: (value) =>
            setState(() => _data = _data.copyWith(heightCm: value.toDouble())),
      );
    }
    return RulerValuePicker(
      min: HeightUnits.minTotalInches,
      max: HeightUnits.maxTotalInches,
      value: _heightInches,
      itemWidth: 76,
      pickerHeight: 148,
      selectedFontSize: 24,
      labelBuilder: HeightUnits.formatFeetInchesShort,
      selectedLabelBuilder: HeightUnits.formatFeetInches,
      onChanged: (totalInches) => setState(
        () => _data = _data.copyWith(
          heightCm: HeightUnits.cmFromTotalInches(totalInches),
        ),
      ),
    );
  }

  void _next() {
    if (_step >= _stepCount - 1) {
      _complete();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _skip() async {
    await ProfileSetupPrefs.save(_data);
    await ProfileSetupPrefs.markCompleted();
    if (!mounted) return;
    _goNextRoute();
  }

  Future<void> _complete() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      await ProfileSetupPrefs.save(_data);
      await ProfileSetupPrefs.markCompleted();

      if (Supabase.instance.client.auth.currentSession != null) {
        await ref.read(memberRepositoryProvider).saveProfileSetup(_data);
        ref.invalidate(memberProfileProvider);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved locally. Sign in to sync with your gym profile.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }

    if (!mounted) return;
    _goNextRoute();
  }

  void _goNextRoute() {
    if (Supabase.instance.client.auth.currentSession != null) {
      ref.invalidate(memberContextProvider);
      context.go('/');
    } else {
      context.go('/explore');
    }
  }

  Widget _continueButton({required String label}) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: _saving ? null : _next,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.white24,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        child: _saving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = AppSemanticColors.light.accentCoral;

    return PageView(
      controller: _controller,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (i) => setState(() => _step = i),
      children: [
        ProfileSetupScaffold(
          title: 'What is your current weight?',
          subtitle: 'Your plan will be tailored to your Body Mass Index (BMI) and weight.',
          stepIndex: 0,
          stepCount: _stepCount,
          onSkip: _skip,
          child: Center(
            child: RulerValuePicker(
              min: _useKg ? 35 : 80,
              max: _useKg ? 180 : 400,
              value: _weightDisplay,
              onChanged: _setWeightDisplay,
            ),
          ),
          bottom: Column(
            children: [
              Center(
                child: UnitToggle(
                  leftLabel: 'Kg',
                  rightLabel: 'Lb',
                  isLeftSelected: _useKg,
                  activeColor: accentColor,
                  onChanged: (useKg) => setState(() => _useKg = useKg),
                ),
              ),
              const SizedBox(height: 24),
              _continueButton(label: 'Continue'),
            ],
          ),
        ),
        ProfileSetupScaffold(
          title: 'How tall are you?',
          subtitle: 'Height helps us calculate BMI and personalize your fitness recommendations.',
          stepIndex: 1,
          stepCount: _stepCount,
          onSkip: _skip,
          child: Center(child: _heightPicker()),
          bottom: Column(
            children: [
              Center(
                child: UnitToggle(
                  leftLabel: 'Cm',
                  rightLabel: 'Ft',
                  isLeftSelected: _useCm,
                  activeColor: accentColor,
                  onChanged: (useCm) => setState(() => _useCm = useCm),
                ),
              ),
              const SizedBox(height: 24),
              _continueButton(label: 'Continue'),
            ],
          ),
        ),
        ProfileSetupScaffold(
          title: 'What is your age?',
          subtitle: 'Age helps us suggest safe workout intensity and recovery guidance.',
          stepIndex: 2,
          stepCount: _stepCount,
          onSkip: _skip,
          child: Center(
            child: RulerValuePicker(
              min: 16,
              max: 80,
              value: _data.age,
              onChanged: (age) => setState(() => _data = _data.copyWith(age: age)),
            ),
          ),
          bottom: _continueButton(label: 'Continue'),
        ),
        ProfileSetupScaffold(
          title: 'What is your fitness goal?',
          subtitle: 'Choose a goal so your gym experience and plans match what you want to achieve.',
          stepIndex: 3,
          stepCount: _stepCount,
          child: FitnessGoalList(
            selectedKey: _data.fitnessGoal,
            accentColor: AppSemanticColors.light.accentLime,
            onSelected: (key) => setState(() => _data = _data.copyWith(fitnessGoal: key)),
          ),
          bottom: _continueButton(label: 'Complete setup'),
        ),
      ],
    );
  }
}
