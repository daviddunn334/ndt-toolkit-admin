import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../services/analytics_service.dart';

class TrigBeamPathCalculator extends StatefulWidget {
  const TrigBeamPathCalculator({super.key});

  @override
  State<TrigBeamPathCalculator> createState() => _TrigBeamPathCalculatorState();
}

class _TrigBeamPathCalculatorState extends State<TrigBeamPathCalculator> {
  final TextEditingController _angleController = TextEditingController();
  final TextEditingController _thicknessController = TextEditingController();
  final TextEditingController _surfaceDistanceController = TextEditingController();

  // New Dark Color System
  static const Color _bgMain = Color(0xFF1E232A);
  static const Color _bgCard = Color(0xFF2A313B);
  static const Color _bgElevated = Color(0xFF242A33);
  static const Color _textPrimary = Color(0xFFEDF9FF);
  static const Color _textSecondary = Color(0xFFAEBBC8);
  static const Color _textMuted = Color(0xFF7F8A96);
  static const Color _accentPrimary = Color(0xFF6C5BFF);
  static const Color _accentSuccess = Color(0xFF00E5A8);
  static const Color _accentAlert = Color(0xFFFE637E);

  double? _depth;
  int? _legNumber;
  double? _distanceIntoLeg;
  double? _fullSkipDistance;
  double? _halfSkipDistance;
  List<Map<String, double>>? _skipTable;
  String? _errorMessage;

  @override
  void dispose() {
    _angleController.dispose();
    _thicknessController.dispose();
    _surfaceDistanceController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _depth = null;
      _legNumber = null;
      _distanceIntoLeg = null;
      _fullSkipDistance = null;
      _halfSkipDistance = null;
      _skipTable = null;
    });

    if (_angleController.text.isEmpty || 
        _thicknessController.text.isEmpty || 
        _surfaceDistanceController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    try {
      final angle = double.parse(_angleController.text);
      final thickness = double.parse(_thicknessController.text);
      final surfaceDistance = double.parse(_surfaceDistanceController.text);

      if (angle <= 0 || angle >= 90) {
        setState(() {
          _errorMessage = 'Angle must be between 1° and 89°';
        });
        return;
      }

      if (thickness <= 0) {
        setState(() {
          _errorMessage = 'Thickness must be greater than 0';
        });
        return;
      }

      if (surfaceDistance < 0) {
        setState(() {
          _errorMessage = 'Surface distance cannot be negative';
        });
        return;
      }

      final angleRad = angle * (pi / 180);
      final tanAngle = tan(angleRad);
      final hs = thickness * tanAngle;
      final fs = 2 * thickness * tanAngle;
      final legNum = (surfaceDistance / hs).floor() + 1;
      final legPosition = surfaceDistance % hs;

      double depth;
      if (legNum % 2 == 1) {
        depth = legPosition * tanAngle;
      } else {
        depth = thickness - (legPosition * tanAngle);
      }
      depth = depth.clamp(0.0, thickness);

      final skipTable = <Map<String, double>>[];
      for (int i = 1; i <= 4; i++) {
        skipTable.add({
          'leg': i.toDouble(),
          'distance': i * hs,
        });
      }

      setState(() {
        _depth = depth;
        _legNumber = legNum;
        _distanceIntoLeg = legPosition;
        _fullSkipDistance = fs;
        _halfSkipDistance = hs;
        _skipTable = skipTable;
      });

      AnalyticsService().logCalculatorUsed(
        'Trig Beam Path Calculator',
        inputValues: {
          'probe_angle': angle,
          'thickness': thickness,
          'surface_distance': surfaceDistance,
          'leg_number': legNum,
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
      _depth = null;
      _legNumber = null;
      _distanceIntoLeg = null;
      _fullSkipDistance = null;
      _halfSkipDistance = null;
      _skipTable = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgMain,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: _bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📐 Trigonometric Beam Path Tool',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Shear Wave UT Beam Path Calculator',
                          style: TextStyle(
                            fontSize: 14,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Input Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInputField(
                      controller: _angleController,
                      label: 'Probe Angle (θ)',
                      hint: 'Enter angle',
                      suffix: 'degrees',
                      icon: Icons.adjust,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _thicknessController,
                      label: 'Material Thickness (T)',
                      hint: 'Enter thickness',
                      suffix: 'inches',
                      icon: Icons.straighten,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _surfaceDistanceController,
                      label: 'Surface Distance (SD)',
                      hint: 'Enter surface distance',
                      suffix: 'inches',
                      icon: Icons.linear_scale,
                    ),
                    const SizedBox(height: 24),

                    // Calculate button
                    ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate, size: 20),
                      label: const Text(
                        'Calculate',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 32,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _accentAlert.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _accentAlert.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: _accentAlert, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: _accentAlert,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Results
              if (_depth != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _accentPrimary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: _accentSuccess, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Results',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildResultRow('Calculated Depth (D)', '${_depth!.toStringAsFixed(3)}"', isLarge: true),
                      const SizedBox(height: 12),
                      _buildResultRow('Leg Number (L)', '$_legNumber'),
                      const SizedBox(height: 12),
                      _buildResultRow('Distance into Current Leg', '${_distanceIntoLeg!.toStringAsFixed(3)}"'),
                      const SizedBox(height: 16),
                      Divider(color: Colors.white.withOpacity(0.1)),
                      const SizedBox(height: 16),
                      _buildResultRow('Full Skip Distance (FS)', '${_fullSkipDistance!.toStringAsFixed(3)}"'),
                      const SizedBox(height: 12),
                      _buildResultRow('Half Skip Distance (HS)', '${_halfSkipDistance!.toStringAsFixed(3)}"'),
                    ],
                  ),
                ),

                // Skip Table
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.table_chart, color: _accentSuccess, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Skip Distance Table',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._skipTable!.map((entry) {
                        final legNum = entry['leg']!.toInt();
                        final distance = entry['distance']!;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Leg $legNum Skip:',
                                style: TextStyle(
                                  color: _textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${distance.toStringAsFixed(3)}"',
                                style: TextStyle(
                                  color: _textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],

              // Info section (kept light as requested)
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
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
                        Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
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
                    const SizedBox(height: 12),
                    Text(
                      'This tool calculates beam path geometry for shear wave UT inspections on flat plates using basic right-triangle trigonometry.',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Key Formulas:',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Half Skip (HS) = T × tan(θ)\n'
                      'Leg Number = floor(SD / HS) + 1\n'
                      'Depth (odd leg) = LegPosition × tan(θ)\n'
                      'Depth (even leg) = T - (LegPosition × tan(θ))',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 12,
                        height: 1.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String suffix,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(color: _textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _textMuted),
            suffixText: suffix,
            suffixStyle: TextStyle(color: _textSecondary),
            prefixIcon: Icon(icon, color: _textSecondary, size: 20),
            filled: true,
            fillColor: _bgElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _accentPrimary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          onChanged: (_) => _clearResults(),
        ),
      ],
    );
  }

  Widget _buildResultRow(String label, String value, {bool isLarge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 15 : 14,
              fontWeight: isLarge ? FontWeight.w600 : FontWeight.normal,
              color: _textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isLarge ? _accentPrimary : _textPrimary,
            fontSize: isLarge ? 20 : 16,
          ),
        ),
      ],
    );
  }
}
