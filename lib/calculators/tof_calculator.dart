import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../services/analytics_service.dart';

class TofCalculator extends StatefulWidget {
  const TofCalculator({super.key});

  @override
  State<TofCalculator> createState() => _TofCalculatorState();
}

class _TofCalculatorState extends State<TofCalculator> {
  final TextEditingController _velocityController = TextEditingController();
  final TextEditingController _soundPathController = TextEditingController();
  final TextEditingController _tofController = TextEditingController();
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
  static const Color _accentWarning = Color(0xFFFFB020);

  bool _isModeA = true; // Mode A: Sound Path → TOF, Mode B: TOF → Sound Path
  bool _useAngleMode = false; // Optional angle sub-mode for computing Sound Path
  bool _useDepth = true; // true = use Depth, false = use Surface Distance

  double? _resultTof;
  double? _resultTofMicroseconds;
  double? _resultSoundPath;
  double? _computedDepth;
  double? _computedSurfaceDistance;
  String? _errorMessage;

  @override
  void dispose() {
    _velocityController.dispose();
    _soundPathController.dispose();
    _tofController.dispose();
    _angleController.dispose();
    _depthController.dispose();
    _surfaceDistanceController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _resultTof = null;
      _resultTofMicroseconds = null;
      _resultSoundPath = null;
      _computedDepth = null;
      _computedSurfaceDistance = null;
    });

    // Validate velocity (always required)
    if (_velocityController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter velocity';
      });
      return;
    }

    try {
      final velocity = double.parse(_velocityController.text);

      if (velocity <= 0) {
        setState(() {
          _errorMessage = 'Velocity must be greater than 0';
        });
        return;
      }

      if (_isModeA) {
        // Mode A: Sound Path → TOF
        if (_useAngleMode) {
          // Sub-mode: Compute Sound Path from angle + depth or surface distance
          _calculateSoundPathFromAngle(velocity);
        } else {
          // Direct Sound Path input
          if (_soundPathController.text.isEmpty) {
            setState(() {
              _errorMessage = 'Please enter sound path';
            });
            return;
          }

          final soundPath = double.parse(_soundPathController.text);

          if (soundPath <= 0) {
            setState(() {
              _errorMessage = 'Sound path must be greater than 0';
            });
            return;
          }

          _computeTofFromSoundPath(soundPath, velocity);
        }
      } else {
        // Mode B: TOF → Sound Path
        if (_tofController.text.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter time-of-flight';
          });
          return;
        }

        final tof = double.parse(_tofController.text);

        if (tof <= 0) {
          setState(() {
            _errorMessage = 'Time-of-flight must be greater than 0';
          });
          return;
        }

        _computeSoundPathFromTof(tof, velocity);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Please enter valid numbers';
      });
    }
  }

  void _calculateSoundPathFromAngle(double velocity) {
    if (_angleController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter probe angle';
      });
      return;
    }

    final angle = double.parse(_angleController.text);

    if (angle < 1 || angle >= 90) {
      setState(() {
        _errorMessage = 'Probe angle must be between 1° and 89°';
      });
      return;
    }

    final angleRad = angle * (pi / 180);

    if (_useDepth) {
      // Given Depth: S = D / cos(θ)
      if (_depthController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter depth';
        });
        return;
      }

      final depth = double.parse(_depthController.text);

      if (depth <= 0) {
        setState(() {
          _errorMessage = 'Depth must be greater than 0';
        });
        return;
      }

      final cosValue = cos(angleRad);
      if (cosValue.abs() < 0.0001) {
        setState(() {
          _errorMessage = 'Angle too close to 90° - calculation unstable';
        });
        return;
      }

      final soundPath = depth / cosValue;
      final surfaceDistance = depth / tan(angleRad);

      setState(() {
        _computedDepth = depth;
        _computedSurfaceDistance = surfaceDistance;
      });

      _computeTofFromSoundPath(soundPath, velocity);
    } else {
      // Given Surface Distance: S = SD / sin(θ)
      if (_surfaceDistanceController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter surface distance';
        });
        return;
      }

      final surfaceDistance = double.parse(_surfaceDistanceController.text);

      if (surfaceDistance <= 0) {
        setState(() {
          _errorMessage = 'Surface distance must be greater than 0';
        });
        return;
      }

      final sinValue = sin(angleRad);
      if (sinValue.abs() < 0.0001) {
        setState(() {
          _errorMessage = 'Angle too close to 0° - calculation unstable';
        });
        return;
      }

      final soundPath = surfaceDistance / sinValue;
      final depth = surfaceDistance * tan(angleRad);

      setState(() {
        _computedDepth = depth;
        _computedSurfaceDistance = surfaceDistance;
      });

      _computeTofFromSoundPath(soundPath, velocity);
    }
  }

  void _computeTofFromSoundPath(double soundPath, double velocity) {
    final tof = soundPath / velocity;
    final tofMicroseconds = tof * 1e6;

    setState(() {
      _resultTof = tof;
      _resultTofMicroseconds = tofMicroseconds;
      _resultSoundPath = soundPath;
    });

    // Log analytics
    AnalyticsService().logCalculatorUsed(
      'Time-of-Flight (TOF) Calculator',
      inputValues: {
        'mode': 'sound_path_to_tof',
        'velocity': velocity,
        'sound_path': soundPath,
        'tof_seconds': tof,
        'use_angle_mode': _useAngleMode,
      },
    );
  }

  void _computeSoundPathFromTof(double tof, double velocity) {
    final soundPath = tof * velocity;
    final tofMicroseconds = tof * 1e6;

    setState(() {
      _resultTof = tof;
      _resultTofMicroseconds = tofMicroseconds;
      _resultSoundPath = soundPath;
    });

    // Log analytics
    AnalyticsService().logCalculatorUsed(
      'Time-of-Flight (TOF) Calculator',
      inputValues: {
        'mode': 'tof_to_sound_path',
        'velocity': velocity,
        'tof_seconds': tof,
        'sound_path': soundPath,
      },
    );
  }

  void _clearResults() {
    setState(() {
      _resultTof = null;
      _resultTofMicroseconds = null;
      _resultSoundPath = null;
      _computedDepth = null;
      _computedSurfaceDistance = null;
      _errorMessage = null;
    });
  }

  void _toggleMode() {
    setState(() {
      _isModeA = !_isModeA;
      _useAngleMode = false; // Reset angle mode when switching
      _clearResults();
      _soundPathController.clear();
      _tofController.clear();
    });
  }

  void _toggleAngleMode() {
    setState(() {
      _useAngleMode = !_useAngleMode;
      _clearResults();
      if (_useAngleMode) {
        _soundPathController.clear();
      }
    });
  }

  void _toggleAngleSubMode() {
    setState(() {
      _useDepth = !_useDepth;
      _clearResults();
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
                          '⏱️ Time-of-Flight (TOF)',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ultrasonic Travel Time Calculator',
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
                                    Icons.trending_flat,
                                    size: 16,
                                    color: _isModeA ? Colors.white : _textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Path → TOF',
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
                                    Icons.keyboard_return,
                                    size: 16,
                                    color: !_isModeA ? Colors.white : _textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'TOF → Path',
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
                    // Common input: Velocity
                    _buildInputField(
                      controller: _velocityController,
                      label: 'Wave Velocity (V)',
                      hint: 'Enter wave velocity',
                      suffix: 'distance/sec',
                      icon: Icons.speed,
                    ),
                    const SizedBox(height: 16),

                    // Mode A: Sound Path → TOF
                    if (_isModeA) ...[
                      // Option to use angle mode
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _useAngleMode ? _accentWarning.withOpacity(0.1) : _bgElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _useAngleMode ? _accentWarning.withOpacity(0.3) : Colors.white.withOpacity(0.05),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Use Angle Mode (Optional)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _useAngleMode ? _accentWarning : _textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Switch(
                              value: _useAngleMode,
                              onChanged: (value) => _toggleAngleMode(),
                              activeColor: _accentWarning,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_useAngleMode) ...[
                        // Angle mode: compute Sound Path from angle + depth/surface distance
                        _buildInputField(
                          controller: _angleController,
                          label: 'Probe Angle (θ)',
                          hint: 'Enter probe angle',
                          suffix: 'degrees',
                          icon: Icons.adjust,
                        ),
                        const SizedBox(height: 16),

                        // Sub-mode toggle: Depth vs Surface Distance
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _accentWarning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _accentWarning.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Given Parameter',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (!_useDepth) _toggleAngleSubMode();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          color: _useDepth ? _accentWarning : _bgElevated,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: _useDepth ? _accentWarning : Colors.white.withOpacity(0.08),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Text(
                                          'Depth',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: _useDepth ? Colors.white : _textSecondary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (_useDepth) _toggleAngleSubMode();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          color: !_useDepth ? _accentWarning : _bgElevated,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: !_useDepth ? _accentWarning : Colors.white.withOpacity(0.08),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Text(
                                          'Surface Distance',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: !_useDepth ? Colors.white : _textSecondary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
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

                        if (_useDepth)
                          _buildInputField(
                            controller: _depthController,
                            label: 'Depth (D)',
                            hint: 'Enter depth',
                            suffix: 'inches',
                            icon: Icons.height,
                          )
                        else
                          _buildInputField(
                            controller: _surfaceDistanceController,
                            label: 'Surface Distance (SD)',
                            hint: 'Enter surface distance',
                            suffix: 'inches',
                            icon: Icons.straighten,
                          ),
                      ] else ...[
                        // Direct Sound Path input
                        _buildInputField(
                          controller: _soundPathController,
                          label: 'Sound Path (S)',
                          hint: 'Enter sound path length',
                          suffix: 'distance',
                          icon: Icons.trending_up,
                        ),
                      ],
                    ],

                    // Mode B: TOF → Sound Path
                    if (!_isModeA)
                      _buildInputField(
                        controller: _tofController,
                        label: 'Time-of-Flight (TOF)',
                        hint: 'Enter TOF',
                        suffix: 'seconds',
                        icon: Icons.timer,
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
              if (_resultTof != null) ...[
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

                      // Primary results
                      if (_isModeA) ...[
                        // TOF results (seconds and microseconds)
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
                                'Time-of-Flight',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_resultTof!.toStringAsFixed(6)} sec',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: _accentPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_resultTofMicroseconds!.toStringAsFixed(2)} μs',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_useAngleMode && _computedDepth != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _bgElevated,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                _buildResultRow('Sound Path (Computed)', '${_resultSoundPath!.toStringAsFixed(3)}"'),
                                Divider(height: 20, color: Colors.white.withOpacity(0.1)),
                                _buildResultRow('Depth', '${_computedDepth!.toStringAsFixed(3)}"'),
                                Divider(height: 20, color: Colors.white.withOpacity(0.1)),
                                _buildResultRow('Surface Distance', '${_computedSurfaceDistance!.toStringAsFixed(3)}"'),
                              ],
                            ),
                          ),
                        ],
                      ] else ...[
                        // Sound Path result
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
                                'Sound Path',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_resultSoundPath!.toStringAsFixed(3)} distance units',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: _accentPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _bgElevated,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildResultRow('Time-of-Flight', '${_resultTof!.toStringAsFixed(6)} sec'),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('', style: TextStyle(color: _textSecondary, fontSize: 14)),
                                  Text(
                                    '${_resultTofMicroseconds!.toStringAsFixed(2)} μs',
                                    style: TextStyle(color: _textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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
                      'Calculates ultrasonic wave travel time using sound path distance and wave velocity. Essential for UT timing calibrations and beam path verification.',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Core Formulas:',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '• TOF = S / V (seconds)\n'
                      '• TOF (μs) = TOF × 1,000,000\n'
                      '• S = TOF × V\n\n'
                      'Angle Mode (Optional):\n'
                      '• S = D / cos(θ)  [Given Depth]\n'
                      '• S = SD / sin(θ)  [Given Surface Distance]',
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
