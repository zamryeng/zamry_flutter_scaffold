import 'package:go_router/go_router.dart';

import '../../../features/dashboard/ui/ui.dart';
import '../../../features/onboarding/ui/ui.dart';
import '../../../features/splash/ui/splash_screen.dart';
import '../ui_components/others/error_view.dart';
import 'app_navigator.dart';
import 'app_routes.dart';

abstract class AppRouter {
  // Global navigator key for context-free navigation

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash.path,
    debugLogDiagnostics: true,
    navigatorKey: AppNavigator.mainNavigatorKey,
    redirect: (context, state) {
      // Handle redirects here
      //
      return null; // No redirect needed
    },
    errorBuilder: (context, state) => ErrorView(
      error: state.error ?? 'Unknown error',
      routeName: state.uri.path,
      path: state.uri.toString(),
    ),
    routes: [
      GoRoute(
        path: AppRoutes.splash.path,
        name: AppRoutes.splash.name,
        builder: (context, state) => SplashScreen(
          onProceed: () {
            context.goNamed(AppRoutes.onboarding.name);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding.path,
        name: AppRoutes.onboarding.name,
        builder: (context, state) {
          return OnboardingHomeScreen(
            onGetStarted: () {
              context.goNamed(
                AppRoutes.onboardingFlow.name,
                pathParameters: {'page': OnboardingPage.countrySelection.value},
              );
            },
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.onboardingFlow.path,
            name: AppRoutes.onboardingFlow.name,
            builder: (context, state) {
              final page = OnboardingPage.fromString(state.pathParameters['page']!);
              return OnboardingScreen(
                page: page,
                onComplete: () {
                  context.goNamed(AppRoutes.dashboard.name);
                },
                onForward: (page) {
                  context.goNamed(
                    AppRoutes.onboardingFlow.name,
                    pathParameters: {'page': page.value},
                  );
                },
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.dashboard.path,
        name: AppRoutes.dashboard.name,
        builder: (context, state) {
          return DashboardScreen();
        },
      ),
      // GoRoute(
      //   path: AppRoutes.login.path,
      //   name: AppRoutes.login.name,
      //   builder: (context, state) => const LoginView(),
      // ),
      // Dynamic routes
      // GoRoute(
      //   path: '/user/:userId', // Use the path pattern that matches userProfile function
      //   name: AppRoutes.userProfile('').name, // Use the name from the route definition
      //   builder: (context, state) {
      //     final userId = state.pathParameters['userId']!;
      //     return UserProfileView(userId: userId);
      //   },
      // ),
    ],
  );
}
