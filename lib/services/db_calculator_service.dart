import 'dart:math';

/// dB Calculator Service
/// Handles conversions between amplitude ratios and decibels
class DbCalculatorService {
  /// Calculates dB from amplitude ratio
  /// 
  /// Parameters:
  /// - [a1]: Reference amplitude (> 0)
  /// - [a2]: Measured amplitude (> 0)
  /// - [isPowerMode]: true for power/intensity (10*log10), false for amplitude/voltage (20*log10)
  /// 
  /// Returns a map containing:
  /// - 'dB': The decibel change
  /// - 'ratio': The ratio A2/A1 or P2/P1
  /// - 'percentChange': Percent change (R - 1) * 100
  /// - 'error': Error message if validation fails (null if valid)
  static Map<String, dynamic> calculateDbFromRatio({
    required double a1,
    required double a2,
    required bool isPowerMode,
  }) {
    // Validate inputs
    if (a1 <= 0) {
      return {
        'dB': null,
        'ratio': null,
        'percentChange': null,
        'error': 'A1 must be greater than 0',
      };
    }

    if (a2 <= 0) {
      return {
        'dB': null,
        'ratio': null,
        'percentChange': null,
        'error': 'A2 must be greater than 0',
      };
    }

    // Calculate ratio
    final double ratio = a2 / a1;

    // Calculate dB
    final double db;
    if (isPowerMode) {
      // Power/Intensity mode: dB = 10 * log10(P2 / P1)
      db = 10 * log10(ratio);
    } else {
      // Amplitude/Voltage mode: dB = 20 * log10(A2 / A1)
      db = 20 * log10(ratio);
    }

    // Calculate percent change
    final double percentChange = (ratio - 1) * 100;

    return {
      'dB': db,
      'ratio': ratio,
      'percentChange': percentChange,
      'error': null,
    };
  }

  /// Calculates A2 from A1 and dB change
  /// 
  /// Parameters:
  /// - [a1]: Reference amplitude (> 0)
  /// - [db]: Decibel change (can be negative or positive)
  /// - [isPowerMode]: true for power/intensity (10*log10), false for amplitude/voltage (20*log10)
  /// 
  /// Returns a map containing:
  /// - 'a2': The calculated amplitude
  /// - 'ratio': The ratio A2/A1 or P2/P1
  /// - 'percentChange': Percent change (R - 1) * 100
  /// - 'error': Error message if validation fails (null if valid)
  static Map<String, dynamic> calculateRatioFromDb({
    required double a1,
    required double db,
    required bool isPowerMode,
  }) {
    // Validate inputs
    if (a1 <= 0) {
      return {
        'a2': null,
        'ratio': null,
        'percentChange': null,
        'error': 'A1 must be greater than 0',
      };
    }

    // Calculate ratio from dB
    final double ratio;
    if (isPowerMode) {
      // Power/Intensity mode: R = 10^(dB / 10)
      ratio = pow(10, db / 10).toDouble();
    } else {
      // Amplitude/Voltage mode: R = 10^(dB / 20)
      ratio = pow(10, db / 20).toDouble();
    }

    // Calculate A2
    final double a2 = a1 * ratio;

    // Calculate percent change
    final double percentChange = (ratio - 1) * 100;

    return {
      'a2': a2,
      'ratio': ratio,
      'percentChange': percentChange,
      'error': null,
    };
  }

  /// Helper function to calculate log base 10
  static double log10(double x) {
    return log(x) / ln10;
  }

  /// Validates amplitude ratio to dB inputs
  static String? validateRatioToDbInputs({
    required double a1,
    required double a2,
  }) {
    if (a1 <= 0) {
      return 'A1 must be greater than 0';
    }
    if (a2 <= 0) {
      return 'A2 must be greater than 0';
    }
    return null;
  }

  /// Validates dB to ratio inputs
  static String? validateDbToRatioInputs({
    required double a1,
  }) {
    if (a1 <= 0) {
      return 'A1 must be greater than 0';
    }
    return null;
  }
}
