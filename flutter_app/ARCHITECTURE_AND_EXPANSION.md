# Kiến Trúc & Phương Án Mở Rộng: Từ ~20 screens → 80-100 screens

## 📊 Hiện Tại

- ~16 screens hiện tại
- Cấu trúc: `lib/screens/`, `lib/widgets/`, `lib/utils/`
- Chưa có phân chia flow rõ ràng

---

## 🏗️ Kiến Trúc Proposed (Production-Ready)

### Cấu Trúc Thư Mục

```
lib/
├── main.dart
├── config/
│   ├── routes.dart              # Route definitions
│   ├── theme.dart               # Theme configuration
│   └── constants.dart           # Global constants
├── models/                      # Data models
│   ├── user_model.dart
│   ├── skill_model.dart
│   ├── post_model.dart
│   ├── news_model.dart
│   └── etc.dart
├── providers/                   # State management (GetX/Riverpod)
│   ├── auth_provider.dart
│   ├── skill_provider.dart
│   ├── community_provider.dart
│   └── etc.dart
├── screens/
│   ├── auth/                    # Authentication flow (~5 screens)
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   ├── verify_email_screen.dart
│   │   └── auth_wrapper.dart
│   ├── onboarding/              # Onboarding flow (~4-5 screens)
│   │   ├── onboarding_screen.dart
│   │   ├── intro_screen.dart
│   │   ├── permissions_screen.dart
│   │   └── setup_profile_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   ├── home_detail_screen.dart
│   │   └── widgets/
│   ├── skills/                  # Skills/Learning flow (~8-10 screens)
│   │   ├── skills_screen.dart
│   │   ├── skill_detail_screen.dart
│   │   ├── skill_lesson_screen.dart
│   │   ├── skill_quiz_screen.dart
│   │   ├── skill_certificate_screen.dart
│   │   ├── my_learning_screen.dart
│   │   ├── learning_analytics_screen.dart
│   │   └── widgets/
│   ├── community/               # Community flow (~8-10 screens)
│   │   ├── community_screen.dart
│   │   ├── post_detail_screen.dart
│   │   ├── create_post_screen.dart
│   │   ├── user_profile_screen.dart
│   │   ├── group_screen.dart
│   │   ├── group_detail_screen.dart
│   │   ├── messages_screen.dart
│   │   ├── message_detail_screen.dart
│   │   └── widgets/
│   ├── news/                    # News & Articles flow (~6-8 screens)
│   │   ├── news_screen.dart
│   │   ├── news_detail_screen.dart
│   │   ├── news_categories_screen.dart
│   │   ├── bookmarks_screen.dart
│   │   ├── article_reader_screen.dart
│   │   └── widgets/
│   ├── fun/                     # Fun & Gamification (~5-7 screens)
│   │   ├── fun_screen.dart
│   │   ├── game_screen.dart
│   │   ├── leaderboard_screen.dart
│   │   ├── achievements_screen.dart
│   │   ├── rewards_screen.dart
│   │   └── widgets/
│   ├── profile/                 # User Profile flow (~8-10 screens)
│   │   ├── profile_screen.dart
│   │   ├── edit_profile_screen.dart
│   │   ├── my_skills_screen.dart
│   │   ├── my_certificates_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── privacy_screen.dart
│   │   ├── notifications_screen.dart
│   │   ├── blocked_users_screen.dart
│   │   └── widgets/
│   ├── admin/                   # Admin flow (~8-12 screens)
│   │   ├── admin_dashboard_screen.dart
│   │   ├── admin_users_screen.dart
│   │   ├── admin_user_detail_screen.dart
│   │   ├── admin_skills_screen.dart
│   │   ├── admin_content_screen.dart
│   │   ├── admin_reports_screen.dart
│   │   ├── admin_analytics_screen.dart
│   │   ├── admin_cms_screen.dart
│   │   ├── admin_cms_form_screen.dart
│   │   └── widgets/
│   ├── copilot/                 # AI Copilot flow (~3-4 screens)
│   │   ├── copilot_screen.dart
│   │   ├── copilot_chat_screen.dart
│   │   ├── copilot_suggestions_screen.dart
│   │   └── widgets/
│   ├── playground/              # Code/Skill Playground (~2-3 screens)
│   │   ├── playground_screen.dart
│   │   ├── code_editor_screen.dart
│   │   └── widgets/
│   └── shared/                  # Shared screens (~3-5 screens)
│       ├── search_screen.dart
│       ├── notifications_screen.dart
│       ├── error_screen.dart
│       └── maintenance_screen.dart
├── widgets/
│   ├── state/                   # State widgets (new)
│   │   ├── loading_widget.dart
│   │   ├── error_widget.dart
│   │   ├── empty_state_widget.dart
│   │   ├── success_dialog.dart
│   │   └── state_widgets.dart
│   ├── app_scaffold.dart
│   ├── common_widgets.dart      # Reusable widgets
│   └── etc.dart
├── utils/
│   ├── api_service.dart
│   ├── auth_manager.dart
│   ├── user_progress_manager.dart
│   ├── validators.dart          # Input validation
│   ├── formatters.dart          # Date/number formatting
│   └── logger.dart              # Logging utility
└── services/
    ├── notification_service.dart
    ├── storage_service.dart
    ├── analytics_service.dart
    └── crash_reporting_service.dart
```

