class AppRoute {
  final String name;
  final String path;
  final Map<String, String> queryParameters;
  final Map<String, String> pathParameters;

  const AppRoute({
    required this.name,
    required this.path,
    this.queryParameters = const {},
    this.pathParameters = const {},
  });

  @override
  String toString() => name;
}

abstract class AppRoutes {
  static const splash = AppRoute(name: 'splash', path: '/splash');

  static const onboarding = AppRoute(name: 'onboarding-home', path: '/onboarding');
  static const onboardingFlow = AppRoute(name: 'onboarding-flow', path: ':page');
  static const login = AppRoute(name: 'login', path: '/login');
  static const dashboard = AppRoute(name: 'dashboard', path: '/');

  static AppRoute profile(String id) =>
      AppRoute(name: 'profile', path: '/:id/profile', pathParameters: {'id': id});
}
