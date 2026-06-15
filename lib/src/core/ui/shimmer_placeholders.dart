import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/ui/shimmer_effect.dart';

class ShimmerSectionLabel extends StatelessWidget {
  const ShimmerSectionLabel({super.key, this.width = 120});

  final double width;

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: ShimmerBox(width: 120, height: 14, borderRadius: 6),
    );
  }
}

class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({
    super.key,
    this.leadingSize = 44,
    this.height = 72,
  });

  final double leadingSize;
  final double height;

  @override
  Widget build(BuildContext context) {
    final cardBg = Theme.of(context).cardColor;

    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          ShimmerBox(width: leadingSize, height: leadingSize, borderRadius: 12),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerBox(width: double.infinity, height: 12),
                SizedBox(height: 8),
                ShimmerBox(width: 140, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerPlanCard extends StatelessWidget {
  const ShimmerPlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 96,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: const Row(
        children: [
          ShimmerBox(width: 88, height: 96, borderRadius: 0),
          SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShimmerBox(width: double.infinity, height: 13),
                  SizedBox(height: 8),
                  ShimmerBox(width: 160, height: 10),
                  SizedBox(height: 6),
                  ShimmerBox(width: 100, height: 10),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }
}

class ShimmerGymListTile extends StatelessWidget {
  const ShimmerGymListTile({super.key, this.featured = false});

  final bool featured;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: featured
              ? colorScheme.primary.withValues(alpha: 0.35)
              : colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 40, height: 40, borderRadius: 10),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: double.infinity, height: 14),
                    SizedBox(height: 6),
                    ShimmerBox(width: 120, height: 10),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ShimmerBox(width: double.infinity, height: 10),
          SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ShimmerBox(width: 56, height: 22, borderRadius: 6),
              ShimmerBox(width: 64, height: 22, borderRadius: 6),
              ShimmerBox(width: 48, height: 22, borderRadius: 6),
            ],
          ),
        ],
      ),
    );
  }
}

class ShimmerStatCard extends StatelessWidget {
  const ShimmerStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 88,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ShimmerBox(width: 18, height: 18, borderRadius: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 72, height: 14),
              SizedBox(height: 6),
              ShimmerBox(width: 56, height: 10),
            ],
          ),
        ],
      ),
    );
  }
}

class ShimmerHomeDashboard extends StatelessWidget {
  const ShimmerHomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100, top: 4),
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          ),
          child: const Row(
            children: [
              ShimmerBox(width: 52, height: 52, borderRadius: 26),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 140, height: 16),
                    SizedBox(height: 8),
                    ShimmerBox(width: 100, height: 11),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 88,
          child: Row(
            children: List.generate(
              4,
              (_) => const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: ShimmerBox(width: double.infinity, height: 88, borderRadius: 14),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const ShimmerSectionLabel(),
        SizedBox(
          height: 148,
          child: Row(
            children: [
              const Expanded(child: ShimmerStatCard()),
              const SizedBox(width: 10),
              const Expanded(child: ShimmerStatCard()),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const ShimmerSectionLabel(),
        const ShimmerBox(width: double.infinity, height: 120, borderRadius: 16),
        const SizedBox(height: 20),
        const ShimmerSectionLabel(),
        const ShimmerPlanCard(),
        const ShimmerListTile(),
        const ShimmerListTile(),
      ],
    );
  }
}

class ShimmerGymsDirectory extends StatelessWidget {
  const ShimmerGymsDirectory({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100, top: 4),
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 180, height: 22, borderRadius: 8),
              SizedBox(height: 12),
              ShimmerBox(width: double.infinity, height: 44, borderRadius: 12),
              SizedBox(height: 12),
              SizedBox(
                height: 32,
                child: Row(
                  children: [
                    ShimmerBox(width: 72, height: 32, borderRadius: 16),
                    SizedBox(width: 8),
                    ShimmerBox(width: 88, height: 32, borderRadius: 16),
                    SizedBox(width: 8),
                    ShimmerBox(width: 64, height: 32, borderRadius: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        ShimmerSectionLabel(),
        ShimmerGymListTile(featured: true),
        SizedBox(height: 16),
        ShimmerSectionLabel(),
        ShimmerGymListTile(),
        ShimmerGymListTile(),
        ShimmerGymListTile(),
      ],
    );
  }
}

class ShimmerAttendanceTab extends StatelessWidget {
  const ShimmerAttendanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100, top: 4),
      children: [
        SizedBox(
          height: 96,
          child: Row(
            children: List.generate(
              3,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
                  child: const ShimmerStatCard(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const ShimmerSectionLabel(),
        const ShimmerBox(width: double.infinity, height: 100, borderRadius: 16),
        const SizedBox(height: 10),
        const ShimmerBox(width: double.infinity, height: 100, borderRadius: 16),
        const SizedBox(height: 18),
        const ShimmerSectionLabel(),
        const ShimmerListTile(),
        const ShimmerListTile(),
        const ShimmerListTile(),
      ],
    );
  }
}

class ShimmerPlanList extends StatelessWidget {
  const ShimmerPlanList({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        const ShimmerBox(width: double.infinity, height: 72, borderRadius: 16),
        const SizedBox(height: 16),
        const ShimmerSectionLabel(),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, __) => const ShimmerBox(width: 72, height: 36, borderRadius: 18),
          ),
        ),
        const SizedBox(height: 16),
        const ShimmerSectionLabel(),
        for (var i = 0; i < 4; i++) const ShimmerPlanCard(),
      ],
    );
  }
}

