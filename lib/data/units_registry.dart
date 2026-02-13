/// Comprehensive Unit Registry for NDT Applications
/// This registry contains all unit definitions and conversion factors
/// organized by category for easy maintenance and expansion.

enum UnitCategory {
  length,
  pressure,
  velocity,
  frequency,
  time,
  area,
  volume,
  force,
  torque,
  energy,
  power,
  density,
  temperature,
}

/// Extension to provide human-readable labels for categories
extension UnitCategoryExtension on UnitCategory {
  String get label {
    switch (this) {
      case UnitCategory.length:
        return 'Length / Thickness';
      case UnitCategory.pressure:
        return 'Pressure';
      case UnitCategory.velocity:
        return 'Velocity';
      case UnitCategory.frequency:
        return 'Frequency';
      case UnitCategory.time:
        return 'Time';
      case UnitCategory.area:
        return 'Area';
      case UnitCategory.volume:
        return 'Volume';
      case UnitCategory.force:
        return 'Force';
      case UnitCategory.torque:
        return 'Torque';
      case UnitCategory.energy:
        return 'Energy';
      case UnitCategory.power:
        return 'Power';
      case UnitCategory.density:
        return 'Density';
      case UnitCategory.temperature:
        return 'Temperature';
    }
  }

  String get icon {
    switch (this) {
      case UnitCategory.length:
        return '📏';
      case UnitCategory.pressure:
        return '🔧';
      case UnitCategory.velocity:
        return '⚡';
      case UnitCategory.frequency:
        return '📶';
      case UnitCategory.time:
        return '⏱️';
      case UnitCategory.area:
        return '⬜';
      case UnitCategory.volume:
        return '📦';
      case UnitCategory.force:
        return '💪';
      case UnitCategory.torque:
        return '🔄';
      case UnitCategory.energy:
        return '⚡';
      case UnitCategory.power:
        return '💡';
      case UnitCategory.density:
        return '⚖️';
      case UnitCategory.temperature:
        return '🌡️';
    }
  }
}

/// Definition of a single unit within a category
class UnitDef {
  final String id;
  final String label;
  final String? symbol; // Optional display symbol
  final double? factorToBase; // Multiply by this to convert to base unit
  final bool isAffine; // true for temperature (non-linear conversion)

  const UnitDef({
    required this.id,
    required this.label,
    this.symbol,
    this.factorToBase,
    this.isAffine = false,
  });

  String get displayLabel => symbol ?? label;
}

/// Definition of a unit category with all its units
class UnitCategoryDef {
  final UnitCategory category;
  final String baseUnitId;
  final List<UnitDef> units;
  final List<CommonPair>? commonPairs;

  const UnitCategoryDef({
    required this.category,
    required this.baseUnitId,
    required this.units,
    this.commonPairs,
  });

