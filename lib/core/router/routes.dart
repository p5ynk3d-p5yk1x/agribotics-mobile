import 'package:agribotics/core/auth/auth_state.dart';
import 'package:agribotics/core/providers/app_providers.dart';
import 'package:agribotics/core/router/router_notifier.dart';
import 'package:agribotics/features/auth/presentation/login-page.dart';
import 'package:agribotics/features/disease/presentation/pages/disease_detection_page.dart';
import 'package:agribotics/features/disease/presentation/pages/disease_history.dart';
import 'package:agribotics/features/disease/presentation/pages/disease_map.dart';
import 'package:agribotics/features/land/presentation/pages/land_dashboard_page.dart';
import 'package:agribotics/features/land/presentation/pages/land_selection_page.dart';
import 'package:agribotics/features/soil/presentation/pages/nutrient_detection_page.dart';
import 'package:agribotics/features/weeds/presentation/pages/weed_detection.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/estate/presentation/pages/sector_detail_page.dart';
import '../../features/soil/presentation/pages/soil_history.dart';
import '../../features/soil/presentation/pages/soil_map.dart';
import '../../features/soil/presentation/pages/soil_report.dart';
import '../../features/identify/presentation/pages/identify_page.dart';
import '../../features/weeds/presentation/pages/weed_diagnosis.dart';
import '../../features/weeds/presentation/pages/weed_history.dart';
import '../../features/weeds/presentation/pages/weed_map.dart';
import '../../features/weeds/presentation/pages/weed_detail.dart';
import '../../features/market/presentation/pages/market_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../../features/market/presentation/pages/product_detail_page.dart';

const publicRoutes = {
  '/login'
};

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoading = authState is AuthLoading;
      final isAuthenticated = authState is AuthAuthenticated;
      final isPublic = publicRoutes.contains(state.matchedLocation);

      if (isLoading) return null;

      if (!isAuthenticated && !isPublic) {
        return '/login';
      }

      if (isAuthenticated && state.matchedLocation == '/login') {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            MainScaffold(child: child),
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) =>
                const LandDashboardPage(),
              ),
              GoRoute(
                path: '/land/select',
                builder: (context, state) =>
                const LandSelectionPage(),
              ),
              GoRoute(
                path: '/sector-detail',
                builder: (context, state) =>
                const SectorDetailPage(),
              ),
              GoRoute(
                path: '/soil/detection',
                builder: (context, state) =>
                const SoilDetectionPage(),
              ),
              GoRoute(
                path: '/soil/history',
                builder: (context, state) =>
                const SoilNutrientHistory(),
              ),
              GoRoute(
                path: '/soil/nutrient-map',
                builder: (context, state) =>
                const SoilNutrientMap(),
              ),
              GoRoute(
                path: '/soil/vitality-report',
                builder: (context, state) =>
                const SoilReport(),
              ),
              GoRoute(
                path: '/identify',
                builder: (context, state) =>
                const IdentifyPage(),
              ),
              GoRoute(
                path: '/weed/diagnosis',
                builder: (context, state) =>
                const WeedDiagnosis(),
              ),
              GoRoute(
                path: '/weed/history',
                builder: (context, state) =>
                const WeedDetectionHistory(),
              ),
              GoRoute(
                path: '/weed/map',
                builder: (context, state) =>
                const WeedMap(),
              ),
              GoRoute(
                path: '/weed/detail',
                builder: (context, state) =>
                const WeedDetails(),
              ),
              GoRoute(
                path: '/weed/detection',
                builder: (context, state) =>
                const WeedDetectionPage(),
              ),
              GoRoute(
                path: '/disease/map',
                builder: (context, state) =>
                const DiseasePathogenMapScreen(),
              ),
              GoRoute(
                path: '/disease/history',
                builder: (context, state) =>
                const DiseaseDetectionHistory(),
              ),
              GoRoute(
                path: '/disease/detection',
                builder: (context, state) =>
                const DiseaseDetectionPage(),
              ),
              GoRoute(
                path: '/market',
                builder: (context, state) => const MarketPage(),
              ),
              GoRoute(
                path: '/market/product/:id',
                builder: (context, state) => ProductDetailPage(
                  productId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: '/settings',
                builder: (context, state) =>
                const SettingsPage(),
              ),
        ],
      ),
    ],
  );
});