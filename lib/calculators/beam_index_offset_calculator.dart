import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import '../services/analytics_service.dart';

class BeamIndexOffsetCalculator extends StatefulWidget {
  const BeamIndexOffsetCalculator({super.key});

  @override
  State<BeamIndexOffsetCalculator> createState() => _BeamIndexOffsetCalculatorState();
}

class _BeamIndexOffsetCalculatorState extends State<BeamIndexOffsetCalculator> {
  final TextEditingController _standoffController = TextEditingController();
  final TextEditingController _theta1Controller = TextEditingController();
  final TextEditingController _theta2Controller = TextEditingController();
  final TextEditingController _v1Controller = TextEditingController();
  final TextEditingController _v2Controller = TextEditingController();

  bool _useKnownAngle = true; // true = Mode A, false = Mode B
  String? _selectedMaterial1;
  String? _selectedMaterial2;
  
  double? _beamIndexOffset;
  double? _computedTheta1;
  String? _errorMessage;
  String? _warningMessage;

  // Material velocity presets (in m/s)
  final Map<String, double> _materialVelocities = {
    'Custom': 0,
    'Rexolite': 2337,
    'Acrylic': 2730,
    'Water': 1480,
    'Steel (Shear)': 3240,
    'Steel (Longitudinal)': 5920,
  };

  @override
  void dispose() {
    _standoffController.dispose();
    _theta1Controller.dispose();
    _theta2Controller.dispose();
    _v1Controller.dispose();
    _v2Controller.dispose();
    super.dispose();
  }

  void _onMaterial1Changed(String? value) {
    setState(() {
      _selectedMaterial1 = value;
      if (value != null && value != 'Custom') {
        _v1Controller.text = _materialVelocities[value]!.toString();
      }
    });
  }

