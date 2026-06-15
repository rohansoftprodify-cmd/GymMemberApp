import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/core/utils/height_units.dart';
import 'package:gym_member_app/src/core/tenant/member_profile.dart';
import 'package:gym_member_app/src/core/tenant/member_profile_provider.dart';
import 'package:gym_member_app/src/core/ui/shimmer_placeholders.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/home/widgets/home_section_label.dart';
import 'package:gym_member_app/src/features/profile/models/member_profile_edit_data.dart';
import 'package:gym_member_app/src/features/profile/widgets/edit_metric_dialog.dart';
import 'package:gym_member_app/src/features/profile/widgets/edit_profile_gender_section.dart';
import 'package:gym_member_app/src/features/profile/widgets/edit_profile_goal_section.dart';
import 'package:gym_member_app/src/features/profile/widgets/editable_metric_row.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _phoneController = TextEditingController();
  final _emergencyController = TextEditingController();
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _saving = false;
  bool _initialized = false;

  late MemberProfileEditData _data;

  static const _sectionGap = 18.0;

  @override
  void dispose() {
    _phoneController.dispose();
    _emergencyController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _initFromProfile(MemberProfile profile) {
    if (_initialized) return;
    _initialized = true;

    final dob = profile.dateOfBirth == null
        ? null
        : DateTime.tryParse(profile.dateOfBirth!);

    _data = MemberProfileEditData(
      phone: profile.phone ?? '',
      emergencyContact: profile.emergencyContact ?? '',
      address: profile.address ?? '',
      dateOfBirth: dob,
      weightKg: profile.weightKg ?? MemberProfileEditData.defaultWeightKg,
      heightCm: profile.heightCm ?? MemberProfileEditData.defaultHeightCm,
      age: profile.age ?? MemberProfileEditData.defaultAge,
      gender: profile.gender,
      fitnessGoal: profile.fitnessGoal ?? 'healthy',
    );

    _phoneController.text = _data.phone;
    _emergencyController.text = _data.emergencyContact;
    _addressController.text = _data.address;
  }

  Future<void> _editWeight() async {
    final result = await showEditWeightDialog(context, weightKg: _data.weightKg);
    if (result != null) setState(() => _data = _data.copyWith(weightKg: result));
  }

  Future<void> _editHeight() async {
    final result = await showEditHeightDialog(context, heightCm: _data.heightCm);
    if (result != null) setState(() => _data = _data.copyWith(heightCm: result));
  }

  Future<void> _editAge() async {
    final result = await showEditAgeDialog(context, age: _data.age);
    if (result != null) setState(() => _data = _data.copyWith(age: result));
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initial = _data.dateOfBirth ?? DateTime(now.year - 25);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _data = _data.copyWith(dateOfBirth: picked));
    }
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final payload = _data.copyWith(
      phone: _phoneController.text.trim(),
      emergencyContact: _emergencyController.text.trim(),
      address: _addressController.text.trim(),
    );

    try {
      await ref.read(memberRepositoryProvider).updateMyProfile(payload);
      if (!mounted) return;

      ref.invalidate(memberProfileProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Supabase.instance.client.auth.currentSession == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/explore'));
    }

    final profileAsync = ref.watch(memberProfileProvider);
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat.yMMMd();

    return profileAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Edit profile')),
        body: const ShimmerEditProfilePage(),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Edit profile')),
        body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('$err'))),
      ),
      data: (profile) {
        if (profile == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit profile')),
            body: const Center(child: Text('Profile not available.')),
          );
        }

        _initFromProfile(profile);

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            title: const Text('Edit profile'),
            actions: [
              TextButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                const HomeSectionLabel(title: 'Account', icon: Icons.verified_user_outlined),
                _ReadOnlyCard(
                  rows: [
                    _ReadOnlyRow(label: 'Name', value: profile.fullName),
                    _ReadOnlyRow(
                      label: 'Email',
                      value: profile.email ?? profile.authEmail ?? '—',
                    ),
                    _ReadOnlyRow(label: 'Gym', value: profile.gymName),
                  ],
                ),
                const SizedBox(height: _sectionGap),
                const HomeSectionLabel(title: 'Contact', icon: Icons.contact_phone_outlined),
                _FormCard(
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        hintText: 'Your contact number',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emergencyController,
                      decoration: const InputDecoration(
                        labelText: 'Emergency contact',
                        hintText: 'Name and phone number',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      keyboardType: TextInputType.streetAddress,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Home address',
                        hintText: 'Street, city',
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickDateOfBirth,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date of birth',
                          suffixIcon: Icon(Icons.calendar_today_rounded, size: 20),
                        ),
                        child: Text(
                          _data.dateOfBirth == null
                              ? 'Tap to select'
                              : dateFormat.format(_data.dateOfBirth!),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _data.dateOfBirth == null ? semantics.mutedText : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: _sectionGap),
                const HomeSectionLabel(title: 'Gender', icon: Icons.wc_outlined),
                _FormCard(
                  children: [
                    EditProfileGenderSection(
                      selectedKey: _data.gender,
                      onSelected: (key) => setState(() => _data = _data.copyWith(
                            gender: key,
                            clearGender: key == null,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: _sectionGap),
                const HomeSectionLabel(title: 'Body metrics', icon: Icons.monitor_weight_outlined),
                _FormCard(
                  children: [
                    EditableMetricRow(
                      label: 'Weight',
                      value: '${_data.weightKg.toStringAsFixed(1)} kg',
                      onEdit: _editWeight,
                    ),
                    Divider(
                      height: 24,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                    ),
                    EditableMetricRow(
                      label: 'Height',
                      value: HeightUnits.formatDisplay(_data.heightCm),
                      onEdit: _editHeight,
                    ),
                    Divider(
                      height: 24,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                    ),
                    EditableMetricRow(
                      label: 'Age',
                      value: '${_data.age} years',
                      onEdit: _editAge,
                    ),
                  ],
                ),
                const SizedBox(height: _sectionGap),
                const HomeSectionLabel(title: 'Fitness goal', icon: Icons.flag_outlined),
                EditProfileGoalSection(
                  selectedKey: _data.fitnessGoal,
                  onSelected: (key) => setState(() => _data = _data.copyWith(fitnessGoal: key)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save changes'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReadOnlyCard extends StatelessWidget {
  const _ReadOnlyCard({required this.rows});

  final List<_ReadOnlyRow> rows;

  @override
  Widget build(BuildContext context) {
    final semantics = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: semantics.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(
                height: 20,
                color: colorScheme.outlineVariant.withValues(alpha: 0.35),
              ),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: semantics.mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final semantics = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: semantics.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}
