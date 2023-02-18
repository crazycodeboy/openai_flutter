import 'dart:developer' as dev;

class AILogger {
  /// This represents the default value of the logger enable state.
  static bool _isEnable = true;

  /// Changes the logger enable state.
  /// true, the logger will log messages.
  /// false, the logger will not log messages.
  /// The default value is [_isEnable].
  static set isEnable(bool value) {
    _isEnable = value;
  }

  /// Logs a message, if the logger is active.
  static void log(String message) {
    if (!_isEnable) {
      return;
    }

    dev.log(
      message,
      name: 'AILogger',
    );
  }
}
