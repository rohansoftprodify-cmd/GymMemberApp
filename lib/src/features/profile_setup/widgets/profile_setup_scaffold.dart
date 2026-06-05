import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileSetupScaffold extends StatelessWidget {
  const ProfileSetupScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.stepIndex,
    required this.stepCount,
    required this.child,
    this.bottom,
    this.onSkip,
  });

  final String title;
  final String subtitle;
  final int stepIndex;
  final int stepCount;
  final Widget child;
  final Widget? bottom;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final progress = (stepIndex + 1) / stepCount;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 3,
                          backgroundColor: const Color(0xFF2A2A2A),
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (onSkip != null) ...[
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: onSkip,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white.withValues(alpha: 0.7),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text('Skip'),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: child),
              if (bottom != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: bottom!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
