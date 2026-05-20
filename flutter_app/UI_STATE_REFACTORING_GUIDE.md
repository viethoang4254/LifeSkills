# UI State Management Refactoring Guide

## Tổng Quan

Refactoring này giới thiệu một bộ state widgets chuyên nghiệp để thay thế các trạng thái loading/error/empty text đơn giản.

## Các Widget Mới

### 1. **LoadingWidget** (`lib/widgets/state/loading_widget.dart`)

#### LoadingOverlay

Overlay loading với custom message (dùng cho Stack)

```dart
Stack(
  children: [
    YourContent(),
    LoadingOverlay(
      message: 'Đang đồng bộ dữ liệu...',
      isDismissible: false,
    ),
  ],
);
```

#### LoadingScreen

Full screen loading widget

```dart
const LoadingScreen(
  title: 'Đang khởi động',
  message: 'Vui lòng chờ một chút',
);
```

#### SkeletonLoader

Placeholder loading animation

```dart
SkeletonLoader(
  itemCount: 4,
  itemHeight: 160,
  horizontalPadding: 16,
);
```

---

### 2. **ErrorWidget** (`lib/widgets/state/error_widget.dart`)

#### ErrorOverlay

Overlay khi có lỗi (dùng cho Stack)

```dart
ErrorOverlay(
  title: 'Không thể tải dữ liệu',
  message: 'Kiểm tra kết nối Internet của bạn',
  onRetry: _reload,
  onDismiss: () => Navigator.pop(context),
);
```

#### ErrorScreen

Full screen error widget

```dart
ErrorScreen(
  title: 'Lỗi kết nối',
  message: 'Không thể truy cập máy chủ',
  errorCode: 'NETWORK_ERROR',
  onRetry: _reload,
  onBack: () => Navigator.pop(context),
);
```

---

### 3. **EmptyStateWidget** (`lib/widgets/state/empty_state_widget.dart`)

#### EmptyStateOverlay

Overlay khi không có dữ liệu (dùng cho Stack)

```dart
EmptyStateOverlay(
  icon: '📚',
  title: 'Chưa có kỹ năng nào',
  description: 'Hãy thêm kỹ năng để bắt đầu',
  ctaLabel: 'Thêm ngay',
  onCTA: _createNew,
);
```

#### EmptyStateScreen

Full screen empty state widget

```dart
EmptyStateScreen(
  icon: '🔖',
  title: 'Chưa có bài viết được lưu',
  description: 'Lưu các bài viết yêu thích của bạn',
  ctaLabel: 'Khám phá bài viết',
  onCTA: () => Navigator.pushNamed(context, '/news'),
  onBack: () => Navigator.pop(context),
);
```

---

### 4. **SuccessDialog** (`lib/widgets/state/success_dialog.dart`)

#### SuccessDialog

Dialog thông báo thành công

```dart
showDialog(
  context: context,
  builder: (_) => SuccessDialog(
    title: 'Tạo bài viết thành công',
    message: 'Bài viết của bạn đã được đăng',
    actionLabel: 'Xem ngay',
    onAction: () => _openDetail(),
    autoClose: const Duration(seconds: 3),
  ),
);
```

#### showSuccessSnackBar

SnackBar thành công (dùng cho quick feedback)

```dart
showSuccessSnackBar(
  context,
  message: 'Đã lưu bài viết',
);
```

#### showErrorSnackBar

SnackBar lỗi (dùng cho quick feedback)

```dart
showErrorSnackBar(
  context,
  message: 'Có lỗi xảy ra, thử lại',
);
```

---

## UIState Enum

```dart
enum UIState {
  idle,      // Trạng thái ban đầu
  loading,   // Đang tải dữ liệu
  success,   // Tải thành công, có dữ liệu
  error,     // Có lỗi xảy ra
  empty,     // Tải thành công nhưng không có dữ liệu
}
```

---

## UIError Model

