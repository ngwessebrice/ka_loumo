import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'app/routes/app_router.dart';
import 'app/theme/app_theme.dart';
import 'core/settings/theme_provider.dart';
import 'core/settings/locale_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Firebase init ONLY
  try {
    await Firebase.initializeApp();
  } catch (e, st) {
    debugPrint("FIREBASE_INIT_FAILED=$e\n$st");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// =======================================================
// Deep link handler (Stripe success / cancel)
// Supported formats:
//   kaloumo://payment/success?session_id=...
//   kaloumo://payment/cancel
//   kaloumo://upgrade
// =======================================================
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();

    // Listen while app is running
    _sub = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (e) => debugPrint("DEEPLINK_STREAM_ERROR=$e"),
    );

    // Handle launch link
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleDeepLink(uri);
    }).catchError((e) {
      debugPrint("DEEPLINK_INITIAL_ERROR=$e");
    });
  }

  void _handleDeepLink(Uri uri) {
    debugPrint("DEEPLINK=$uri");

    if (uri.scheme != "kaloumo") return;

    // kaloumo://upgrade
    if (uri.host == "upgrade") {
      appRouter.go("/upgrade");
      return;
    }

    // kaloumo://payment/success | cancel
    if (uri.host == "payment") {
      final action =
      uri.pathSegments.isNotEmpty ? uri.pathSegments.first : "";

      if (action == "success") {
        appRouter.go("/upgrade");
        return;
      }

      if (action == "cancel") {
        appRouter.go("/upgrade");
        return;
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Ka-Loumo',
      routerConfig: appRouter,
      locale: localeProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
    );
  }
}
