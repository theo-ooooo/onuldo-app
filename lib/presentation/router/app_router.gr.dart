// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [CreateRecordScreen]
class CreateRecordRoute extends PageRouteInfo<CreateRecordRouteArgs> {
  CreateRecordRoute({
    Key? key,
    int? timerId,
    int? hobbyId,
    String? hobbyName,
    int? durationSeconds,
    List<PageRouteInfo>? children,
  }) : super(
         CreateRecordRoute.name,
         args: CreateRecordRouteArgs(
           key: key,
           timerId: timerId,
           hobbyId: hobbyId,
           hobbyName: hobbyName,
           durationSeconds: durationSeconds,
         ),
         initialChildren: children,
       );

  static const String name = 'CreateRecordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreateRecordRouteArgs>(
        orElse: () => const CreateRecordRouteArgs(),
      );
      return CreateRecordScreen(
        key: args.key,
        timerId: args.timerId,
        hobbyId: args.hobbyId,
        hobbyName: args.hobbyName,
        durationSeconds: args.durationSeconds,
      );
    },
  );
}

class CreateRecordRouteArgs {
  const CreateRecordRouteArgs({
    this.key,
    this.timerId,
    this.hobbyId,
    this.hobbyName,
    this.durationSeconds,
  });

  final Key? key;

  final int? timerId;

  final int? hobbyId;

  final String? hobbyName;

  final int? durationSeconds;

  @override
  String toString() {
    return 'CreateRecordRouteArgs{key: $key, timerId: $timerId, hobbyId: $hobbyId, hobbyName: $hobbyName, durationSeconds: $durationSeconds}';
  }
}

/// generated route for
/// [FeedDetailScreen]
class FeedDetailRoute extends PageRouteInfo<FeedDetailRouteArgs> {
  FeedDetailRoute({
    Key? key,
    required int recordId,
    List<PageRouteInfo>? children,
  }) : super(
         FeedDetailRoute.name,
         args: FeedDetailRouteArgs(key: key, recordId: recordId),
         initialChildren: children,
       );

  static const String name = 'FeedDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FeedDetailRouteArgs>();
      return FeedDetailScreen(key: args.key, recordId: args.recordId);
    },
  );
}

class FeedDetailRouteArgs {
  const FeedDetailRouteArgs({this.key, required this.recordId});

  final Key? key;

  final int recordId;

  @override
  String toString() {
    return 'FeedDetailRouteArgs{key: $key, recordId: $recordId}';
  }
}

/// generated route for
/// [FeedScreen]
class FeedRoute extends PageRouteInfo<void> {
  const FeedRoute({List<PageRouteInfo>? children})
    : super(FeedRoute.name, initialChildren: children);

  static const String name = 'FeedRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FeedScreen();
    },
  );
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeScreen();
    },
  );
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginScreen();
    },
  );
}

/// generated route for
/// [NotificationScreen]
class NotificationRoute extends PageRouteInfo<void> {
  const NotificationRoute({List<PageRouteInfo>? children})
    : super(NotificationRoute.name, initialChildren: children);

  static const String name = 'NotificationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NotificationScreen();
    },
  );
}

/// generated route for
/// [PhotoViewerScreen]
class PhotoViewerRoute extends PageRouteInfo<PhotoViewerRouteArgs> {
  PhotoViewerRoute({
    Key? key,
    required List<String> imageUrls,
    int initialIndex = 0,
    List<PageRouteInfo>? children,
  }) : super(
         PhotoViewerRoute.name,
         args: PhotoViewerRouteArgs(
           key: key,
           imageUrls: imageUrls,
           initialIndex: initialIndex,
         ),
         initialChildren: children,
       );

  static const String name = 'PhotoViewerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PhotoViewerRouteArgs>();
      return PhotoViewerScreen(
        key: args.key,
        imageUrls: args.imageUrls,
        initialIndex: args.initialIndex,
      );
    },
  );
}

class PhotoViewerRouteArgs {
  const PhotoViewerRouteArgs({
    this.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  final Key? key;

  final List<String> imageUrls;

  final int initialIndex;

  @override
  String toString() {
    return 'PhotoViewerRouteArgs{key: $key, imageUrls: $imageUrls, initialIndex: $initialIndex}';
  }
}

/// generated route for
/// [ProfileScreen]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileScreen();
    },
  );
}

/// generated route for
/// [SignupScreen]
class SignupRoute extends PageRouteInfo<void> {
  const SignupRoute({List<PageRouteInfo>? children})
    : super(SignupRoute.name, initialChildren: children);

  static const String name = 'SignupRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignupScreen();
    },
  );
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}

/// generated route for
/// [StatisticsScreen]
class StatisticsRoute extends PageRouteInfo<void> {
  const StatisticsRoute({List<PageRouteInfo>? children})
    : super(StatisticsRoute.name, initialChildren: children);

  static const String name = 'StatisticsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const StatisticsScreen();
    },
  );
}

/// generated route for
/// [TimerScreen]
class TimerRoute extends PageRouteInfo<void> {
  const TimerRoute({List<PageRouteInfo>? children})
    : super(TimerRoute.name, initialChildren: children);

  static const String name = 'TimerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TimerScreen();
    },
  );
}

/// generated route for
/// [UserProfileScreen]
class UserProfileRoute extends PageRouteInfo<UserProfileRouteArgs> {
  UserProfileRoute({
    Key? key,
    required int userId,
    List<PageRouteInfo>? children,
  }) : super(
         UserProfileRoute.name,
         args: UserProfileRouteArgs(key: key, userId: userId),
         initialChildren: children,
       );

  static const String name = 'UserProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserProfileRouteArgs>();
      return UserProfileScreen(key: args.key, userId: args.userId);
    },
  );
}

class UserProfileRouteArgs {
  const UserProfileRouteArgs({this.key, required this.userId});

  final Key? key;

  final int userId;

  @override
  String toString() {
    return 'UserProfileRouteArgs{key: $key, userId: $userId}';
  }
}

/// generated route for
/// [UserSearchScreen]
class UserSearchRoute extends PageRouteInfo<void> {
  const UserSearchRoute({List<PageRouteInfo>? children})
    : super(UserSearchRoute.name, initialChildren: children);

  static const String name = 'UserSearchRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UserSearchScreen();
    },
  );
}
