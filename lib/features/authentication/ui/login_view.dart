import 'package:flutter/material.dart';

import '../../../core/presentation/presentation.dart';
import '../../../core/service_locator/service_locator.dart';
import '../../../services/local_db_service/sqflite_db.dart';
import '../domain/login_vm.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  void initState() {
    super.initState();

    // Test insert
    Future.microtask(() async {
      await [
        ServiceLocator.get<SqliteDb>().create('countries', {
          'name': 'Nigeria',
          'country_code': 'NG',
          'phone_code': '+234',
        }),
        ServiceLocator.get<SqliteDb>().create('countries', {
          'name': 'Ghana',
          'country_code': 'GH',
          'phone_code': '+223',
        }),
        ServiceLocator.get<SqliteDb>().create('owners', {
          'owner_id': 'john_doe',
          'alias': 'John Doe',
          'device_alias': 'Infinix',
          'country_code': 'NG',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }),
      ].wait;

      final (countries, owners, joinTable) = await (
        ServiceLocator.get<SqliteDb>().retrieve('countries'),
        ServiceLocator.get<SqliteDb>().retrieve('owners'),
        ServiceLocator.get<SqliteDb>().retrieve(
          '_',
          rawQuery: (
            sql:
                'SELECT countries.country_code, countries.phone_code, owners.alias, owners.owner_id FROM countries INNER JOIN owners ON countries.country_code=owners.country_code',
            args: [],
          ),
        ),
      ).wait;
      debugPrint('$countries\n$owners\n$joinTable');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppView<LoginVm>(
        model: ServiceLocator.get(),
        builder: (vm, _) => Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: vm.emailField,
              label: context.translations.email,
              keyboardType: TextInputType.emailAddress,
              capitalization: TextCapitalization.none,
            ),
            SizedBox(height: 16),
            AppTextField(controller: vm.passwordField, label: context.translations.password),
            SizedBox(height: 16),
            AppViewSelector<LoginVm, bool>(
              selector: (vm) => vm.isBusy,
              builder: (isBusy, child) => AppButton.primary(
                onPressed: vm.login,
                busy: isBusy,
                label: context.translations.login,
              ),
            ),
            AppViewSelector<LoginVm, bool>(
              selector: (vm) => vm.hasEncounteredError,
              builder: (hasEncounteredError, child) => hasEncounteredError
                  ? Text('Login failed - ${vm.lastFailure?.message ?? ''}')
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
