import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'service_locator.config.dart';

@InjectableInit(initializerName: 'init', preferRelativeImports: true, asExtension: true)
void configureDependencies() => ServiceLocator.get.init();

abstract class ServiceLocator {
  final GetIt locator;

  ServiceLocator(this.locator);

  FutureOr<void> register();

  static final get = GetIt.instance;

  static Future<void> reset() async {
    await get.reset();
    configureDependencies();
  }

  static void resetInstance<T extends Object>() {
    get.resetLazySingleton<T>();
  }
}