```dart
final _error = UIError(
  title: 'Lỗi tải dữ liệu',
  message: 'Không thể kết nối đến máy chủ',
  code: 'SERVER_ERROR',
);

// Hoặc dùng factory constructors:
UIError.serverError(message: 'Service tạm thời không khả dụng')
UIError.networkError()
UIError.genericError(message: 'Có lỗi không xác định')
```

---

## Refactoring Pattern

### Trước (Cũ)

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  List<dynamic> _items = [];
  bool _isLoading = true;

  Future<void> _load() async {
    try {
      final items = await ApiService.getItems();
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('Không có dữ liệu'))
              : ListView.builder(...),
    );
  }
}
```

### Sau (Mới)

```dart
import 'package:myapp/widgets/state/state_widgets.dart';

class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  List<dynamic> _items = [];
  UIState _state = UIState.loading;
  UIError? _error;

  Future<void> _load() async {
    setState(() {
      _state = UIState.loading;
      _error = null;
    });
    try {
      final items = await ApiService.getItems();
      setState(() {
        _items = items;
        _state = items.isEmpty ? UIState.empty : UIState.success;
      });
    } catch (e) {
      setState(() {
        _state = UIState.error;
        _error = UIError.genericError(message: e.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case UIState.loading:
        return const SkeletonLoader(itemCount: 5);

      case UIState.error:
        return ErrorOverlay(
          title: _error?.title ?? 'Có lỗi xảy ra',
          message: _error?.message,
          onRetry: _load,
          onDismiss: () => Navigator.pop(context),
        );

      case UIState.empty:
        return EmptyStateOverlay(
          icon: '📭',
          title: 'Không có dữ liệu',
          ctaLabel: 'Tải lại',
          onCTA: _load,
        );

      case UIState.success:
      case UIState.idle:
        return ListView.builder(...);
    }
  }
}
```

---

## Screens Đã Refactor

- ✅ `skills_screen.dart`
- ✅ `news_screen.dart`
- ✅ `community_screen.dart`

---

## Screens Cần Refactor (Gợi ý)

- `home_screen.dart` - Thêm error handling chuyên nghiệp
- `fun_screen.dart` - Replace CircularProgressIndicator đơn giản
- `playground_screen.dart` - Thêm error overlay
- `profile_screen.dart` - Thêm empty state khi chưa có data
- `admin_screen.dart` - Thêm error & empty states
- `admin_cms_screen.dart` - Thêm loading skeleton cho danh sách
- `copilot_screen.dart` - Xử lý lỗi API từ Copilot
- `create_post_screen.dart` - Thêm loading dialog khi submit
- `post_detail_screen.dart` - Thêm error handling khi load comments

---

## Best Practices

1. **Luôn set \_state = UIState.loading trước khi API call**

```dart
setState(() {
  _state = UIState.loading;
  _error = null;
});
```

2. **Xử lý 5 trạng thái trong build method**

```dart
switch (_state) {
  case UIState.loading: ...
  case UIState.success: ...
  case UIState.error: ...
  case UIState.empty: ...
  case UIState.idle: ...
}
```

3. **Sử dụng EmptyStateOverlay cho Tab/Filter trống**

```dart
// Nếu list trống nhưng _state == success
if (_filtered.isEmpty && _state == UIState.success) {
  return EmptyStateOverlay(...);
}
```

4. **Sử dụng SuccessDialog cho action penting**

```dart
if (success) {
  showDialog(
    context: context,
    builder: (_) => SuccessDialog(...),
  );
}
```

5. **Sử dụng SnackBars cho quick feedback**

```dart
showSuccessSnackBar(context, message: 'Đã lưu');
```

---

## Lưu Ý

- Không thay đổi logic backend/API
- Chỉ refactor UI layer
- Giữ consistency trong toàn ứng dụng
- Test đầy đủ các trạng thái (loading, error, empty, success)
