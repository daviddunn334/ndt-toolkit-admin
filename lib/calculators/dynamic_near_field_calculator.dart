import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/analytics_service.dart';
import '../services/dynamic_near_field_service.dart';

class DynamicNearFieldCalculator extends StatefulWidget {
  const DynamicNearFieldCalculator({super.key});

  @override
  State<DynamicNearFieldCalculator> createState() => _DynamicNearFieldCalculatorState();
}

class _DynamicNearFieldCalculatorState extends State<DynamicNearFieldCalculator> {
  // Controllers for common inputs
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _velocityController = TextEditingController();
  
  // Controllers for Mode A (compute aperture from array)
  final TextEditingController _activeElementsController = TextEditingController();
  final TextEditingController _pitchController = TextEditingController();
  final TextEditingController _elementWidthController = TextEditingController();
  
  // Controller for Mode B (direct aperture entry)
  final TextEditingController _apertureController = TextEditingController();

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

  bool _computeApertureMode = true; // true = Mode A, false = Mode B
  
  // Results
  double? _aperture;
  double? _nearFieldLength;
  double? _wavelength;
  double? _ratio;
  String? _errorMessage;

  @override
  void dispose() {
    _frequencyController.dispose();
    _velocityController.dispose();
    _activeElementsController.dispose();
    _pitchController.dispose();
    _elementWidthController.dispose();
    _apertureController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _aperture = null;
      _nearFieldLength = null;
      _wavelength = null;
      _ratio = null;
    });

    // Validate common inputs
    if (_frequencyController.text.isEmpty || _velocityController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in frequency and velocity';
      });
      return;
    }

    try {
      final frequency = double.parse(_frequencyController.text);
      final velocity = double.parse(_velocityController.text);
      
      double aperture;

      if (_computeApertureMode) {
        // Mode A: Compute aperture from array parameters
        if (_activeElementsController.text.isEmpty || 
            _pitchController.text.isEmpty || 
            _elementWidthController.text.isEmpty) {
          setState(() {
            _errorMessage = 'Please fill in all array parameters';
          });
          return;
        }

        final activeElements = int.parse(_activeElementsController.text);
        final pitch = double.parse(_pitchController.text);
        final elementWidth = double.parse(_elementWidthController.text);

        // Calculate aperture from array
        final apertureResult = DynamicNearFieldService.calculateApertureFromArray(
          activeElements: activeElements,
          pitch: pitch,
          elementWidth: elementWidth,
        );

        if (apertureResult['error'] != null) {
          setState(() {
            _errorMessage = apertureResult['error'];
          });
          return;
        }

        aperture = apertureResult['aperture'];
      } else {
        // Mode B: Use direct aperture input
        if (_apertureController.text.isEmpty) {
          setState(() {
            _errorMessage = 'Please enter aperture value';
          });
          return;
        }

        aperture = double.parse(_apertureController.text);
        
        if (aperture <= 0) {
          setState(() {
            _errorMessage = 'Aperture must be greater than 0';
          });
          return;
        }
      }

      // Calculate near field
      final result = DynamicNearFieldService.calculateNearField(
        frequencyMHz: frequency,
        velocity: velocity,
        aperture: aperture,
      );

      if (result['error'] != null) {
        setState(() {
          _errorMessage = result['error'];
        });
        return;
      }

      setState(() {
        _aperture = aperture;
        _nearFieldLength = result['nearFieldLength'];
        _wavelength = result['wavelength'];
        _ratio = result['apertureToWavelengthRatio'];
      });

      // Log analytics
      AnalyticsService().logCalculatorUsed(
        'Dynamic Near Field Calculator',
        inputValues: {
          'mode': _computeApertureMode ? 'compute_aperture' : 'direct_aperture',
          'frequency_mhz': frequency,
          'velocity': velocity,
          'aperture': aperture,
          'near_field_length': _nearFieldLength,
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
      _aperture = null;
      _nearFieldLength = null;
      _wavelength = null;
      _ratio = null;
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
                          '📡 Dynamic Near Field Calculator',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'PAUT Fresnel Zone / Transition Point',
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
                    color: _accentPrimary.withOpacity(0.3),
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
                          color: _accentPrimary,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Aperture Input Mode',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _accentPrimary,
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
                            'Compute from n/e/a',
                            _computeApertureMode,
                            () {
                              setState(() {
                                _computeApertureMode = true;
                                _clearResults();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModeButton(
                            'Enter D directly',
                            !_computeApertureMode,
                            () {
                              setState(() {
                                _computeApertureMode = false;
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
                    Text(
                      'Common Parameters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _frequencyController,
                      label: 'Frequency (f)',
                      hint: 'Enter frequency',
                      suffix: 'MHz',
                      icon: Icons.graphic_eq,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _velocityController,
                      label: 'Wave Velocity (V)',
                      hint: 'Enter velocity',
                      suffix: 'distance/sec',
                      icon: Icons.speed,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ensure velocity is in distance/sec to match MHz→Hz conversion',
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontSize: 11,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Mode-specific inputs
                    if (_computeApertureMode) ...[
                      Text(
                        'Mode A: Array Parameters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _activeElementsController,
                        label: 'Active Elements (n)',
                        hint: 'Enter number of elements',
                        suffix: 'elements',
                        icon: Icons.grid_4x4,
                        isInteger: true,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _pitchController,
                        label: 'Pitch (e)',
                        hint: 'Enter pitch',
                        suffix: 'units',
                        icon: Icons.straighten,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _elementWidthController,
                        label: 'Element Width (a)',
                        hint: 'Enter element width',
                        suffix: 'units',
                        icon: Icons.width_normal,
                      ),
                    ] else ...[
                      Text(
                        'Mode B: Direct Aperture Entry',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _apertureController,
                        label: 'Aperture (D)',
                        hint: 'Enter aperture',
                        suffix: 'units',
                        icon: Icons.open_in_full,
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Calculate button
                    ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate, size: 20),
                      label: const Text(
                        'Calculate Near Field',
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
              if (_nearFieldLength != null) ...[
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
                      _buildResultRow('Aperture (D)', '${_aperture!.toStringAsFixed(3)} units'),
                      const SizedBox(height: 12),
                      _buildResultRow('Near Field Length (N)', '${_nearFieldLength!.toStringAsFixed(3)} units', isLarge: true),
                      const SizedBox(height: 16),
                      Divider(color: Colors.white.withOpacity(0.1)),
                      const SizedBox(height: 16),
                      _buildResultRow('Wavelength (λ)', '${_wavelength!.toStringAsFixed(3)} units'),
                      const SizedBox(height: 12),
                      _buildResultRow('D/λ Ratio', _ratio!.toStringAsFixed(3)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _accentSuccess.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _accentSuccess.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: _accentSuccess,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'The near field extends from the transducer to ${_nearFieldLength!.toStringAsFixed(3)} units',
                                style: TextStyle(
                                  color: _accentSuccess,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
                          'About Near Field Length',
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
                      'The near field (Fresnel zone) is the region closest to the transducer where the ultrasonic beam converges and interference patterns occur. Beyond this distance is the far field (Fraunhofer zone) where the beam begins to diverge predictably.',
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
                      'Frequency: f(Hz) = f(MHz) × 10⁶\n'
                      'Wavelength: λ = V / f\n'
                      'Near Field: N = (D² × f) / (4 × V)\n'
                      'Aperture (Mode A): D = (n - 1) × e + a',
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

  Widget _buildModeButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? _accentPrimary : _bgElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _accentPrimary : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : _textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
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
    bool isInteger = false,
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
          keyboardType: isInteger 
              ? TextInputType.number 
              : const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: isInteger
              ? [FilteringTextInputFormatter.digitsOnly]
              : [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
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
