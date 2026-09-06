import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:discuz_flutter/app/ExclusiveDiscuzApp.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/provider/DiscuzNotificationProvider.dart';
import 'package:discuz_flutter/provider/ReplyPostNotifierProvider.dart';
import 'package:discuz_flutter/provider/SelectedTidNotifierProvider.dart';
import 'package:discuz_flutter/provider/ThemeNotifierProvider.dart';
import 'package:discuz_flutter/provider/TypeSettingNotifierProvider.dart';
import 'package:discuz_flutter/provider/UserPreferenceNotifierProvider.dart';
import 'package:discuz_flutter/utility/PushServiceUtils.dart';
import 'package:discuz_flutter/utility/UserPreferencesUtils.dart';
import 'package:discuz_flutter/utility/WbiSign.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app/MainApp.dart';
import 'dao/DiscuzDao.dart';
import 'entity/Discuz.dart';
import 'firebase_options.dart';

String initialPlatform = "";

bool isExclusiveDiscuz = false;

Discuz exclusiveDiscuz = Discuz(
    "https://keylol.com",
    "X3.2",
    "utf-8",
    4,
    "1.4.8",
    "register",
    true,
    "true",
    "true",
    "其乐 Keylol",
    "0",
    "https://keylol.com/uc_server",
    "161");

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  Discuz discuz = exclusiveDiscuz;
  Object? startupError;
  StackTrace? startupStackTrace;

  try {
    await _initRequiredStartupServices();

    log("languages initialization");
    initialPlatform = await UserPreferencesUtils.getPlatformPreference();
    discuz = await _prepareExclusiveDiscuzIfNeeded();
  } catch (error, stackTrace) {
    startupError = error;
    startupStackTrace = stackTrace;
    log("Startup initialization failed", error: error, stackTrace: stackTrace);
  }

  runApp(_buildRootApp(
    discuz: discuz,
    startupError: startupError,
    startupStackTrace: startupStackTrace,
  ));

  FlutterNativeSplash.remove();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (startupError == null) {
      unawaited(_initDeferredStartupServices());
    }
  });
}

Future<void> _initRequiredStartupServices() async {
  await Hive.initFlutter();
  await AppDatabase.initBoxes();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GStrorage.init();
}

Future<Discuz> _prepareExclusiveDiscuzIfNeeded() async {
  Discuz discuz = exclusiveDiscuz;

  if (isExclusiveDiscuz) {
    DiscuzDao discuzDao = await AppDatabase.getDiscuzDao();
    Discuz? existDiscuz =
        discuzDao.findDiscuzByBaseURL(exclusiveDiscuz.baseURL);
    if (existDiscuz == null) {
      // insert it if not exist
      var insertKey = await discuzDao.insertDiscuz(exclusiveDiscuz);
      log(insertKey.toString());
    }
    // final extract
    Discuz? savedDiscuz =
        discuzDao.findDiscuzByBaseURL(exclusiveDiscuz.baseURL);
    if (savedDiscuz != null) {
      log("find the discuz!");
      discuz = savedDiscuz;
    } else {
      log("Can't find the saved discuz in dataset");
    }
  }

  return discuz;
}

Future<void> _initDeferredStartupServices() async {
  try {
    await MobileAds.instance.initialize();
  } catch (error, stackTrace) {
    log("Mobile ads initialization failed",
        error: error, stackTrace: stackTrace);
  }

  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    if (Platform.isIOS) {
      String? apnsToken = await messaging.getAPNSToken();
      log("Get APNS token $apnsToken");
    }
    await PushServiceUtils.initFirebaseLocalNotification();
  } catch (error, stackTrace) {
    log("Push initialization failed", error: error, stackTrace: stackTrace);
  }

  try {
    await AppDatabase.removeAllExpiredRecord();
  } catch (error, stackTrace) {
    log("Expired record cleanup failed", error: error, stackTrace: stackTrace);
  }
}

Widget _buildRootApp({
  required Discuz discuz,
  Object? startupError,
  StackTrace? startupStackTrace,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(
        value: ThemeNotifierProvider(platformName: initialPlatform),
      ),
      ChangeNotifierProvider.value(value: DiscuzAndUserNotifier()),
      ChangeNotifierProvider.value(value: ReplyPostNotifierProvider()),
      ChangeNotifierProvider.value(value: TypeSettingNotifierProvider()),
      ChangeNotifierProvider.value(value: UserPreferenceNotifierProvider()),
      ChangeNotifierProvider.value(value: SelectedTidNotifierProvider()),
      ChangeNotifierProvider.value(
        value: DiscuzNotificationProvider(),
      )
    ],
    child: startupError == null
        ? isExclusiveDiscuz
            ? ExclusiveDiscuzApp(initialPlatform, discuz)
            : MyApp(initialPlatform, navigatorKey)
        : StartupErrorApp(
            error: startupError,
            stackTrace: startupStackTrace,
          ),
  );
}

class StartupErrorApp extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;

  const StartupErrorApp({
    super.key,
    required this.error,
    this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Startup failed",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "The app failed before the main interface could be rendered.",
                  ),
                  const SizedBox(height: 16),
                  SelectableText(error.toString()),
                  if (stackTrace != null) ...[
                    const SizedBox(height: 16),
                    SelectableText(stackTrace.toString()),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
