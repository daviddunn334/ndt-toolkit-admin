import '../models/reference_section.dart';

/// Residual Stress Quick Reference Data
/// Field-friendly technical reference for NDT and welding technicians
const List<ReferenceSection> residualStressData = [
  ReferenceSection(
    title: 'What is Residual Stress?',
    bulletPoints: [
      'Definition: Locked-in internal stress present without external load',
      'Causes: Welding thermal cycles, cold working, forming/bending, machining, heat treatment',
      'Types: Tensile residual stress and Compressive residual stress',
      'Exists in balance throughout a component - some areas tensile, others compressive',
      'Can be significant enough to affect structural performance',
    ],
  ),
  ReferenceSection(
    title: 'Why It Matters in NDT',
    bulletPoints: [
      'Can contribute to stress corrosion cracking (SCC)',
      'Increases risk of hydrogen-induced cracking (HIC)',
      'Accelerates fatigue crack growth and propagation',
      'High tensile residual stress increases crack propagation risk',
      'Compressive stress can improve fatigue life and crack resistance',
      'Important consideration when evaluating crack-like indications',
      'Affects structural integrity assessments and fitness-for-service evaluations',
    ],
  ),
  ReferenceSection(
    title: 'Typical Sources (Welding Focus)',
    bulletPoints: [
      'High tensile stress near weld toe and weld root',
      'Heat affected zone (HAZ) experiences steep thermal gradients',
      'Rapid cooling effects lock in thermal stresses',
      'Thick-section weldments more susceptible due to constraint',
      'Weld sequencing and restraint conditions affect magnitude',
      'Multi-pass welds create complex residual stress patterns',
      'Mismatch in thermal expansion between base and weld metal',
      'Constraint from adjacent structures increases residual stress',
    ],
  ),
  ReferenceSection(
    title: 'Measurement Methods (Reference Only)',
    bulletPoints: [
      'X-ray diffraction (XRD): Measures surface stress with high accuracy',
      'Hole-drilling method: Semi-destructive, measures stress relief',
      'Ultrasonic acoustoelastic techniques: Non-destructive, through-thickness measurement',
      'Barkhausen noise: For ferromagnetic materials, surface/near-surface stress',
      'Neutron diffraction: Through-thickness measurement, research-grade equipment',
      'Contour method: Destructive, provides full 2D stress map',
      'Deep hole drilling: Measures through-thickness stress distribution',
    ],
  ),
  ReferenceSection(
    title: 'Typical Magnitude (Reference Ranges)',
    bulletPoints: [
      'Can approach yield strength locally in highly constrained welds',
      'Often 30–70% of yield strength in typical welded zones',
      'As-welded carbon steel: typically 200-400 MPa tensile',
      'As-welded stainless steel: typically 300-500 MPa tensile',
      'Cold-worked regions: 40-80% of yield strength',
      'Machined surfaces: typically 50-200 MPa (can be tensile or compressive)',
    ],
    disclaimer: 'Actual values depend heavily on material, geometry, welding process, heat input, and cooling rate.',
  ),
  ReferenceSection(
    title: 'Mitigation Methods',
    bulletPoints: [
      'Post Weld Heat Treatment (PWHT): Most effective for thick sections',
      'Stress relief heat treatment: Reduces residual stress to 10-30% of original',
      'Peening (shot peening, hammer peening): Induces compressive surface stress',
      'Controlled welding sequence: Minimizes constraint and distortion',
      'Preheat: Reduces thermal gradients during welding',
      'Low-hydrogen electrodes: Reduces hydrogen cracking susceptibility',
      'Weld joint design: Optimize for lower restraint',
      'Vibration stress relief: Alternative method, effectiveness debated',
      'Thermal stress relief: Localized heating for large components',
    ],
  ),
];
