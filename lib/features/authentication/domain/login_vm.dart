import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../core/domain/app_view_model.dart';
import '../data/authentication_repo.dart';
import 'models/user_model.dart';

@injectable
class LoginVm extends AppViewModel {
  final AuthenticationRepo _authRepo;

  LoginVm({required AuthenticationRepo authRepo}) : _authRepo = authRepo;

  UiState<LoginInfo> _loginUiState = const Uninitialised();

  UiState<LoginInfo> get loginUiState => _loginUiState;

  final emailField = TextEditingController();
  final passwordField = TextEditingController();

  Future<void> login() async {
    // Validation

    // Send to Server
    setState(() {
      _loginUiState = _loginUiState.loading();
    });
    final login = await _authRepo.login(email: emailField.text, password: passwordField.text);

    setState(() {
      _loginUiState = login.fold(_loginUiState.error, _loginUiState.success);
    });

    switch (_loginUiState) {
      case Error e:
        setState(() {
          _loginUiState = handleErrorAndSetUiState(e);
        });
      default:
    }
  }
}
