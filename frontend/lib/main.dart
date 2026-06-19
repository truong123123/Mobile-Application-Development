import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:le_nhat_truong/features/auth/providers/auth_provider.dart';
import 'package:le_nhat_truong/features/favorites/providers/favorites_provider.dart';
import 'package:le_nhat_truong/features/cart/providers/cart_provider.dart';
import 'package:le_nhat_truong/features/auth/services/auth_service.dart';
import 'package:le_nhat_truong/core/theme/app_theme.dart';

import 'package:le_nhat_truong/core/routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
        ChangeNotifierProvider(
            create: (ctx) => AuthProvider(authService: ctx.read())),
        ChangeNotifierProxyProvider<AuthProvider, FavoritesProvider>(
          create: (_) => FavoritesProvider(),
          update: (_, authProvider, favoritesProvider) {
            final email = authProvider.user?.email;
            if (favoritesProvider != null) {
              favoritesProvider.setCurrentUserEmail(email);
            }
            return favoritesProvider ?? FavoritesProvider();
          },
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'AuthApp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        initialRoute: AppRoutes.splash,
      ),
    );
  }
}
