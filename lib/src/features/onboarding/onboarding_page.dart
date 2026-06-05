import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_member_app/src/core/onboarding/onboarding_prefs.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/onboarding/models/onboarding_slide.dart';
import 'package:gym_member_app/src/features/onboarding/widgets/onboarding_slide_view.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await OnboardingPrefs.markCompleted();
    if (!mounted) return;
    context.go('/profile-setup');
  }

  void _next() {
    if (_index >= onboardingSlides.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = AppSemanticColors.light.accentLime;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: PageView.builder(
          controller: _controller,
          itemCount: onboardingSlides.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (context, i) {
            return OnboardingSlideView(
              slide: onboardingSlides[i],
              pageIndex: i,
              pageCount: onboardingSlides.length,
              isLastPage: i == onboardingSlides.length - 1,
              accentColor: accentColor,
              onPrimaryAction: _next,
              onSkip: _finish,
            );
          },
        ),
      ),
    );
  }
}
