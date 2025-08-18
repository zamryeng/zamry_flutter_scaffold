import 'dart:async';

import '../../features/authentication/data/authentication_repo.dart';
import '../../features/authentication/domain/login_vm.dart';
import '../../features/onboarding/data/onboarding_repository.dart';
import '../../features/onboarding/domain/onboarding_vm.dart';
import 'service_locator.dart';

class FeatureDependencies extends ServiceLocator {
  FeatureDependencies(super.locator);

  @override
  FutureOr<void> register() {
    // Register all feature dependencies here

    // Authentication
    locator.registerFactory<LoginVm>(() => LoginVm(authRepo: locator()));
    locator.registerLazySingleton<AuthenticationRepo>(
      () => AuthenticationRepo(networkService: locator()),
    );

    // Onboarding
    locator.registerLazySingleton<OnboardingRepository>(() => OnboardingRepository());
    locator.registerFactory<OnboardingVm>(() => OnboardingVm(repository: locator()));
  }
}