---

## 📱 Phần Mở Rộng Chi Tiết

### 1. **AUTH FLOW** (5-6 screens)

Thay thế/bổ sung hiện tại auth_screen.dart

```
✓ Login Screen
✓ Signup Screen
- Forgot Password Screen
- Verify Email Screen (OTP)
- Reset Password Screen
✓ Auth Wrapper (route guard)
```

### 2. **ONBOARDING FLOW** (4-5 screens)

Hoàn toàn mới - bắt buộc khi user lần đầu đăng nhập

```
- Onboarding Intro (carousel)
  - Slide 1: Welcome
  - Slide 2: Features
  - Slide 3: Community
  - Slide 4: Start learning

- Setup Profile Screen
  - Avatar upload
  - Name, bio
  - Interests selection

- Permissions Screen
  - Camera, Notification, Storage

- Personalization Screen
  - Learning goals
  - Preferred topics
```

### 3. **SKILLS FLOW** (8-10 screens)

Mở rộng skills_screen.dart hiện tại

```
✓ Skills List Screen (category, filter, search)

- Skill Detail Screen (→ cải thiện)
  - Overview
  - Lessons
  - Reviews
  - Related skills

- Skill Lesson Screen
  - Video/content player
  - Notes
  - Progress tracking

- Skill Quiz Screen
  - Multiple choice questions
  - Timer
  - Score feedback

- Skill Certificate Screen
  - Certificate design
  - Download/share
  - LinkedIn integration

- My Learning Screen
  - In progress
  - Completed
  - Bookmarked

- Learning Analytics Screen
  - Time spent
  - Completion rate
  - Performance chart
  - Recommendations

- Review & Rating Screen
  - Leave review for skill
  - Rate difficulty
```

### 4. **COMMUNITY FLOW** (8-10 screens)

Mở rộng community_screen.dart hiện tại

```
✓ Community Feed (posts, filters)

- Post Detail Screen (→ cải thiện)
  - Comments thread
  - Replies
  - Like/share

- Create Post Screen (hiện tại cơ bản)

- User Profile Screen
  - User info
  - User's posts
  - User's skills
  - Follow/Message button

- Group Screen
  - Browse groups
  - Join/Leave
  - Group filters

- Group Detail Screen
  - Group info
  - Group members
  - Group posts
  - Group files

- Messages Screen
  - DMslist
  - Group chats

- Message Detail Screen
  - Chat interface
  - File sharing
  - Call button

- Notifications Screen
  - All notifications
  - Mark read/unread
```

### 5. **NEWS FLOW** (6-8 screens)

Mở rộng news_screen.dart hiện tại

```
✓ News List (all, hot, bookmarks)

- News Detail Screen (cải thiện)
  - Full article
  - Author info
  - Related articles
  - Comments

- News Categories Screen
  - Browse by category
  - Category filters

- Bookmarks Screen
  - Saved articles

- Article Reader Screen
  - Night mode
  - Font size adjustment
  - Read time estimate
  - Continue reading

- Search News Screen
  - Search by title/keyword
  - Recent searches
```

