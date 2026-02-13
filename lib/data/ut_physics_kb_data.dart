import '../models/kb_section.dart';

/// UT Physics Knowledge Base Content
/// Comprehensive reference for ultrasonic testing fundamentals
final List<KbSection> utPhysicsKbData = [
  // 1) Wave Fundamentals
  KbSection(
    id: 'wave_fundamentals',
    title: 'Wave Fundamentals',
    bullets: [
      'Longitudinal vs Shear waves (particle motion differences)',
      'Wave velocity basics (material-dependent)',
      'Frequency vs wavelength relationship (λ = V / f)',
      'Basic terms: period, amplitude, phase',
    ],
  ),

  // 2) Reflection & Transmission
  KbSection(
    id: 'reflection_transmission',
    title: 'Reflection & Transmission',
    bullets: [
      'Acoustic impedance Z = ρV (concept)',
      'Reflection vs transmission at interfaces (why mismatch matters)',
      'Couplant layer effects (thin layer, angle changes, losses)',
    ],
  ),

  // 3) Snell's Law & Refraction
  KbSection(
    id: 'snells_law_refraction',
    title: 'Snell\'s Law & Refraction',
    bullets: [
      'Snell\'s Law in velocity form: sinθ1/V1 = sinθ2/V2',
      'Refraction angle behavior (slower/faster medium)',
      'Mode conversion overview (L↔S possibilities)',
      'Critical angles concept (when no real refracted solution)',
    ],
    actions: [
      KbLinkAction(
        label: 'Open Snell\'s Law Calculator',
        route: '/snells_law_suite',
      ),
    ],
  ),

  // 4) Beam Behavior
  KbSection(
    id: 'beam_behavior',
    title: 'Beam Behavior',
    bullets: [
      'Near field vs far field (what changes)',
      'Near field length (Fresnel): N = (D² f) / (4V) (use consistent unit note)',
      'Beam divergence concept (why beam spreads)',
      'Dead zone concept (near-surface limitations)',
      'Attenuation overview (frequency/material effects)',
    ],
    actions: [
      KbLinkAction(
        label: 'Open Near Field Calculator',
        route: '/tools', // TODO: Update when specific near field route available
      ),
      KbLinkAction(
        label: 'Open Beam Divergence Tool',
        route: '/tools', // TODO: Update when beam divergence route available
      ),
    ],
  ),

  // 5) Amplitude & dB Concepts
  KbSection(
    id: 'amplitude_db',
    title: 'Amplitude & dB Concepts',
    bullets: [
      'dB definition for amplitude: dB = 20 log₁₀(A2/A1)',
      '6 dB rule (doubling/halving amplitude)',
      'DAC concept (what it represents)',
      'TCG concept (why it\'s used)',
    ],
    actions: [
      KbLinkAction(
        label: 'Open dB Calculator',
        route: '/tools', // TODO: Update when dB calculator route available
      ),
    ],
  ),

  // 6) TOF & Geometry
  KbSection(
    id: 'tof_geometry',
    title: 'TOF & Geometry',
    bullets: [
      'Sound path vs depth vs surface distance (right triangle)',
      'Depth = SD * tanθ',
      'Sound path S = Depth / cosθ = SD / sinθ',
      'Skip distance:',
      '  • Half skip HS = T * tanθ',
      '  • Full skip FS = 2T * tanθ',
      'Multi-leg concept (odd/even leg direction)',
    ],
    actions: [
      KbLinkAction(
        label: 'Open Beam Path Tool',
        route: '/beam_geometry',
      ),
      KbLinkAction(
        label: 'Open Skip Distance Calculator',
        route: '/beam_geometry',
      ),
    ],
  ),
];
