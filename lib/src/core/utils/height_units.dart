class HeightUnits {
  HeightUnits._();

  static const cmPerInch = 2.54;

  /// 4 ft 0 in through 8 ft 0 in.
  static const minTotalInches = 48;
  static const maxTotalInches = 96;

  static int totalInchesFromCm(double cm) =>
      (cm / cmPerInch).round().clamp(minTotalInches, maxTotalInches);

  static double cmFromTotalInches(int totalInches) => totalInches * cmPerInch;

  static (int feet, int inches) splitFeetInches(int totalInches) {
    final feet = totalInches ~/ 12;
    final inch = totalInches % 12;
    return (feet, inch);
  }

  static String inchWord(int inches) => inches == 1 ? 'inch' : 'inches';

  /// e.g. "6 ft 1 inch"
  static String formatFeetInches(int totalInches) {
    final (feet, inch) = splitFeetInches(totalInches);
    return '$feet ft $inch ${inchWord(inch)}';
  }

  /// Compact label for ruler ticks, e.g. "6'1\""
  static String formatFeetInchesShort(int totalInches) {
    final (feet, inch) = splitFeetInches(totalInches);
    return "$feet'$inch\"";
  }

  static String formatCm(double cm) => '${cm.round()} cm';

  static String formatDisplay(double cm) {
    final inches = totalInchesFromCm(cm);
    return '${formatCm(cm)} · ${formatFeetInches(inches)}';
  }
}