class ShimmerProfilePage extends StatelessWidget {
  const ShimmerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        const ShimmerBox(width: double.infinity, height: 76, borderRadius: 16),
        const SizedBox(height: 12),
        SizedBox(
          height: 82,
          child: Row(
            children: List.generate(
              3,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
                  child: const ShimmerStatCard(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const ShimmerSectionLabel(),
        const ShimmerBox(width: double.infinity, height: 88, borderRadius: 14),
        const SizedBox(height: 14),
        const ShimmerSectionLabel(),
        const ShimmerListTile(height: 64),
        const ShimmerListTile(height: 64),
        const SizedBox(height: 14),
        const ShimmerSectionLabel(),
        for (var i = 0; i < 4; i++)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: ShimmerBox(width: double.infinity, height: 48, borderRadius: 12),
          ),
      ],
    );
  }
}

class ShimmerSupportPage extends StatelessWidget {
  const ShimmerSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        const ShimmerBox(width: double.infinity, height: 80, borderRadius: 16),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, __) => const ShimmerBox(width: 88, height: 40, borderRadius: 20),
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < 6; i++) const ShimmerListTile(height: 56),
      ],
    );
  }
}

class ShimmerDetailPage extends StatelessWidget {
  const ShimmerDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: const [
        ShimmerBox(width: double.infinity, height: 140, borderRadius: 16),
        SizedBox(height: 16),
        ShimmerSectionLabel(),
        ShimmerBox(width: double.infinity, height: 100, borderRadius: 14),
        SizedBox(height: 12),
        ShimmerBox(width: double.infinity, height: 100, borderRadius: 14),
        SizedBox(height: 16),
        ShimmerSectionLabel(),
        ShimmerListTile(),
        ShimmerListTile(),
        ShimmerListTile(),
      ],
    );
  }
}

class ShimmerAttendanceHistory extends StatelessWidget {
  const ShimmerAttendanceHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: const [
        ShimmerBox(width: double.infinity, height: 88, borderRadius: 16),
        SizedBox(height: 20),
        ShimmerSectionLabel(),
        ShimmerListTile(height: 80),
        ShimmerListTile(height: 80),
        ShimmerListTile(height: 80),
        ShimmerListTile(height: 80),
      ],
    );
  }
}

class ShimmerSuggestedProducts extends StatelessWidget {
  const ShimmerSuggestedProducts({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (i) => Padding(
          padding: EdgeInsets.only(top: i > 0 ? 10 : 0),
          child: const ShimmerBox(width: double.infinity, height: 96, borderRadius: 14),
        ),
      ),
    );
  }
}

class ShimmerCheckoutPage extends StatelessWidget {
  const ShimmerCheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: const [
        ShimmerListTile(height: 88),
        ShimmerListTile(height: 88),
        SizedBox(height: 8),
        ShimmerBox(width: double.infinity, height: 72, borderRadius: 14),
        SizedBox(height: 14),
        ShimmerBox(width: double.infinity, height: 120, borderRadius: 14),
        SizedBox(height: 14),
        ShimmerBox(width: double.infinity, height: 48, borderRadius: 12),
      ],
    );
  }
}

class ShimmerEditProfilePage extends StatelessWidget {
  const ShimmerEditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: const [
        ShimmerSectionLabel(),
        ShimmerBox(width: double.infinity, height: 52, borderRadius: 12),
        SizedBox(height: 8),
        ShimmerBox(width: double.infinity, height: 52, borderRadius: 12),
        SizedBox(height: 8),
        ShimmerBox(width: double.infinity, height: 52, borderRadius: 12),
        SizedBox(height: 18),
        ShimmerSectionLabel(),
        ShimmerBox(width: double.infinity, height: 100, borderRadius: 14),
        SizedBox(height: 18),
        ShimmerSectionLabel(),
        ShimmerBox(width: double.infinity, height: 140, borderRadius: 14),
      ],
    );
  }
}