  UnitDef? getUnitById(String id) {
    try {
      return units.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Common unit pairs for quick access
class CommonPair {
  final String fromUnitId;
  final String toUnitId;
  final String label;

  const CommonPair({
    required this.fromUnitId,
    required this.toUnitId,
    required this.label,
  });
}

/// The complete units registry
class UnitsRegistry {
  static const List<UnitCategoryDef> categories = [
    // LENGTH / THICKNESS (base: meters)
    UnitCategoryDef(
      category: UnitCategory.length,
      baseUnitId: 'm',
      units: [
        UnitDef(id: 'mm', label: 'Millimeters', symbol: 'mm', factorToBase: 0.001),
        UnitDef(id: 'cm', label: 'Centimeters', symbol: 'cm', factorToBase: 0.01),
        UnitDef(id: 'm', label: 'Meters', symbol: 'm', factorToBase: 1.0),
        UnitDef(id: 'in', label: 'Inches', symbol: 'in', factorToBase: 0.0254),
        UnitDef(id: 'ft', label: 'Feet', symbol: 'ft', factorToBase: 0.3048),
        UnitDef(id: 'yd', label: 'Yards', symbol: 'yd', factorToBase: 0.9144),
      ],
      commonPairs: [
        CommonPair(fromUnitId: 'in', toUnitId: 'mm', label: 'in → mm'),
        CommonPair(fromUnitId: 'mm', toUnitId: 'in', label: 'mm → in'),
        CommonPair(fromUnitId: 'ft', toUnitId: 'm', label: 'ft → m'),
      ],
    ),

    // PRESSURE (base: Pascals)
    UnitCategoryDef(
      category: UnitCategory.pressure,
      baseUnitId: 'Pa',
      units: [
        UnitDef(id: 'Pa', label: 'Pascals', symbol: 'Pa', factorToBase: 1.0),
        UnitDef(id: 'kPa', label: 'Kilopascals', symbol: 'kPa', factorToBase: 1000.0),
        UnitDef(id: 'MPa', label: 'Megapascals', symbol: 'MPa', factorToBase: 1000000.0),
        UnitDef(id: 'bar', label: 'Bar', symbol: 'bar', factorToBase: 100000.0),
        UnitDef(id: 'psi', label: 'PSI', symbol: 'psi', factorToBase: 6894.757),
        UnitDef(id: 'ksi', label: 'KSI', symbol: 'ksi', factorToBase: 6894757.0),
      ],
      commonPairs: [
        CommonPair(fromUnitId: 'psi', toUnitId: 'kPa', label: 'psi → kPa'),
        CommonPair(fromUnitId: 'kPa', toUnitId: 'psi', label: 'kPa → psi'),
        CommonPair(fromUnitId: 'bar', toUnitId: 'psi', label: 'bar → psi'),
      ],
    ),

    // VELOCITY (base: m/s)
    UnitCategoryDef(
      category: UnitCategory.velocity,
      baseUnitId: 'm/s',
      units: [
        UnitDef(id: 'm/s', label: 'Meters/second', symbol: 'm/s', factorToBase: 1.0),
        UnitDef(id: 'mm/µs', label: 'Millimeters/microsecond', symbol: 'mm/µs', factorToBase: 1000.0),
        UnitDef(id: 'in/µs', label: 'Inches/microsecond', symbol: 'in/µs', factorToBase: 25400.0),
        UnitDef(id: 'ft/s', label: 'Feet/second', symbol: 'ft/s', factorToBase: 0.3048),
      ],
      commonPairs: [
        CommonPair(fromUnitId: 'in/µs', toUnitId: 'm/s', label: 'in/µs → m/s'),
        CommonPair(fromUnitId: 'mm/µs', toUnitId: 'in/µs', label: 'mm/µs → in/µs'),
        CommonPair(fromUnitId: 'in/µs', toUnitId: 'mm/µs', label: 'in/µs → mm/µs'),
      ],
    ),

    // FREQUENCY (base: Hz)
    UnitCategoryDef(
      category: UnitCategory.frequency,
      baseUnitId: 'Hz',
      units: [
        UnitDef(id: 'Hz', label: 'Hertz', symbol: 'Hz', factorToBase: 1.0),
        UnitDef(id: 'kHz', label: 'Kilohertz', symbol: 'kHz', factorToBase: 1000.0),
        UnitDef(id: 'MHz', label: 'Megahertz', symbol: 'MHz', factorToBase: 1000000.0),
      ],
      commonPairs: [
        CommonPair(fromUnitId: 'MHz', toUnitId: 'kHz', label: 'MHz → kHz'),
        CommonPair(fromUnitId: 'kHz', toUnitId: 'MHz', label: 'kHz → MHz'),
      ],
    ),

    // TIME (base: seconds)
    UnitCategoryDef(
      category: UnitCategory.time,
      baseUnitId: 's',
      units: [
        UnitDef(id: 's', label: 'Seconds', symbol: 's', factorToBase: 1.0),
        UnitDef(id: 'ms', label: 'Milliseconds', symbol: 'ms', factorToBase: 0.001),
        UnitDef(id: 'µs', label: 'Microseconds', symbol: 'µs', factorToBase: 0.000001),
        UnitDef(id: 'min', label: 'Minutes', symbol: 'min', factorToBase: 60.0),
        UnitDef(id: 'hr', label: 'Hours', symbol: 'hr', factorToBase: 3600.0),
      ],
      commonPairs: [
        CommonPair(fromUnitId: 'µs', toUnitId: 'ms', label: 'µs → ms'),
        CommonPair(fromUnitId: 'hr', toUnitId: 'min', label: 'hr → min'),
      ],
    ),

    // AREA (base: m²)
    UnitCategoryDef(
      category: UnitCategory.area,
      baseUnitId: 'm²',
      units: [
        UnitDef(id: 'mm²', label: 'Square millimeters', symbol: 'mm²', factorToBase: 0.000001),
        UnitDef(id: 'cm²', label: 'Square centimeters', symbol: 'cm²', factorToBase: 0.0001),
        UnitDef(id: 'm²', label: 'Square meters', symbol: 'm²', factorToBase: 1.0),
        UnitDef(id: 'in²', label: 'Square inches', symbol: 'in²', factorToBase: 0.00064516),
        UnitDef(id: 'ft²', label: 'Square feet', symbol: 'ft²', factorToBase: 0.092903),
      ],
      commonPairs: [
        CommonPair(fromUnitId: 'in²', toUnitId: 'cm²', label: 'in² → cm²'),
        CommonPair(fromUnitId: 'ft²', toUnitId: 'm²', label: 'ft² → m²'),
      ],
    ),

    // VOLUME (base: m³)
    UnitCategoryDef(
      category: UnitCategory.volume,
      baseUnitId: 'm³',
      units: [
        UnitDef(id: 'mL', label: 'Milliliters', symbol: 'mL', factorToBase: 0.000001),
        UnitDef(id: 'L', label: 'Liters', symbol: 'L', factorToBase: 0.001),
        UnitDef(id: 'cm³', label: 'Cubic centimeters', symbol: 'cm³', factorToBase: 0.000001),
        UnitDef(id: 'm³', label: 'Cubic meters', symbol: 'm³', factorToBase: 1.0),
        UnitDef(id: 'in³', label: 'Cubic inches', symbol: 'in³', factorToBase: 0.000016387),
        UnitDef(id: 'ft³', label: 'Cubic feet', symbol: 'ft³', factorToBase: 0.028317),
        UnitDef(id: 'gal', label: 'Gallons (US)', symbol: 'gal', factorToBase: 0.003785),
      ],
      commonPairs: [
        CommonPair(fromUnitId: 'gal', toUnitId: 'L', label: 'gal → L'),
        CommonPair(fromUnitId: 'L', toUnitId: 'gal', label: 'L → gal'),
      ],
    ),

    // FORCE (base: Newtons)
    UnitCategoryDef(
      category: UnitCategory.force,
      baseUnitId: 'N',
      units: [
        UnitDef(id: 'N', label: 'Newtons', symbol: 'N', factorToBase: 1.0),
        UnitDef(id: 'kN', label: 'Kilonewtons', symbol: 'kN', factorToBase: 1000.0),
        UnitDef(id: 'lbf', label: 'Pounds-force', symbol: 'lbf', factorToBase: 4.448222),
      ],
      commonPairs: [
        CommonPair(fromUnitId: 'lbf', toUnitId: 'N', label: 'lbf → N'),
        CommonPair(fromUnitId: 'N', toUnitId: 'lbf', label: 'N → lbf'),
      ],
    ),

    // TORQUE (base: N·m)
    UnitCategoryDef(
      category: UnitCategory.torque,
      baseUnitId: 'N·m',
      units: [
        UnitDef(id: 'N·m', label: 'Newton-meters', symbol: 'N·m', factorToBase: 1.0),
        UnitDef(id: 'ft·lbf', label: 'Foot-pounds', symbol: 'ft·lbf', factorToBase: 1.355818),
        UnitDef(id: 'in·lbf', label: 'Inch-pounds', symbol: 'in·lbf', factorToBase: 0.112985),
      ],
      commonPairs: [
        CommonPair(fromUnitId: 'ft·lbf', toUnitId: 'N·m', label: 'ft·lbf → N·m'),
        CommonPair(fromUnitId: 'N·m', toUnitId: 'ft·lbf', label: 'N·m → ft·lbf'),
      ],
    ),

    // ENERGY (base: Joules)
    UnitCategoryDef(
      category: UnitCategory.energy,
      baseUnitId: 'J',
      units: [
        UnitDef(id: 'J', label: 'Joules', symbol: 'J', factorToBase: 1.0),
        UnitDef(id: 'kJ', label: 'Kilojoules', symbol: 'kJ', factorToBase: 1000.0),
        UnitDef(id: 'cal', label: 'Calories', symbol: 'cal', factorToBase: 4.184),
        UnitDef(id: 'BTU', label: 'BTU', symbol: 'BTU', factorToBase: 1055.06),
      ],
      commonPairs: [
        CommonPair(fromUnitId: 'BTU', toUnitId: 'kJ', label: 'BTU → kJ'),
        CommonPair(fromUnitId: 'kJ', toUnitId: 'BTU', label: 'kJ → BTU'),
      ],
    ),

    // POWER (base: Watts)
    UnitCategoryDef(
      category: UnitCategory.power,
      baseUnitId: 'W',
      units: [
        UnitDef(id: 'W', label: 'Watts', symbol: 'W', factorToBase: 1.0),
        UnitDef(id: 'kW', label: 'Kilowatts', symbol: 'kW', factorToBase: 1000.0),
        UnitDef(id: 'hp', label: 'Horsepower', symbol: 'hp', factorToBase: 745.7),
      ],
      commonPairs: [
        CommonPair(fromUnitId: 'hp', toUnitId: 'kW', label: 'hp → kW'),
        CommonPair(fromUnitId: 'kW', toUnitId: 'hp', label: 'kW → hp'),
      ],
    ),

    // DENSITY (base: kg/m³)
    UnitCategoryDef(
      category: UnitCategory.density,
      baseUnitId: 'kg/m³',
      units: [
        UnitDef(id: 'kg/m³', label: 'Kilograms/cubic meter', symbol: 'kg/m³', factorToBase: 1.0),
        UnitDef(id: 'g/cm³', label: 'Grams/cubic centimeter', symbol: 'g/cm³', factorToBase: 1000.0),
        UnitDef(id: 'lb/in³', label: 'Pounds/cubic inch', symbol: 'lb/in³', factorToBase: 27679.9),
        UnitDef(id: 'lb/ft³', label: 'Pounds/cubic foot', symbol: 'lb/ft³', factorToBase: 16.0185),
      ],
      commonPairs: [
        CommonPair(fromUnitId: 'g/cm³', toUnitId: 'lb/in³', label: 'g/cm³ → lb/in³'),
        CommonPair(fromUnitId: 'lb/ft³', toUnitId: 'kg/m³', label: 'lb/ft³ → kg/m³'),
      ],
    ),

    // TEMPERATURE (base: Celsius) - Special handling for affine conversions
    UnitCategoryDef(
      category: UnitCategory.temperature,
      baseUnitId: '°C',
      units: [
        UnitDef(id: '°C', label: 'Celsius', symbol: '°C', isAffine: true),
        UnitDef(id: '°F', label: 'Fahrenheit', symbol: '°F', isAffine: true),
        UnitDef(id: 'K', label: 'Kelvin', symbol: 'K', isAffine: true),
        UnitDef(id: '°R', label: 'Rankine', symbol: '°R', isAffine: true),
      ],
      commonPairs: [
        CommonPair(fromUnitId: '°F', toUnitId: '°C', label: '°F → °C'),
        CommonPair(fromUnitId: '°C', toUnitId: '°F', label: '°C → °F'),
        CommonPair(fromUnitId: 'K', toUnitId: '°C', label: 'K → °C'),
      ],
    ),
  ];

  /// Get category definition by enum
  static UnitCategoryDef? getCategoryDef(UnitCategory category) {
    try {
      return categories.firstWhere((c) => c.category == category);
    } catch (e) {
      return null;
    }
  }

  /// Get all category labels for dropdown
  static List<String> get categoryLabels {
    return categories.map((c) => c.category.label).toList();
  }
}
