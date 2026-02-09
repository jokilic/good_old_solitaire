String formatElapsedTime(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;

  final minutesText = minutes.toString().padLeft(2, '0');
  final secondsText = seconds.toString().padLeft(2, '0');

  return '$minutesText:$secondsText';
}