### 6. **FUN & GAMIFICATION** (5-7 screens)

Mở rộng fun_screen.dart

```
✓ Fun/Tips Screen (daily tips)

- Game Screen
  - Trivia/Quiz games
  - Daily challenges
  - Scoring system

- Leaderboard Screen
  - Global ranking
  - Friend ranking
  - Category-specific

- Achievements Screen
  - Badges earned
  - Locked badges
  - Progress to next badge

- Rewards/Points Screen
  - Current points
  - Redeem rewards
  - Store/Shop (virtual items)

- Challenge Detail Screen
  - Challenge rules
  - Submit entry
  - Results
```

### 7. **PROFILE FLOW** (8-10 screens)

Mở rộng profile_screen.dart

```
✓ Profile Screen (basic info)

- Edit Profile Screen
  - Edit name, bio
  - Avatar upload
  - Banner upload

- My Skills Screen
  - Skills learned
  - Certificates
  - Recommendations

- My Certificates Screen
  - List of certificates
  - Download/Share
  - Verify certificate

- Settings Screen
  - Account settings
  - Preferences

- Privacy Settings Screen
  - Public/Private profile
  - Block users
  - Data privacy

- Notifications Settings Screen
  - Email notifications
  - Push notifications
  - In-app notifications

- Blocked Users Screen
  - Manage blocked users
  - Unblock

- Account Deletion Screen
  - Confirm deletion
  - Data export
```

### 8. **ADMIN FLOW** (8-12 screens)

Mở rộng admin_screen.dart / admin_cms_screen.dart

```
✓ Admin Dashboard
  - Overview stats
  - Quick actions
  - Recent activities

✓ Admin Users Screen (list)

- Admin User Detail Screen
  - User info
  - Activity log
  - Suspend/Ban

- Admin Skills Screen (CRUD)
  - List all skills
  - Create/Edit skill
  - Publish/Draft

✓ Admin Content Screen (CMS - cải thiện)

- Admin Reports Screen
  - User reports
  - Content reports
  - Handle reports

- Admin Analytics Screen
  - User growth
  - Popular skills
  - Engagement metrics
  - Revenue (if applicable)

- Admin Settings Screen
  - App config
  - Email templates
  - API keys

- Admin Audit Log Screen
  - All admin actions
  - User activities
  - System events
```

### 9. **COPILOT & AI** (3-4 screens)

Mở rộng copilot_screen.dart

```
✓ Copilot Chat Screen (current)

- Copilot Suggestions Screen
  - Recommended skills
  - Study plan
  - Learning path

- Copilot Analysis Screen
  - User learning style
  - Recommended content
  - Performance insights
```

### 10. **PLAYGROUND** (2-3 screens)

Mở rộng playground_screen.dart

```
✓ Playground Screen (current)

- Code Editor Screen
  - Full editor
  - Run code
  - Save snippets
```

### 11. **SHARED/COMMON SCREENS** (3-5 screens)

```
- Search Screen
  - Search skills
  - Search posts
  - Search users
  - Search articles

- Global Notifications Screen
  - Push log
  - Mark read/unread

- Error Screen (generic)
  - Network error
  - Server error
  - 404, 500 pages

- Maintenance Screen
  - App under maintenance
  - Estimated time
```

---

## 🔄 State Management Architecture

### Hiện Tại

- `initState()` + `setState()` trực tiếp trong screen
- Không có state management library

### Proposed (RecommendedSolutions)

#### Option 1: GetX (Recommended - Simple & Fast)

