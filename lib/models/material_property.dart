import 'dart:math' as math;

class MaterialProperty {
  final String name;
  final double? longitudinalVelocity; // m/s
  final double? shearVelocity; // m/s
  final double? density; // kg/m³
  final double? youngsModulus; // GPa
  final double? shearModulus; // GPa
  final double? poissonRatio; // dimensionless
  final String? description;

  const MaterialProperty({
    required this.name,
    this.longitudinalVelocity,
    this.shearVelocity,
    this.density,
    this.youngsModulus,
    this.shearModulus,
    this.poissonRatio,
    this.description,
  });

  // Check if material supports shear waves
  bool get supportsShear => shearVelocity != null && shearModulus != null;

  // Check if we can derive velocities
  bool get canDeriveVelocities =>
      youngsModulus != null &&
      density != null &&
      poissonRatio != null;

  // Derive longitudinal velocity from modulus and density
  // VL ≈ sqrt( (E(1-ν)) / (ρ(1+ν)(1-2ν)) )
  double? get derivedLongitudinalVelocity {
    if (!canDeriveVelocities) return null;
    final E = youngsModulus! * 1e9; // Convert GPa to Pa
    final rho = density!;
    final nu = poissonRatio!;
    
    final numerator = E * (1 - nu);
    final denominator = rho * (1 + nu) * (1 - 2 * nu);
    
    if (denominator <= 0) return null;
    
    return math.sqrt(numerator / denominator);
  }

  // Derive shear velocity from shear modulus and density
  // VS ≈ sqrt( G / ρ )
  double? get derivedShearVelocity {
    if (shearModulus == null || density == null) return null;
    final G = shearModulus! * 1e9; // Convert GPa to Pa
    final rho = density!;
    
    return math.sqrt(G / rho);
  }
}
