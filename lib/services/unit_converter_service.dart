import '../data/units_registry.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for converting between units and managing conversion state
class UnitConverterService {
  /// Convert a value from one unit to another
  static double? convert({
    required double value,
    required UnitCategory category,
    required String fromUnitId,
    required String toUnitId,
  }) {
    try {
      final categoryDef = UnitsRegistry.getCategoryDef(category);
      if (categoryDef == null) return null;

      final fromUnit = categoryDef.getUnitById(fromUnitId);
      final toUnit = categoryDef.getUnitById(toUnitId);

      if (fromUnit == null || toUnit == null) return null;

      // Same unit, no conversion needed
      if (fromUnitId == toUnitId) return value;

      // Handle temperature conversions separately (affine)
      if (category == UnitCategory.temperature) {
        return _convertTemperature(value, fromUnitId, toUnitId);
      }

      // Linear conversions: convert to base, then to target
      if (fromUnit.factorToBase == null || toUnit.factorToBase == null) {
        return null;
      }

      final baseValue = value * fromUnit.factorToBase!;
      final result = baseValue / toUnit.factorToBase!;

      return result;
    } catch (e) {
      return null;
    }
  }

  /// Handle temperature conversions with explicit formulas
  static double _convertTemperature(double value, String fromUnit, String toUnit) {
    // First convert to Celsius (base)
    double celsius;
    
    switch (fromUnit) {
      case '°C':
        celsius = value;
        break;
      case '°F':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'K':
        celsius = value - 273.15;
        break;
      case '°R':
        celsius = (value - 491.67) * 5 / 9;
        break;
      default:
        throw Exception('Unknown temperature unit: $fromUnit');
    }

    // Then convert from Celsius to target
    switch (toUnit) {
      case '°C':
        return celsius;
      case '°F':
        return celsius * 9 / 5 + 32;
      case 'K':
        return celsius + 273.15;
      case '°R':
        return (celsius + 273.15) * 9 / 5;
      default:
        throw Exception('Unknown temperature unit: $toUnit');
    }
  }

  /// Format a number for display with smart precision
  static String formatValue(double value, {int? decimals}) {
    if (value.isNaN || value.isInfinite) {
      return 'Error';
    }

    // Use specified decimals or smart formatting
    if (decimals != null) {
      return value.toStringAsFixed(decimals);
    }

    // Smart formatting
    final absValue = value.abs();

    if (absValue == 0) {
      return '0';
    }

    // Very large or very small numbers - use scientific notation
    if (absValue >= 1e6 || (absValue < 1e-3 && absValue > 0)) {
      return value.toStringAsExponential(3);
    }

    // Regular numbers - use appropriate decimal places
    if (absValue >= 100) {
      return value.toStringAsFixed(2);
    } else if (absValue >= 1) {
      return value.toStringAsFixed(3);
    } else {
      return value.toStringAsFixed(4);
    }
  }

  /// Save last used category and units to preferences
  static Future<void> saveLastUsed({
    required UnitCategory category,
    required String fromUnitId,
    required String toUnitId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_category', category.toString());
      await prefs.setString('last_from_unit_${category.toString()}', fromUnitId);
      await prefs.setString('last_to_unit_${category.toString()}', toUnitId);
    } catch (e) {
      // Fail silently if preferences not available
    }
  }

  /// Load last used settings
  static Future<Map<String, String>?> loadLastUsed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoryStr = prefs.getString('last_category');
      if (categoryStr == null) return null;

      final fromUnit = prefs.getString('last_from_unit_$categoryStr');
      final toUnit = prefs.getString('last_to_unit_$categoryStr');

      if (fromUnit == null || toUnit == null) return null;

      return {
        'category': categoryStr,
        'fromUnit': fromUnit,
        'toUnit': toUnit,
      };
    } catch (e) {
      return null;
    }
  }

  /// Save/Load favorites
  static Future<void> saveFavorite({
    required UnitCategory category,
    required String fromUnitId,
    required String toUnitId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList('unit_favorites') ?? [];
      final favoriteKey = '${category.toString()}|$fromUnitId|$toUnitId';
      
      if (!favorites.contains(favoriteKey)) {
        favorites.add(favoriteKey);
        await prefs.setStringList('unit_favorites', favorites);
      }
    } catch (e) {
      // Fail silently
    }
  }

  static Future<void> removeFavorite({
    required UnitCategory category,
    required String fromUnitId,
    required String toUnitId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList('unit_favorites') ?? [];
      final favoriteKey = '${category.toString()}|$fromUnitId|$toUnitId';
      
      favorites.remove(favoriteKey);
      await prefs.setStringList('unit_favorites', favorites);
    } catch (e) {
      // Fail silently
    }
  }

  static Future<List<Map<String, String>>> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList('unit_favorites') ?? [];
      
      return favorites.map((fav) {
        final parts = fav.split('|');
        if (parts.length != 3) return null;
        return {
          'category': parts[0],
          'fromUnit': parts[1],
          'toUnit': parts[2],
        };
      }).whereType<Map<String, String>>().toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> isFavorite({
    required UnitCategory category,
    required String fromUnitId,
    required String toUnitId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList('unit_favorites') ?? [];
      final favoriteKey = '${category.toString()}|$fromUnitId|$toUnitId';
      return favorites.contains(favoriteKey);
    } catch (e) {
      return false;
    }
  }

  /// Validate numeric input
  static bool isValidNumber(String input) {
    if (input.isEmpty) return false;
    final number = double.tryParse(input);
    return number != null && number.isFinite;
  }

  /// Parse input allowing for various formats
  static double? parseInput(String input) {
    if (input.isEmpty) return null;
    
    // Remove common non-numeric characters (except decimal point, minus, and e for scientific)
    final cleaned = input.trim();
    
    return double.tryParse(cleaned);
  }
}
