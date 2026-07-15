import 'package:flutter/material.dart';
import 'package:gym_member_app/src/features/onboarding/models/onboarding_slide.dart';
import 'package:gym_member_app/src/features/onboarding/widgets/onboarding_indicator.dart';

class OnboardingSlideView extends StatelessWidget {
  const OnboardingSlideView({
    super.key,
    required this.slide,
    required this.pageIndex,
    required this.pageCount,
    required this.isLastPage,
    required this.accentColor,
    required this.accentOnColor,
    required this.onPrimaryAction,
    required this.onSkip,
  });

  final OnboardingSlide slide;
  final int pageIndex;
  final int pageCount;
  final bool isLastPage;
  final Color accentColor;
  final Color accentOnColor;
  final VoidCallback onPrimaryAction;
  final VoidCallback onSkip;

  static const _headlineSize = 38.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          slide.imageAsset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Container(color: const Color(0xFF121212)),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.45, 0.72, 1.0],
              colors: [
                Colors.black.withValues(alpha: 0.15),
                Colors.black.withValues(alpha: 0.25),
                Colors.black.withValues(alpha: 0.72),
                Colors.black.withValues(alpha: 0.92),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withValues(alpha: 0.88),
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slide.line1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: _headlineSize,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      slide.line2,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: _headlineSize,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      slide.accentLine,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: _headlineSize,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      slide.quote,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: onPrimaryAction,
                        style: FilledButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: accentOnColor,
                          elevation: 0,
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        child: Text(isLastPage ? 'Get Started' : 'Continue'),
                      ),
                    ),
                    const SizedBox(height: 22),
                    OnboardingIndicator(
                      count: pageCount,
                      index: pageIndex,
                      activeColor: accentColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
