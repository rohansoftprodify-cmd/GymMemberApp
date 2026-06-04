import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/tenant/member_context_provider.dart';
import 'package:gym_member_app/src/features/gyms/gyms_directory_tab.dart';

class MemberGymsTab extends StatelessWidget {
  const MemberGymsTab({super.key, required this.member});

  final MemberContext member;

  @override
  Widget build(BuildContext context) {
    return GymsDirectoryTab(linkedGymId: member.gymId);
  }
}
