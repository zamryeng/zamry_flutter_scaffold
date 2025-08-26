import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../main/environment_config.dart';
import '../../services/analytics_service/analytics_service.dart';
import '../../services/analytics_service/firebase_analytics_service.dart';
import '../../services/build_info_service/build_info_service.dart';
import '../../services/error_logging_service/error_logging_service.dart';
import '../../services/local_db_service/sqflite_db_service.dart';
import '../../services/local_storage_service/flutter_secure_local_storage_service.dart';
import '../../services/local_storage_service/local_storage_service.dart';
import '../../services/rest_network_service/dio_network_service.dart';
import '../../services/rest_network_service/rest_network_service.dart';
import '../../utilities/constants/constants.dart';
import '../domain/app_view_model.dart';
import '../domain/session_manager.dart';
import '../presentation/ui_components/overlays/app_toast_widget.dart';
import 'service_locator.dart';

@module
abstract class ServiceModule {
  @factory
  LocalStorageService localStorage() =>
      FlutterSecureLocalStorage(flutterSecureStorage: const FlutterSecureStorage());

  @singleton
  ErrorLogService get errorLogService =>
      ErrorLogService.instance..initialise(shouldLog: EnvironmentConfig.isProd);

  @lazySingleton
  MessageDisplayHandler get messageDisplayHandler => ToastErrorHandler();

  @lazySingleton
  SessionManager get sessionManager => SessionManager(
    localStorageService: ServiceLocator.get(),
    errorLogService: ServiceLocator.get(),
    analyticsService: ServiceLocator.get(),
  );

  @lazySingleton
  RestNetworkService get restService => DioNetworkService(
    sessionManager: ServiceLocator.get(),
    baseUrl: EnvironmentConfig.apiUrl,
    isProd: EnvironmentConfig.isProd,
    sendTimeout: Constants.networkTimeoutDuration,
  );

  @lazySingleton
  AnalyticsService get analytics => AnalyticsCombinatorService([
    FirebaseAnalyticsService(firebaseAnalytics: FirebaseAnalytics.instance),
  ])..configure(EnvironmentConfig.isProd);

  @lazySingleton
  BuildInfoService get buildInfoService =>
      BuildInfoServiceImpl(deviceInfoPlugin: DeviceInfoPlugin());

  @lazySingleton
  SqliteDb get db => SqliteDb();
}
