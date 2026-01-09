import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ✅ Import your global router instance (or router key) from your app_router.dart
// Adjust the path/name to match your project.
import 'package:ka_loumo/app/routes/app_router.dart'; // must expose: `router` (GoRouter)

class DeepLinkHandler extends StatefulWidget {
  final Widget child;
  const DeepLinkHandler({super.key, required this.child});

  @override
  State<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  // prevents handling the same link twice (common on Android)
  String? _lastHandled;

  @override
  void initState() {
    super.initState();

    // Cold start
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleUri(uri);
    });

    // Warm start
    _sub = _appLinks.uriLinkStream.listen(_handleUri);
  }

  void _handleUri(Uri uri) {
    if (uri.scheme != 'kaloumo') return;

    final link = uri.toString();
    if (_lastHandled == link) return;
    _lastHandled = link;

    final host = uri.host;
    final path = uri.path;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (host == 'upgrade' && path.startsWith('/success')) {
        final sessionId = uri.queryParameters['session_id'] ?? '';
        final qs = sessionId.isEmpty
            ? ''
            : '?session_id=${Uri.encodeComponent(sessionId)}';
        appRouter.go('/upgrade/success$qs');
        return;
      }

      if (host == 'upgrade' && path.startsWith('/cancel')) {
        appRouter.go('/upgrade/cancel');
        return;
      }
    });
  }


  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
