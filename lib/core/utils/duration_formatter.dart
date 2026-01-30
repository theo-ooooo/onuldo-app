class DurationFormatter {
  DurationFormatter._();

  /// Format duration as HH:MM:SS
  static String format(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(seconds)}';
  }

  /// Format duration as MM:SS (for shorter durations)
  static String formatShort(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);

    return '${_twoDigits(minutes)}:${_twoDigits(seconds)}';
  }

  /// Format duration as human readable string (e.g., "2시간 30분")
  static String formatHumanReadable(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '$hours시간 $minutes분';
    } else if (hours > 0) {
      return '$hours시간';
    } else if (minutes > 0) {
      return '$minutes분';
    } else {
      return '${duration.inSeconds}초';
    }
  }

  /// Format seconds as HH:MM:SS
  static String formatSeconds(int totalSeconds) {
    return format(Duration(seconds: totalSeconds));
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
