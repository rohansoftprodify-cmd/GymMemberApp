class OnboardingSlide {
  const OnboardingSlide({
    required this.imageAsset,
    required this.line1,
    required this.line2,
    required this.accentLine,
    required this.quote,
  });

  final String imageAsset;
  final String line1;
  final String line2;
  final String accentLine;
  final String quote;
}

const onboardingSlides = <OnboardingSlide>[
  OnboardingSlide(
    imageAsset: 'assets/onboarding/slide_1.jpg',
    line1: 'No Excuses',
    line2: 'Just Do The',
    accentLine: 'Workout',
    quote:
        '“Fitness is not about being better than someone else. It’s about being better than you used to be.”',
  ),
  OnboardingSlide(
    imageAsset: 'assets/onboarding/slide_2.jpg',
    line1: 'Track Your',
    line2: 'Progress',
    accentLine: 'Every Day',
    quote:
        '“Small daily improvements lead to stunning long-term results. Show up, check in, and stay consistent.”',
  ),
  OnboardingSlide(
    imageAsset: 'assets/onboarding/slide_3.jpg',
    line1: 'Explore Gyms',
    line2: 'Check In',
    accentLine: 'Anytime',
    quote:
        '“Discover partner gyms, view offers, and use location or QR check-in when you arrive.”',
  ),
];
