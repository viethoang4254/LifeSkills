// Export all state widgets and utilities
export 'loading_widget.dart';
export 'error_widget.dart';
export 'empty_state_widget.dart';
export 'success_dialog.dart';

/// UI State enum - dùng để quản lý các state
enum UIState { idle, loading, success, error, empty }

/// Error model
class UIError {
  final String title;
  final String? message;
  final String? code;

  UIError({required this.title, this.message, this.code});

  factory UIError.serverError({String? message}) => UIError(
    title: 'Lỗi máy chủ',
    message: message ?? 'Không thể kết nối đến máy chủ',
    code: 'SERVER_ERROR',
  );

  factory UIError.networkError() => UIError(
    title: 'Lỗi kết nối',
    message: 'Vui lòng kiểm tra kết nối Internet của bạn',
    code: 'NETWORK_ERROR',
  );

  factory UIError.genericError({String? message}) => UIError(
    title: 'Có lỗi xảy ra',
    message: message ?? 'Vui lòng thử lại',
    code: 'UNKNOWN_ERROR',
  );
}
