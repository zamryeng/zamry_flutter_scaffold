import 'package:flutter/material.dart';

import '../service_locator/service_locator.dart';
import 'failure.dart';

sealed class UiState<T> {
  const UiState();

  T get requireData => throw StateError('Data not available for this ui state');

  T? get data => null;

  Failure? get failure => null;

  bool get hasData => data != null;

  bool get isUninitialised => switch (this) {
    Uninitialised() => true,
    _ => false,
  };

  bool get isLoading => switch (this) {
    Loading() => true,
    _ => false,
  };

  bool get isSuccess => switch (this) {
    Success() => true,
    _ => false,
  };

  bool get isError => switch (this) {
    Failure() => true,
    _ => false,
  };

  bool get hasNoConnection => failure is NetworkFailure;
}

class Uninitialised<T> extends UiState<T> {
  const Uninitialised();
}

class Success<T> extends UiState<T> {
  const Success(this.result);

  final T result;

  @override
  T? get data => result;

  @override
  T get requireData => result;
}

class Loading<T> extends UiState<T> {
  const Loading([this.data]);

  @override
  final T? data;

  @override
  T get requireData => hasData ? data! : super.requireData;
}

class Error<T> extends UiState<T> {
  const Error(this.error, [this.data]);

  final Failure error;
  @override
  final T? data;

  @override
  T get requireData => hasData ? data! : super.requireData;

  @override
  Failure? get failure => error;
}

abstract class MessageDisplayHandler {
  void showError(String message, [String? heading]);

  void showSuccess(String message, [String? heading]);

  void showWarning(String message, [String? heading]);

  void showInfo(String message, [String? heading]);
}

/// A base class for creating view models as [ChangeNotifier]s that hold UI and other logic for a particular screen or feature.
///
/// This class implements the ViewModel layer of the MVVM (Model-View-ViewModel) architecture pattern.
/// It extends [ChangeNotifier] to provide reactive state management, allowing the UI to automatically
/// rebuild when the view model's state changes.
///
/// The UI listens to instances of this class and rebuilds itself based on its members.
/// The UI (buttons and gestures) may also call methods on instances of this class to trigger
/// business logic operations.
///
/// This class sits between the UI and the data layer, providing a clean separation of concerns
/// and making the code more testable and maintainable.
///
/// Example usage:
/// ```dart
/// class LoginViewModel extends AppViewModel {
///   Future<void> login(String email, String password) async {
///     setState(VmState.busy);
///     try {
///       // Perform login logic
///       setState(VmState.none);
///     } catch (e) {
///       handleErrorAndSetVmState(Failure(e.toString()));
///     }
///   }
/// }
/// ```
abstract class AppViewModel extends ChangeNotifier {
  AppViewModel([MessageDisplayHandler? messageHandler])
    : messageHandler = messageHandler ?? ServiceLocator.get<MessageDisplayHandler>();

  /// The error handler instance used by this view model.
  ///
  /// This field holds the error handler that is responsible for processing
  /// and displaying errors that occur during view model operations. It can
  /// be injected through the constructor or retrieved from the service locator
  /// if not provided.
  ///
  /// The error handler is used by methods like [handleError] and
  /// [handleErrorAndSetUiState] to ensure consistent error handling across
  /// all view models in the application.
  ///
  /// If no error handler is provided in the constructor, the default error
  /// handler from the service locator is used.
  final MessageDisplayHandler messageHandler;

  /// Whether the view model has been disposed.
  ///
  /// This flag prevents operations on a disposed view model and helps
  /// avoid memory leaks and invalid state updates.
  bool _disposed = false;

  /// The last failure that occurred in the view model.
  ///
  /// This field stores the most recent failure for debugging purposes
  /// and can be used to display error information to the user.
  Failure? _lastFailure;

  /// Returns the last failure that occurred in the view model.
  ///
  /// This getter provides access to the most recent failure for debugging
  /// or error reporting purposes.
  Failure? get lastFailure => _lastFailure;

  /// Returns true if the view model has encountered an error, false otherwise.
  ///
  /// This getter checks if the current state is either [VmState.error] or [VmState.noConnection].
  /// It's useful for determining whether to show error UI or disable certain actions.

  /// Called by the framework when the object is no longer needed.
  ///
  /// This method is called when the view model is being disposed of.
  /// It calls the parent class's dispose method and sets the [_disposed] flag
  /// to prevent further operations on the disposed view model.
  ///
  /// Override this method if you need to perform additional cleanup
  /// (e.g., canceling streams, disposing of controllers).
  @override
  void dispose() {
    super.dispose();
    _disposed = true;
  }

  /// Sets the view model's state to [viewState] and notifies any listeners of the change.
  ///
  /// This method is the primary way to update the view model's state. It updates
  /// the [_viewState] field and notifies all listeners (typically UI widgets)
  /// that the state has changed, causing them to rebuild.
  ///
  /// If [viewState] is null, the view model's state is not updated, but its
  /// listeners are still notified. This is useful for triggering UI updates
  /// without changing the state (e.g., when data is refreshed).
  ///
  /// The method checks if the view model has been disposed before notifying
  /// listeners to prevent operations on disposed objects.
  ///
  /// Example usage:
  /// ```dart
  /// setState(VmState.busy); // Set to busy state
  /// setState(VmState.none); // Set to normal state
  /// setState(); // Notify listeners without changing state
  /// ```

  @protected
  void setState(final VoidCallback onStateUpdate) {
    onStateUpdate();
    if (!_disposed && hasListeners) notifyListeners();
  }

  /// Handles a [failure] by displaying an error message and storing the failure.
  ///
  /// This method processes a failure by:
  /// 1. Checking if it's a [BadAuthFailure] and handling it appropriately
  /// 2. Displaying an error toast to the user if the view model has listeners
  /// 3. Storing the failure in [_lastFailure] for debugging purposes
  ///
  /// The method only shows the error toast if the view model has listeners
  /// (i.e., if it's currently being used by a UI widget).
  ///
  /// [failure] The failure to handle.
  /// [heading] An optional heading for the error message (currently unused).
  @protected
  void handleError(Failure failure, [String? heading]) {
    if (failure is BadAuthFailure) {
      // TODO(MajorE): Handle bad auth failure
    }
    if (hasListeners) {
      messageHandler.showError(failure.message);
      _lastFailure = failure;
    }
  }

  @protected
  UiState<S> handleErrorAndSetUiState<S>(Error state, [String? heading]) {
    handleError(state.error, heading);

    return Uninitialised<S>();
  }
}

extension UiDataStateX<T> on UiState<T> {
  UiState<T> loading([T? data]) {
    if (data != null) return Loading(data);

    return switch (this) {
      Success<T>(result: final data) => Loading(data),
      Loading<T>(:final data?) => Loading(data),
      Error<T>(:final data) => Loading(data),
      _ => const Loading(),
    };
  }

  UiState<T> success(T data) {
    return Success(data);
  }

  UiState<T> error(Failure error) {
    return switch (this) {
      Success<T>(result: final data) => Error(error, data),
      Loading<T>(:final data?) => Error(error, data),
      _ => Error(error),
    };
  }
}