```dart
// lib/providers/skill_provider.dart
import 'package:get/get.dart';

class SkillProvider extends GetxController {
  final _skills = <SkillModel>[].obs;
  final _loading = false.obs;
  final _error = Rxn<String>();

  List<SkillModel> get skills => _skills;
  bool get loading => _loading.value;
  String? get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    loadSkills();
  }

  Future<void> loadSkills() async {
    _loading.value = true;
    _error.value = null;
    try {
      final items = await ApiService.getSkills();
      _skills.value = items.map(SkillModel.fromJson).toList();
    } catch (e) {
      _error.value = 'Failed to load skills';
    } finally {
      _loading.value = false;
    }
  }
}

// Usage in screen
class SkillsScreen extends GetView<SkillProvider> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading) return const SkeletonLoader();
      if (controller.error != null) return ErrorOverlay(...);
      if (controller.skills.isEmpty) return EmptyStateOverlay(...);

      return ListView(
        children: controller.skills
            .map((skill) => SkillCard(skill: skill))
            .toList(),
      );
    });
  }
}
```

#### Option 2: Riverpod (More Type-safe & Modern)

```dart
// lib/providers/skill_provider.dart
import 'package:riverpod/riverpod.dart';

final skillsProvider = FutureProvider<List<SkillModel>>((ref) async {
  return await ApiService.getSkills();
});

// Usage in screen
class SkillsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skills = ref.watch(skillsProvider);

    return skills.when(
      loading: () => const SkeletonLoader(),
      error: (err, stack) => ErrorOverlay(...),
      data: (items) => items.isEmpty
          ? EmptyStateOverlay(...)
          : ListView(...),
    );
  }
}
```

#### Option 3: Bloc/Cubit (Enterprise Standard)

```dart
// lib/providers/cubits/skill_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class SkillCubit extends Cubit<SkillState> {
  SkillCubit() : super(const SkillState.initial());

  Future<void> loadSkills() async {
    emit(const SkillState.loading());
    try {
      final items = await ApiService.getSkills();
      emit(SkillState.success(items));
    } catch (e) {
      emit(SkillState.error(e.toString()));
    }
  }
}

// Usage in screen
class SkillsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SkillCubit, SkillState>(
      builder: (context, state) {
        return state.maybeWhen(
          loading: () => const SkeletonLoader(),
          error: (msg) => ErrorOverlay(...),
          success: (items) => items.isEmpty
              ? EmptyStateOverlay(...)
              : ListView(...),
          orElse: () => const SizedBox(),
        );
      },
    );
  }
}
```

---

## 🛣️ Routing Architecture

### Current

- `initialRoute: loggedIn ? '/home' : '/auth'`
- Named routes in `main.dart`

### Proposed

```dart
// lib/config/routes.dart
class AppRoutes {
  // Auth
  static const auth = '/auth';
  static const login = '/auth/login';
  static const signup = '/auth/signup';
  static const forgotPassword = '/auth/forgot-password';

  // Onboarding
  static const onboarding = '/onboarding';
  static const setupProfile = '/onboarding/setup-profile';

  // Main
  static const home = '/home';
  static const skills = '/skills';
  static const skillDetail = '/skills/:id';
  static const skillLesson = '/skills/:id/lesson/:lessonId';
  static const community = '/community';
  static const news = '/news';

  // Profile
  static const profile = '/profile';
  static const editProfile = '/profile/edit';

  // Admin
  static const admin = '/admin';
  static const adminUsers = '/admin/users';
}

// lib/main.dart
class KyNangSongApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const AuthWrapper(),
      onGenerateRoute: (settings) {
        // Named route generator
        switch (settings.name) {
          case AppRoutes.home:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case AppRoutes.skills:
            return MaterialPageRoute(builder: (_) => const SkillsScreen());
          // ... more routes
          default:
            return MaterialPageRoute(builder: (_) => const NotFoundScreen());
        }
      },
    );
  }
}

// lib/screens/shared/auth_wrapper.dart
class AuthWrapper extends StatelessWidget {
  const AuthWrapper();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }

        if (snapshot.hasData) {
          // Check if onboarding done
          final onboardingDone = /* check */;
          return onboardingDone ? const MainNav() : const OnboardingScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
```

---

## 📦 Dependency Management

### pubspec.yaml Updates

