import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import '../services/analytics_service.dart';

class SurfaceDistanceDepthConverter extends StatefulWidget {
  const SurfaceDistanceDepthConverter({super.key});

  @override
  State<SurfaceDistanceDepthConverter> createState() => _SurfaceDistanceDepthConverterState();
}

class _SurfaceDistanceDepthConverterState extends State<SurfaceDistanceDepthConverter> {
  final TextEditingController _angleController = TextEditingController();
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _thicknessController = TextEditingController();

  // Mode selection
  bool _isModeA = true; // true = SD→D, false = D→SD
  bool _isMultiLeg = false;

  // Results
  double? _resultValue;
  double? _soundPath;
  int? _legNumber;
  double? _legPosition;
  double? _halfSkip;
  double? _fullSkip;
  String? _errorMessage;

  @override
  void dispose() {
    _angleController.dispose();
    _inputController.dispose();
    _thicknessController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _resultValue = null;
      _soundPath = null;
      _legNumber = null;
      _legPosition = null;
      _halfSkip = null;
      _fullSkip = null;
    });

    // Validate inputs
    if (_angleController.text.isEmpty || _inputController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all required fields';
      });
      return;
    }

    if (_isMultiLeg && _thicknessController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Thickness is required for multi-leg mode';
      });
      return;
    }

    try {
      final angle = double.parse(_angleController.text);
      final inputValue = double.parse(_inputController.text);
      final thickness = _isMultiLeg ? double.parse(_thicknessController.text) : null;

      // Validation
      if (angle < 1 || angle > 89) {
        setState(() {
          _errorMessage = 'Probe angle must be between 1° and 89°';
        });
        return;
      }

      if (inputValue < 0) {
        setState(() {
          _errorMessage = 'Input value must be ≥ 0';
        });
        return;
      }

      if (_isMultiLeg && (thickness == null || thickness <= 0)) {
        setState(() {
          _errorMessage = 'Thickness must be > 0';
        });
        return;
      }

      // Convert angle to radians
      final angleRad = angle * (pi / 180);
      final tanValue = tan(angleRad);
      final cosValue = cos(angleRad);

      if (_isMultiLeg) {
        // Multi-leg mode
        _calculateMultiLeg(inputValue, angleRad, tanValue, thickness!);
      } else {
        // Single-leg mode
        _calculateSingleLeg(inputValue, angleRad, tanValue, cosValue);
      }

      // Log analytics
      AnalyticsService().logCalculatorUsed(
        'Surface Distance Depth Converter',
        inputValues: {
          'mode': _isModeA ? 'SD_to_D' : 'D_to_SD',
          'multi_leg': _isMultiLeg,
          'probe_angle': angle,
          'input_value': inputValue,
          if (_isMultiLeg) 'thickness': thickness,
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Please enter valid numbers';
      });
    }
  }

  void _calculateSingleLeg(double input, double angleRad, double tanValue, double cosValue) {
    if (_isModeA) {
      // Mode A: Surface Distance → Depth
      final depth = input * tanValue;
      final soundPath = depth / cosValue;
      
      setState(() {
        _resultValue = depth;
        _soundPath = soundPath;
      });
    } else {
      // Mode B: Depth → Surface Distance
      final surfaceDistance = input / tanValue;
      final soundPath = input / cosValue;
      
      setState(() {
        _resultValue = surfaceDistance;
        _soundPath = soundPath;
      });
    }
  }

  void _calculateMultiLeg(double input, double angleRad, double tanValue, double thickness) {
    final hs = thickness * tanValue;
    final fs = 2 * hs;

    setState(() {
      _halfSkip = hs;
      _fullSkip = fs;
    });

    if (_isModeA) {
      // Mode A: Total Surface Distance → Depth + Leg
      final sdTotal = input;
      
      // Calculate leg number
      final legNum = (sdTotal / hs).floor() + 1;
      
      // Position within current leg
      final p = sdTotal % hs;
      
      // Calculate depth based on odd/even leg
      double depth;
      if (legNum % 2 == 1) {
        // Odd leg: beam traveling down
        depth = p * tanValue;
      } else {
        // Even leg: beam traveling up
        depth = thickness - (p * tanValue);
      }
      
      // Clamp depth to [0, T]
      depth = depth.clamp(0.0, thickness);
      
      setState(() {
        _resultValue = depth;
        _legNumber = legNum;
        _legPosition = p;
      });
    } else {
      // Mode B: Depth → Surface Distance (candidates)
      final targetDepth = input;
      
      if (targetDepth < 0 || targetDepth > thickness) {
        setState(() {
          _errorMessage = 'Depth must be between 0 and $thickness';
        });
        return;
      }
      
      // For simplicity, calculate for leg 1 (odd leg, going down)
      // In a full implementation, you could show multiple leg candidates
      final p = targetDepth / tanValue;
      final sdTotal = p; // First leg
      
      setState(() {
        _resultValue = sdTotal;
        _legNumber = 1;
        _legPosition = p;
      });
    }
  }

  void _clearResults() {
    setState(() {
      _resultValue = null;
      _soundPath = null;
      _legNumber = null;
      _legPosition = null;
      _halfSkip = null;
      _fullSkip = null;
      _errorMessage = null;
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
                                '↔️ Surface Distance ↔ Depth',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFEDF9FF),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Angle-beam UT converter',
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

                    // Mode Toggle
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
                          Text(
                            'Conversion Mode',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFEDF9FF),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildModeButton(
                                  'SD → D',
                                  Icons.arrow_forward,
                                  _isModeA,
                                  () {
                                    setState(() {
                                      _isModeA = true;
                                      _clearResults();
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildModeButton(
                                  'D → SD',
                                  Icons.arrow_back,
                                  !_isModeA,
                                  () {
                                    setState(() {
                                      _isModeA = false;
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
                    const SizedBox(height: 16),

                    // Multi-leg Toggle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF242A33),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFB020).withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Multi-leg Mode',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFFFB020),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Use thickness + leg logic',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFFEDF9FF).withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isMultiLeg,
                            onChanged: (value) {
                              setState(() {
                                _isMultiLeg = value;
                                _clearResults();
                              });
                            },
                            activeColor: const Color(0xFFFFB020),
                            activeTrackColor: const Color(0xFFFFB020).withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Input fields
                    _buildDarkTextField(
                      controller: _angleController,
                      label: 'Probe Angle (θ)',
                      hint: 'Enter probe angle',
                      suffix: 'degrees',
                      icon: Icons.adjust,
                    ),
                    const SizedBox(height: 16),

                    if (_isMultiLeg) ...[
                      _buildDarkTextField(
                        controller: _thicknessController,
                        label: 'Thickness (T)',
                        hint: 'Enter material thickness',
                        suffix: 'inches',
                        icon: Icons.straighten,
                      ),
                      const SizedBox(height: 16),
                    ],

                    _buildDarkTextField(
                      controller: _inputController,
                      label: _isModeA 
                          ? (_isMultiLeg ? 'Total Surface Distance (SD)' : 'Surface Distance (SD)')
                          : (_isMultiLeg ? 'Target Depth (D)' : 'Depth (D)'),
                      hint: _isModeA ? 'Enter surface distance' : 'Enter depth',
                      suffix: 'inches',
                      icon: _isModeA ? Icons.linear_scale : Icons.vertical_align_center,
                    ),
                    const SizedBox(height: 24),

                    // Error message
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
                        child: Row(
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
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Results
                    if (_resultValue != null) ...[
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
                              _isModeA ? 'Depth (D)' : 'Surface Distance (SD)',
                              '${_resultValue!.toStringAsFixed(3)}"',
                              valueColor: const Color(0xFF00E5A8),
                              isLarge: true,
                            ),
                            if (_soundPath != null) ...[
                              const SizedBox(height: 12),
                              _buildResultRow(
                                'Sound Path (S)',
                                '${_soundPath!.toStringAsFixed(3)}"',
                                valueColor: const Color(0xFF00E5A8),
                              ),
                            ],
                            if (_isMultiLeg && _legNumber != null) ...[
                              const SizedBox(height: 16),
                              Divider(color: const Color(0xFFEDF9FF).withOpacity(0.2)),
                              const SizedBox(height: 12),
                              _buildResultRow(
                                'Leg Number',
                                '$_legNumber',
                                valueColor: const Color(0xFFFFB020),
                              ),
                            ],
                            if (_isMultiLeg && _legPosition != null) ...[
                              const SizedBox(height: 12),
                              _buildResultRow(
                                'Distance into Leg',
                                '${_legPosition!.toStringAsFixed(3)}"',
                                valueColor: const Color(0xFFFFB020),
                              ),
                            ],
                            if (_isMultiLeg && _halfSkip != null) ...[
                              const SizedBox(height: 12),
                              _buildResultRow(
                                'Half Skip (HS)',
                                '${_halfSkip!.toStringAsFixed(3)}"',
                                valueColor: const Color(0xFFFFB020),
                              ),
                            ],
                            if (_isMultiLeg && _fullSkip != null) ...[
                              const SizedBox(height: 12),
                              _buildResultRow(
                                'Full Skip (FS)',
                                '${_fullSkip!.toStringAsFixed(3)}"',
                                valueColor: const Color(0xFFFFB020),
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
                        'Convert',
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
                                'About This Tool',
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
                            'Convert between surface distance (along surface) and depth (through-wall) for angle-beam UT using right-triangle trigonometry.',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Single-leg Formulas:',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'D = SD × tan(θ)  [SD → D]\n'
                            'SD = D / tan(θ)  [D → SD]\n'
                            'S = D / cos(θ)    [Sound path]',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 11,
                              height: 1.4,
                              fontFamily: 'monospace',
                            ),
                          ),
                          if (_isMultiLeg) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Multi-leg Mode:',
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Accounts for beam reflections. Odd legs travel down from top, even legs travel up from bottom.',
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
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

  Widget _buildModeButton(String label, IconData icon, bool isSelected, VoidCallback onTap) {
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFEDF9FF).withOpacity(0.7),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFFEDF9FF).withOpacity(0.7),
            ),
          ],
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
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onChanged: (_) => _clearResults(),
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
            fontSize: isLarge ? 22 : 16,
          ),
        ),
      ],
    );
  }
}
