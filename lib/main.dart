import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lottie/lottie.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:studioh_ceramic_cafe_client/cubit/auth_cubit/auth_cubit.dart';
import 'package:studioh_ceramic_cafe_client/cubit/chat_cubit/chat_cubit.dart';
import 'package:studioh_ceramic_cafe_client/cubit/notification_cubit/notification_cubit.dart';
import 'package:studioh_ceramic_cafe_client/firebase_options.dart';
import 'package:studioh_ceramic_cafe_client/screens/splash_screen.dart';
import 'package:studioh_ceramic_cafe_client/utils/route/app_router.dart';
import 'package:studioh_ceramic_cafe_client/utils/route/app_routes.dart';
import 'cubit/order_cubit/order_cubit.dart';
import 'services/api_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

//  Flag to track initialization status
bool _initializationComplete = false;

/// Global navigator key to access context from anywhere (for refreshing cubits)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //  Initialize Firebase immediately (required for app)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print(' Firebase initialized');
  } catch (e) {
    print(' Firebase initialization error: $e');
  }

  // Initialize RevenueCat BEFORE runApp to prevent crashes
  try {
    await initializeRevenueCat();
    print(' RevenueCat initialized');
  } catch (e) {
    print(' RevenueCat initialization failed: $e');
  }

  // Initialize API service (Dio interceptors)
  ApiService.init();

  runApp(const MyApp());

  //  Setup messaging in background (doesn't block UI)
  _setupMessaging();
}

Future<void> _setupMessaging() async {
  try {
    print('Setting up messaging in background...');

    //  Request permissions (iOS only)
    // provisional: false — provisional authorisation delivers quietly (Notification
    // Centre only, no banner, no sound) and never shows the permission prompt.
    await FirebaseMessaging.instance.requestPermission(
      provisional: false,
      alert: true,
      badge: true,
      sound: true,
    );
    print(' Permissions requested');

    // Get tokens asynchronously
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    print('APNS Token: $apnsToken');

    final fcmToken = await FirebaseMessaging.instance.getToken();
    print('Initial FCM Token: $fcmToken');

    //  Subscribe to topic
    await FirebaseMessaging.instance.subscribeToTopic('allUsers');
    print(' Subscribed to topic');

    // RevenueCat is now initialized in main() before runApp()

    //  Setup local notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          _handleNotificationTap(response.payload!);
        }
      },
    );
    print(' Local notifications initialized');

    //  Create Android channel
    const channel = AndroidNotificationChannel(
      'default_channel',
      'General Notifications',
      description: 'All general app notifications',
      importance: Importance.max,
      playSound: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Setup message handlers
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final data = message.data;

      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: data['screen'],
        );
      }

      // Refresh data in the current view when a foreground notification arrives
      _refreshCurrentData();
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message?.data['screen'] != null) {
        _handleNotificationTap(message!.data['screen']);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data['screen'] != null) {
        _handleNotificationTap(message.data['screen']);
      }
    });

    // Token refresh listener — also register with Laravel backend
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      print('Refreshed FCM Token: $token');
      ApiService.registerDevice(
        fcmToken: token,
        platform: Platform.isIOS ? 'ios' : 'android',
      ).catchError((_) {});
    });

    // Register FCM token with Laravel backend
    if (fcmToken != null) {
      try {
        await ApiService.registerDevice(
          fcmToken: fcmToken,
          platform: Platform.isIOS ? 'ios' : 'android',
        );
        print('FCM token registered with backend');
      } catch (_) {
        // Silently fail — user may not be logged in yet
      }
    }

    print('All messaging setup complete');
    _initializationComplete = true;
  } catch (e) {
    print('❌ Error in messaging setup: $e');
    _initializationComplete = true; // Mark complete even if error
  }
}

/// Refresh all data when a foreground notification is received
void _refreshCurrentData() {
  try {
    final context = navigatorKey.currentContext;
    if (context == null) {
      print('⚠️ No context available to refresh data');
      return;
    }

    print('🔄 Refreshing data after foreground notification...');

    // Refresh orders (root-level cubit)
    try {
      context.read<OrderCubit>().fetchOrders();
      print('✅ Orders refreshed');
    } catch (_) {}

    // Refresh chat list (root-level cubit)
    try {
      context.read<ChatCubit>().loadChatList();
      print('✅ Chat list refreshed');
    } catch (_) {}

    // Update the notification bell badge — the push has just been recorded
    // server-side, so the unread count has changed.
    try {
      context.read<NotificationCubit>().refreshUnreadCount();
      print('✅ Notification badge refreshed');
    } catch (_) {}
  } catch (e) {
    print('❌ Error refreshing data: $e');
  }
}

Future<void> initializeRevenueCat() async {
  // Import the RevenueCat service
  // Note: Update API keys in lib/services/revenuecat_service.dart
  String apiKey;
  if (Platform.isIOS) {
    apiKey = 'appl_fTbRCxqjIfcJrTJKlJeUlViBxLU';
  } else if (Platform.isAndroid) {
    apiKey = 'goog_YOUR_ANDROID_KEY_HERE';
  } else {
    throw UnsupportedError('Platform not supported');
  }

  await Purchases.setLogLevel(LogLevel.debug);
  await Purchases.configure(PurchasesConfiguration(apiKey));
}

void _handleNotificationTap(String payload) {
  if (payload == "specialScreen") {
    // Navigation handled by routes
  }
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // AuthCubit - created once
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
        // Drives the notification panel and its bell badge
        BlocProvider<NotificationCubit>(create: (_) => NotificationCubit()),
        // OrderCubit depends on AuthCubit
        BlocProvider<OrderCubit>(
          create: (context) => OrderCubit(authCubit: context.read<AuthCubit>()),
        ),
        // ChatCubit depends on AuthCubit
        BlocProvider<ChatCubit>(
          create: (context) => ChatCubit(
            currentUserId: '',
            orderCubit: context.read<OrderCubit>(),
          ),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Poppins',
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        title: 'StudioH Ceramic Cafe',
        home: const SplashScreen(),
        onGenerateRoute: AppRouter.generateRoute,
        navigatorObservers: [routeObserver],
      ),
    );
  }
}