```yaml
dependencies:
  flutter:
    sdk: flutter

  # UI
  google_fonts: ^6.0.0

  # State Management (choose one)
  get: ^4.6.6
  # OR
  riverpod: ^2.0.0
  flutter_riverpod: ^2.0.0
  # OR
  flutter_bloc: ^8.1.3
  bloc: ^8.1.2

  # Navigation
  go_router: ^12.0.0 # Alternative to onGenerateRoute

  # API & Networking
  dio: ^5.3.1
  retrofit: ^4.0.1

  # Database & Storage
  firebase_core: ^2.24.0
  firebase_auth: ^4.10.0
  cloud_firestore: ^4.14.0
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Video Player
  video_player: ^2.7.2

  # Image/Video Picker
  image_picker: ^1.0.4

  # Notifications
  firebase_messaging: ^14.7.0
  flutter_local_notifications: ^16.1.0

  # Analytics
  firebase_analytics: ^10.7.0

  # Logging
  logger: ^2.1.0

  # Utils
  intl: ^0.19.0
  uuid: ^4.0.0

  # Testing
  mockito: ^5.4.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

---

## 🎨 Theme & Design System

### Create Theme File

```dart
// lib/config/theme.dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F46E5),
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.outfitTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF4F46E5),
      elevation: 0,
      // ...
    ),
    // Define all components
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F46E5),
      brightness: Brightness.dark,
    ),
    // ...
  );
}
```

---

## 🧪 Testing Strategy

### Unit Tests

```dart
// test/providers/skill_provider_test.dart
void main() {
  test('loadSkills should fetch and parse skills', () async {
    final provider = SkillProvider();
    await provider.loadSkills();
    expect(provider.skills.isNotEmpty, true);
  });
}
```

### Widget Tests

```dart
// test/screens/skills_screen_test.dart
void main() {
  testWidgets('SkillsScreen shows loading', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(SkeletonLoader), findsOneWidget);
  });
}
```

---

## 📊 Total Screen Estimate

| Flow       | Screens   | Status              |
| ---------- | --------- | ------------------- |
| Auth       | 5-6       | To do               |
| Onboarding | 4-5       | To do               |
| Home       | 2         | ✓ Existing          |
| Skills     | 8-10      | ✓ Partial - Expand  |
| Community  | 8-10      | ✓ Partial - Expand  |
| News       | 6-8       | ✓ Partial - Expand  |
| Fun        | 5-7       | ✓ Partial - Expand  |
| Profile    | 8-10      | ✓ Partial - Expand  |
| Admin      | 8-12      | ✓ Existing - Expand |
| Copilot    | 3-4       | ✓ Existing          |
| Playground | 2-3       | ✓ Existing          |
| Shared     | 3-5       | Minimal             |
| **TOTAL**  | **75-95** | -                   |

---

## 🚀 Implementation Roadmap

### Phase 1 (Weeks 1-2): Foundation

- [x] Create state widgets
- [ ] Setup routing system
- [ ] Setup state management (GetX/Riverpod/Bloc)
- [ ] Create models layer
- [ ] Create constants/config

### Phase 2 (Weeks 3-4): Auth & Onboarding

- [ ] Refactor auth flow (login, signup, password reset)
- [ ] Create onboarding flow
- [ ] Setup auth guard

### Phase 3 (Weeks 5-6): Core Features Expansion

- [ ] Expand skills flow (lesson, quiz, analytics)
- [ ] Expand community (groups, messaging, profiles)
- [ ] Expand news (categories, reader)
- [ ] Expand fun (games, leaderboard, achievements)

### Phase 4 (Weeks 7-8): Profile & Admin

- [ ] Expand profile (settings, privacy, certificates)
- [ ] Expand admin (analytics, reports)
- [ ] Expand copilot (suggestions, analysis)

### Phase 5+ (Weeks 9+): Polish & Testing

- [ ] Design system finalization
- [ ] E2E testing
- [ ] Performance optimization
- [ ] Analytics integration

---

## 💡 Key Benefits

✅ Clear separation of concern  
✅ Scalable & maintainable structure  
✅ Professional UI state management  
✅ Consistent across all screens  
✅ Enhanced user experience  
✅ Easy to onboard new developers  
✅ Better error handling  
✅ Professional-grade application  
✅ Ready for production & scaling  
✅ Future-proof architecture
