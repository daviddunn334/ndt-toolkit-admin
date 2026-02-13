import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../services/analytics_service.dart';

class SoundPathLengthCalculator extends StatefulWidget {
  const SoundPathLengthCalculator({super.key});

  @override
  State<SoundPathLengthCalculator> createState() => _SoundPathLengthCalculatorState();
}

class _SoundPathLengthCalculatorState extends State<SoundPathLengthCalculator> {
  final TextEditingController _angleController = TextEditingController();
  final TextEditingController _depthController = TextEditingController();
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

  bool _isModeA = true; // Mode A: Depth → Sound Path, Mode B: Surface Distance → Sound Path

  double? _soundPath;
  double? _relatedDepth;
  double? _relatedSurfaceDistance;
  String? _errorMessage;

  @override
  void dispose() {
    _angleController.dispose();
    _depthController.dispose();
    _surfaceDistanceController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _soundPath = null;
      _relatedDepth = null;
      _relatedSurfaceDistance = null;
    });

    // Validate angle input (always required)
    if (_angleController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter probe angle';
      });
      return;
    }

    // Validate mode-specific input
    if (_isModeA && _depthController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter depth';
      });
      return;
    }

    if (!_isModeA && _surfaceDistanceController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter surface distance';
      });
      return;
    }

    try {
      final angle = double.parse(_angleController.text);

      // Validation: angle must be 1-89 degrees
      if (angle < 1 || angle >= 90) {
        setState(() {
          _errorMessage = 'Probe angle must be between 1° and 89°';
        });
        return;
      }

      // Convert angle to radians
      final angleRad = angle * (pi / 180);

      // Check for divide-by-zero cases
      final cosValue = cos(angleRad);
      final sinValue = sin(angleRad);
      final tanValue = tan(angleRad);

      if (cosValue.abs() < 0.0001 || sinValue.abs() < 0.0001 || tanValue.abs() < 0.0001) {
        setState(() {
          _errorMessage = 'Angle too close to 0° or 90° - calculations unstable';
        });
        return;
      }

      if (_isModeA) {
        // Mode A: Given Depth, compute Sound Path and Surface Distance
        final depth = double.parse(_depthController.text);

        if (depth <= 0) {
          setState(() {
            _errorMessage = 'Depth must be greater than 0';
          });
          return;
        }

        // SoundPath = Depth / cos(θ)
        final soundPath = depth / cosValue;

        // SurfaceDistance = Depth / tan(θ)
        final surfaceDistance = depth / tanValue;

        setState(() {
          _soundPath = soundPath;
          _relatedDepth = depth;
          _relatedSurfaceDistance = surfaceDistance;
        });

        // Log analytics
        AnalyticsService().logCalculatorUsed(
          'Sound Path Length Calculator',
          inputValues: {
            'mode': 'depth_to_sound_path',
            'probe_angle': angle,
            'depth': depth,
            'sound_path': soundPath,
          },
        );
      } else {
        // Mode B: Given Surface Distance, compute Sound Path and Depth
        final surfaceDistance = double.parse(_surfaceDistanceController.text);

        if (surfaceDistance <= 0) {
          setState(() {
            _errorMessage = 'Surface distance must be greater than 0';
          });
          return;
        }

        // Depth = SurfaceDistance × tan(θ)
        final depth = surfaceDistance * tanValue;

        // SoundPath = SurfaceDistance / sin(θ)
        final soundPath = surfaceDistance / sinValue;

        setState(() {
          _soundPath = soundPath;
          _relatedDepth = depth;
          _relatedSurfaceDistance = surfaceDistance;
        });

        // Log analytics
        AnalyticsService().logCalculatorUsed(
          'Sound Path Length Calculator',
          inputValues: {
            'mode': 'surface_distance_to_sound_path',
            'probe_angle': angle,
            'surface_distance': surfaceDistance,
            'sound_path': soundPath,
          },
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Please enter valid numbers';
      });
    }
  }

  void _clearResults() {
    setState(() {
      _soundPath = null;
      _relatedDepth = null;
      _relatedSurfaceDistance = null;
      _errorMessage = null;
    });
  }

  void _toggleMode() {
    setState(() {
      _isModeA = !_isModeA;
      _clearResults();
      // Clear the mode-specific input field
      _depthController.clear();
      _surfaceDistanceController.clear();
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
                          '📏 Sound Path Length',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'True Beam Path Through Material',
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

              // Mode Toggle
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
                    Text(
                      'Calculation Mode',
                      style: TextStyle(
                        color: _textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (!_isModeA) _toggleMode();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: _isModeA ? _accentPrimary : _bgElevated,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _isModeA ? _accentPrimary : Colors.white.withOpacity(0.08),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_downward,
                                    size: 16,
                                    color: _isModeA ? Colors.white : _textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Depth → Path',
                                    style: TextStyle(
                                      color: _isModeA ? Colors.white : _textSecondary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_isModeA) _toggleMode();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: !_isModeA ? _accentPrimary : _bgElevated,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: !_isModeA ? _accentPrimary : Colors.white.withOpacity(0.08),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 16,
                                    color: !_isModeA ? Colors.white : _textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Surface → Path',
                                    style: TextStyle(
                                      color: !_isModeA ? Colors.white : _textSecondary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

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
                    // Common input: Probe Angle
                    _buildInputField(
                      controller: _angleController,
                      label: 'Probe Angle (θ)',
                      hint: 'Enter probe angle',
                      suffix: 'degrees',
                      icon: Icons.adjust,
                    ),
                    const SizedBox(height: 16),

                    // Mode A: Depth input
                    if (_isModeA)
                      _buildInputField(
                        controller: _depthController,
                        label: 'Depth (D)',
                        hint: 'Enter depth',
                        suffix: 'inches',
                        icon: Icons.height,
                      ),

                    // Mode B: Surface Distance input
                    if (!_isModeA)
                      _buildInputField(
                        controller: _surfaceDistanceController,
                        label: 'Surface Distance (SD)',
                        hint: 'Enter surface distance',
                        suffix: 'inches',
                        icon: Icons.straighten,
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
              if (_soundPath != null) ...[
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
                      // Sound Path (primary result)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _accentPrimary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _accentPrimary.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Sound Path Length',
                              style: TextStyle(
                                fontSize: 14,
                                color: _textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_soundPath!.toStringAsFixed(3)}"',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: _accentPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Related values
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _bgElevated,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Complete Reference',
                              style: TextStyle(
                                fontSize: 12,
                                color: _textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildResultRow(
                              'Depth',
                              '${_relatedDepth!.toStringAsFixed(3)}"',
                            ),
                            Divider(height: 20, color: Colors.white.withOpacity(0.1)),
                            _buildResultRow(
                              'Surface Distance',
                              '${_relatedSurfaceDistance!.toStringAsFixed(3)}"',
                            ),
                            Divider(height: 20, color: Colors.white.withOpacity(0.1)),
                            _buildResultRow(
                              'Sound Path',
                              '${_soundPath!.toStringAsFixed(3)}"',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Info section
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
                      'Calculates the true sound path (beam path length) through the material for shear-wave UT in flat plates.',
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
                      'Mode A (Given Depth):\n'
                      '  Sound Path = Depth / cos(θ)\n'
                      '  Surface Distance = Depth / tan(θ)\n\n'
                      'Mode B (Given Surface Distance):\n'
                      '  Depth = Surface Distance × tan(θ)\n'
                      '  Sound Path = Surface Distance / sin(θ)',
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

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: _textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: _textPrimary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