  void _onMaterial2Changed(String? value) {
    setState(() {
      _selectedMaterial2 = value;
      if (value != null && value != 'Custom') {
        _v2Controller.text = _materialVelocities[value]!.toString();
      }
    });
  }

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _warningMessage = null;
      _beamIndexOffset = null;
      _computedTheta1 = null;
    });

    // Validate standoff height
    if (_standoffController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter standoff height';
      });
      return;
    }

    try {
      final h = double.parse(_standoffController.text);

      if (h <= 0) {
        setState(() {
          _errorMessage = 'Standoff height must be greater than 0';
        });
        return;
      }

      double theta1Deg;

      if (_useKnownAngle) {
        // Mode A: Known wedge angle
        if (_theta1Controller.text.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter wedge angle';
          });
          return;
        }

        theta1Deg = double.parse(_theta1Controller.text);

        if (theta1Deg < 0 || theta1Deg >= 90) {
          setState(() {
            _errorMessage = 'Wedge angle must be between 0° and 89°';
          });
          return;
        }
      } else {
        // Mode B: Solve wedge angle from Snell's Law
        if (_theta2Controller.text.isEmpty || 
            _v1Controller.text.isEmpty || 
            _v2Controller.text.isEmpty) {
          setState(() {
            _errorMessage = 'Please fill in all fields for Snell\'s Law calculation';
          });
          return;
        }

        final theta2Deg = double.parse(_theta2Controller.text);
        final v1 = double.parse(_v1Controller.text);
        final v2 = double.parse(_v2Controller.text);

        if (v1 <= 0 || v2 <= 0) {
          setState(() {
            _errorMessage = 'Velocities must be greater than 0';
          });
          return;
        }

        if (theta2Deg < 0 || theta2Deg >= 90) {
          setState(() {
            _errorMessage = 'Refracted angle must be between 0° and 89°';
          });
          return;
        }

        // Solve for θ1 using Snell's Law: sin(θ1) / V1 = sin(θ2) / V2
        final theta2Rad = theta2Deg * (pi / 180);
        final ratio = (v1 / v2) * sin(theta2Rad);

        // Clamp to prevent domain errors
        final clampedRatio = ratio.clamp(-1.0, 1.0);

        if (ratio.abs() > 1.0) {
          setState(() {
            _errorMessage = 'No real solution for θ1';
            _warningMessage = 'The velocity ratio and refracted angle produce an impossible configuration (|sin(θ1)| > 1)';
          });
          return;
        }

        final theta1Rad = asin(clampedRatio);
        theta1Deg = theta1Rad * (180 / pi);
        
        setState(() {
          _computedTheta1 = theta1Deg;
        });
      }

      // Prevent tan blowup near 90°
      if (theta1Deg >= 89.0) {
        setState(() {
          _errorMessage = 'Angle too close to 90° (tan approaches infinity)';
        });
        return;
      }

      // Calculate beam index offset: X = h × tan(θ1)
      final theta1Rad = theta1Deg * (pi / 180);
      final x = h * tan(theta1Rad);

      setState(() {
        _beamIndexOffset = x;
      });

      // Log analytics
      AnalyticsService().logCalculatorUsed(
        'Beam Index Offset Calculator',
        inputValues: {
          'mode': _useKnownAngle ? 'known_angle' : 'snell_law',
          'standoff_height': h,
          'theta1': theta1Deg,
          'beam_index_offset': x,
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Please enter valid numbers';
      });
    }
  }

  void _clearResults() {
    setState(() {
      _beamIndexOffset = null;
      _computedTheta1 = null;
      _errorMessage = null;
      _warningMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E232A),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A313B),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                          color: const Color(0xFFEDF9FF),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '📏 Beam Index Offset',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFEDF9FF),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Angle-Beam Wedge Geometry',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(0xFFEDF9FF).withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Mode toggle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF242A33),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF6C5BFF).withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.swap_horiz,
                                color: const Color(0xFF6C5BFF),
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Calculation Mode',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF6C5BFF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildModeButton(
                                  'Known θ₁',
                                  _useKnownAngle,
                                  () {
                                    setState(() {
                                      _useKnownAngle = true;
                                      _clearResults();
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildModeButton(
                                  'Solve θ₁ (Snell)',
                                  !_useKnownAngle,
                                  () {
                                    setState(() {
                                      _useKnownAngle = false;
                                      _clearResults();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Common input: Standoff height info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'h is the normal (perpendicular) distance from element/virtual origin to the contact surface',
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Standoff height input
                    _buildDarkTextField(
                      controller: _standoffController,
                      label: 'Standoff Height (h)',
                      hint: 'Enter standoff height',
                      suffix: 'units',
                      icon: Icons.height,
                      helper: 'Perpendicular distance to contact surface',
                    ),
                    const SizedBox(height: 24),

                    // Mode-specific inputs
                    if (_useKnownAngle) ...[
                      // Mode A: Known wedge angle
                      Text(
                        'Known Wedge Angle',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEDF9FF),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDarkTextField(
                        controller: _theta1Controller,
                        label: 'Wedge Angle (θ₁)',
                        hint: 'Enter wedge angle',
                        suffix: 'degrees',
                        icon: Icons.adjust,
                        helper: 'Angle inside wedge relative to surface normal',
                      ),
                    ] else ...[
                      // Mode B: Solve θ1 from Snell's Law
                      Text(
                        'Solve Wedge Angle using Snell\'s Law',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEDF9FF),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDarkTextField(
                        controller: _theta2Controller,
                        label: 'Refracted Angle in Material (θ₂)',
                        hint: 'Enter refracted angle',
                        suffix: 'degrees',
                        icon: Icons.adjust,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Wedge Material',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEDF9FF).withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDarkDropdown(
                        value: _selectedMaterial1,
                        label: 'Material Preset',
                        icon: Icons.layers,
                        items: _materialVelocities.keys.toList(),
                        onChanged: _onMaterial1Changed,
                      ),
                      const SizedBox(height: 12),
                      _buildDarkTextField(
                        controller: _v1Controller,
                        label: 'Wedge Velocity (V₁)',
                        hint: 'Enter velocity',
                        suffix: 'm/s',
                        icon: Icons.speed,
                        onChanged: (_) {
                          _clearResults();
                          if (_selectedMaterial1 != 'Custom') {
                            setState(() {
                              _selectedMaterial1 = 'Custom';
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Test Material',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEDF9FF).withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDarkDropdown(
                        value: _selectedMaterial2,
                        label: 'Material Preset',
                        icon: Icons.layers,
                        items: _materialVelocities.keys.toList(),
                        onChanged: _onMaterial2Changed,
                      ),
                      const SizedBox(height: 12),
                      _buildDarkTextField(
                        controller: _v2Controller,
                        label: 'Material Velocity (V₂)',
                        hint: 'Enter velocity',
                        suffix: 'm/s',
                        icon: Icons.speed,
                        onChanged: (_) {
                          _clearResults();
                          if (_selectedMaterial2 != 'Custom') {
                            setState(() {
                              _selectedMaterial2 = 'Custom';
                            });
                          }
                        },
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Error/Warning messages
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFE637E).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFE637E).withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Color(0xFFFE637E),
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Color(0xFFFE637E),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_warningMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _warningMessage!,
                                style: TextStyle(
                                  color: const Color(0xFFFE637E).withOpacity(0.9),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Results
                    if (_beamIndexOffset != null) ...[
                      Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF242A33),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF00E5A8),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: const Color(0xFF00E5A8),
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Results',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: const Color(0xFF00E5A8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildResultRow(
                              'Beam Index Offset (X)',
                              '${_beamIndexOffset!.toStringAsFixed(3)} units',
                              valueColor: const Color(0xFF00E5A8),
                              isLarge: true,
                            ),
                            if (_computedTheta1 != null) ...[
                              const SizedBox(height: 16),
                              Divider(color: const Color(0xFFEDF9FF).withOpacity(0.2)),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                'Computed Wedge Angle (θ₁)',
                                '${_computedTheta1!.toStringAsFixed(3)}°',
                                valueColor: const Color(0xFF00E5A8),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Calculated using Snell\'s Law',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF00E5A8).withOpacity(0.8),
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    // Calculate button
                    ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate, color: Colors.white),
                      label: const Text(
                        'Calculate',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5BFF),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),

                    // Info section
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'About Beam Index Offset',
                                style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This calculator estimates the horizontal offset (X) from the probe element (or virtual origin) to the beam exit point (index point) on the test surface for angle-beam wedge setups. This is essential for proper probe positioning.',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Formula:',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'X = h × tan(θ₁)',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Where:\n'
                            '• h = Standoff height (perpendicular distance)\n'
                            '• θ₁ = Wedge angle (inside wedge material)\n'
                            '• X = Horizontal offset to beam exit point',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C5BFF) : const Color(0xFF1E232A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF6C5BFF) : const Color(0xFF6C5BFF).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFFEDF9FF).withOpacity(0.7),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDarkTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? suffix,
    required IconData icon,
    String? helper,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Color(0xFFEDF9FF),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: const Color(0xFFEDF9FF).withOpacity(0.7),
          fontSize: 14,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFFEDF9FF).withOpacity(0.3),
          fontSize: 14,
        ),
        filled: true,
        fillColor: const Color(0xFF242A33),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFEDF9FF).withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFEDF9FF).withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF6C5BFF),
            width: 2,
          ),
        ),
        suffixText: suffix,
        suffixStyle: TextStyle(
          color: const Color(0xFFEDF9FF).withOpacity(0.5),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF6C5BFF)),
        helperText: helper,
        helperStyle: TextStyle(
          color: const Color(0xFFEDF9FF).withOpacity(0.5),
          fontSize: 11,
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onChanged: onChanged ?? (_) => _clearResults(),
    );
  }

  Widget _buildDarkDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      style: const TextStyle(
        color: Color(0xFFEDF9FF),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      dropdownColor: const Color(0xFF242A33),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: const Color(0xFFEDF9FF).withOpacity(0.7),
          fontSize: 14,
        ),
        filled: true,
        fillColor: const Color(0xFF242A33),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFEDF9FF).withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFEDF9FF).withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF6C5BFF),
            width: 2,
          ),
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF6C5BFF)),
      ),
      items: items.map((String material) {
        return DropdownMenuItem<String>(
          value: material,
          child: Text(material),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildResultRow(
    String label,
    String value, {
    Color? valueColor,
    bool isLarge = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 16 : 14,
              fontWeight: isLarge ? FontWeight.w600 : FontWeight.normal,
              color: const Color(0xFFEDF9FF),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
            fontSize: isLarge ? 24 : 16,
          ),
        ),
      ],
    );
  }
}
