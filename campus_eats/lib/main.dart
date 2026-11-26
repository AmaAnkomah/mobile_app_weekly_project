import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'models/cart_item_model.dart';
import 'screens/auth/login_screen.dart';
import 'screens/student/home_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart'; 

import 'services/auth_service.dart';
import 'services/cart_service.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';

import 'viewmodels/admin_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/cart_viewmodel.dart';
import 'viewmodels/menu_viewmodel.dart';
import 'viewmodels/order_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 2. Initialize Hive for Offline Cart
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(CartItemModelAdapter());
  }
  final cartService = CartService();
  await cartService.init();

  // (Optional) One-time seed for the new project
  final firestoreService = FirestoreService();
  await firestoreService.seedDatabase();

  runApp(
    MultiProvider(
      providers: [
        // Services
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
        Provider(create: (_) => StorageService()),
        Provider.value(value: cartService),
        
        // ViewModels
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(context.read<AuthService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => MenuViewModel(context.read<FirestoreService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => CartViewModel(context.read<CartService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => OrderViewModel(context.read<FirestoreService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => AdminViewModel(context.read<FirestoreService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileViewModel(context.read<FirestoreService>()),
        ),
      ],
      child: const CampusEatsApp(),
    ),
  );
}

class CampusEatsApp extends StatelessWidget {
  const CampusEatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Eats VVU',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    if (authVM.status == AuthStatus.initial || authVM.status == AuthStatus.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (authVM.status == AuthStatus.unauthenticated || authVM.user == null) {
      return const LoginScreen();
    }

    if (authVM.user!.isAdmin) {
      return const AdminDashboardScreen();
    }

    return const HomeScreen();
  }
}
