import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_member_app/src/core/theme/app_theme.dart';
import 'package:gym_member_app/src/features/attendance/widgets/attendance_method_card.dart';
import 'package:gym_member_app/src/features/gyms/widgets/gym_list_tile.dart';

void main() {
  testWidgets('GymListTile lays out inside ListView', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ListView(
            children: [
              GymListTile(
                gym: const {'id': '1', 'name': 'Test Gym', 'address': '123 Main'},
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Test Gym'), findsOneWidget);
  });

  testWidgets('AttendanceMethodCard lays out inside ListView', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ListView(
            children: [
              AttendanceMethodCard(
                icon: Icons.my_location_rounded,
                title: 'Location',
                subtitle: 'Near gym',
                buttonLabel: 'Check in',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Location'), findsOneWidget);
  });
}
