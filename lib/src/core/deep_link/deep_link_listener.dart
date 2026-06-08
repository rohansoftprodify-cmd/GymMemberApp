import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:gym_member_app/src/core/router/app_router.dart';
import 'package:gym_member_app/src/features/attendance/attendance_qr.dart';

/// Routes incoming gymmember:// deep links into GoRouter.
class DeepLinkListener extends StatefulWidget {
  const DeepLinkListener({super.key, required this.child});

  final Widget child;

  @override
  State<DeepLinkListener> createState() => _DeepLinkListenerState();
}

class _DeepLinkListenerState extends State<DeepLinkListener> {
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _appLinks.getInitialLink().then(_handleUri);
    _appLinks.uriLinkStream.listen(_handleUri);
  }

  void _handleUri(Uri? uri) {
    if (uri == null) return;

    final gymId = gymIdFromCheckInDeepLink(uri);
    if (gymId == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      appRouter.go('/checkin?gymId=$gymId');
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
