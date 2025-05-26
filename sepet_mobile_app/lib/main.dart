import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'firebase_options.dart';
import 'constants/app_strings.dart';
import 'constants/app_theme.dart';
import 'screens/auth_wrapper.dart';
import 'screens/demo_auth_wrapper.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/demo_auth_service.dart';
import 'services/demo_firestore_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Demo mode switch - geliştirme için true, production için false
const bool USE_DEMO_MODE = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!USE_DEMO_MODE) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully');

      // Firebase Messaging'i sadece mobil platformlarda başlat
      if (!kIsWeb) {
        await _initFirebaseMessaging();
      } else {
        print('Web platformu - FCM devre dışı');
      }
    } catch (e) {
      print('Firebase initialization error: $e');
      // Firebase başlatma hatası durumunda uygulamayı kapat
      if (!e.toString().contains('duplicate-app')) {
        print('Kritik Firebase hatası - Uygulama kapatılıyor');
        return;
      }
      print('Firebase already initialized');
      // Firebase Messaging'i sadece mobil platformlarda başlat
      if (!kIsWeb) {
        await _initFirebaseMessaging();
      }
    }
  } else {
    print('Demo mode aktif - Firebase servisleri devre dışı');
  }

  runApp(const SepetApp());
}

Future<void> _initFirebaseMessaging() async {
  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Bildirim izni iste
    await messaging.requestPermission();

    // Token al
    String? token = await messaging.getToken();
    print('FCM Token: ${token ?? 'null'}');

    // Foreground mesajları dinle
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          'Foreground mesaj geldi: ${message.notification?.title} - ${message.notification?.body}');
    });

    // Arka planda/kapalıyken gelen mesajlar için (opsiyonel)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    print('FCM initialization error: $e');
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(
      'Background mesaj geldi: ${message.notification?.title} - ${message.notification?.body}');
}

class SepetApp extends StatelessWidget {
  const SepetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: USE_DEMO_MODE ? _getDemoProviders() : _getFirebaseProviders(),
      child: MaterialApp(
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Sistem temasını takip et
        home: USE_DEMO_MODE ? const DemoAuthWrapper() : const AuthWrapper(),
      ),
    );
  }

  List<SingleChildWidget> _getDemoProviders() {
    return [
      // Demo services
      Provider<DemoAuthService>(
        create: (_) => DemoAuthService()..initialize(),
      ),
      Provider<DemoFirestoreService>(
        create: (_) => DemoFirestoreService()..initialize(),
      ),
    ];
  }

  List<SingleChildWidget> _getFirebaseProviders() {
    return [
      // Firebase services
      Provider<AuthService>(
        create: (_) => AuthService(),
      ),
      Provider<FirestoreService>(
        create: (_) => FirestoreService(),
      ),
      // Auth state stream provider
      StreamProvider(
        create: (context) => context.read<AuthService>().authStateChanges,
        initialData: null,
      ),
    ];
  }
}
