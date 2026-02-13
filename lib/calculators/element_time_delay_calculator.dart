import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/analytics_service.dart';
import '../services/element_time_delay_service.dart';

class ElementTimeDelayCalculator extends StatefulWidget {
  const ElementTimeDelayCalculator({super.key});

  @override
  State<ElementTimeDelayCalculator> createState() => _ElementTimeDelayCalculatorState();
}

class _ElementTimeDelayCalculatorState extends State<ElementTimeDelayCalculator> {
  // Controllers
  final TextEditingController _steeringAngleController = TextEditingController();
  final TextEditingController _elementPitchController = TextEditingController();
  final TextEditingController _waveVelocityController = TextEditingController();
  final TextEditingController _activeElementsController = TextEditingController();

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
  static const Color _accentYellow = Color(0xFFF8B800);

  // Results
  double? _adjacentDelaySeconds;
  double? _adjacentDelayMicroseconds;
  double? _totalDelaySeconds;
  double? _totalDelayMicroseconds;
  double? _apertureLength;
  List<Map<String, dynamic>>? _elementDelays;
  String? _errorMessage;

  @override
  void dispose() {
    _steeringAngleController.dispose();
    _elementPitchController.dispose();
    _waveVelocityController.dispose();
    _activeElementsController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _adjacentDelaySeconds = null;
      _adjacentDelayMicroseconds = null;
      _totalDelaySeconds = null;
      _totalDelayMicroseconds = null;
      _apertureLength = null;
      _elementDelays = null;
    });

    // Validate inputs
    if (_steeringAngleController.text.isEmpty ||
        _elementPitchController.text.isEmpty ||
        _waveVelocityController.text.isEmpty ||
        _activeElementsController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    try {
      final steeringAngle = double.parse(_steeringAngleController.text);
      final elementPitch = double.parse(_elementPitchController.text);
      final waveVelocity = double.parse(_waveVelocityController.text);
      final activeElements = int.parse(_activeElementsController.text);

      // Calculate element time delays
      final result = ElementTimeDelayService.calculateElementTimeDelay(
        steeringAngleDeg: steeringAngle,
        elementPitch: elementPitch,
        waveVelocity: waveVelocity,
        activeElements: activeElements,
      );

      if (result['error'] != null) {
        setState(() {
          _errorMessage = result['error'];
        });
        return;
      }

      setState(() {
        _adjacentDelaySeconds = result['adjacentDelaySeconds'];
        _adjacentDelayMicroseconds = result['adjacentDelayMicroseconds'];
        _totalDelaySeconds = result['totalDelaySeconds'];
        _totalDelayMicroseconds = result['totalDelayMicroseconds'];
        _apertureLength = result['apertureLength'];
        _elementDelays = result['elementDelays'];
      });

      // Log analytics
      AnalyticsService().logCalculatorUsed(
        'Element Time Delay Calculator',
        inputValues: {
          'steering_angle_deg': steeringAngle,
          'element_pitch': elementPitch,
          'wave_velocity': waveVelocity,
          'active_elements': activeElements,
          'adjacent_delay_us': _adjacentDelayMicroseconds,
          'total_delay_us': _totalDelayMicroseconds,
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
      _adjacentDelaySeconds = null;
      _adjacentDelayMicroseconds = null;
      _totalDelaySeconds = null;
      _totalDelayMicroseconds = null;
      _apertureLength = null;
      _elementDelays = null;
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
                          '⏱️ Element Time Delay Calculator',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'PAUT Steering Delay Calculation',
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
                    Text(
                      'Steering Parameters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _steeringAngleController,
                      label: 'Steering Angle (θ)',
                      hint: 'Enter angle',
                      suffix: 'degrees',
                      icon: Icons.rotate_right,
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
                              'Valid range: -89° to +89° (negative = left, positive = right)',
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
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _elementPitchController,
                      label: 'Element Pitch (e)',
                      hint: 'Enter pitch',
                      suffix: 'distance',
                      icon: Icons.straighten,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _waveVelocityController,
                      label: 'Wave Velocity (V)',
                      hint: 'Enter velocity',
                      suffix: 'distance/sec',
                      icon: Icons.speed,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _activeElementsController,
                      label: 'Active Elements (n)',
                      hint: 'Enter number',
                      suffix: 'elements',
                      icon: Icons.grid_4x4,
                      isInteger: true,
                    ),
                    const SizedBox(height: 24),

                    // Calculate button
                    ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate, size: 20),
                      label: const Text(
                        'Calculate Time Delays',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentYellow,
                        foregroundColor: Colors.black,
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
              if (_adjacentDelayMicroseconds != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _accentYellow.withOpacity(0.3),
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
                      _buildResultRow(
                        'Adjacent Element Delay (Δt)',
                        '${_adjacentDelayMicroseconds!.toStringAsFixed(3)} µs',
                        isLarge: true,
                      ),
                      const SizedBox(height: 8),
                      _buildResultRow(
                        '  (in seconds)',
                        '${_adjacentDelaySeconds!.toStringAsExponential(3)} s',
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.white.withOpacity(0.1)),
                      const SizedBox(height: 16),
                      _buildResultRow(
                        'Total Delay Across Aperture',
                        '${_totalDelayMicroseconds!.toStringAsFixed(3)} µs',
                        isLarge: true,
                      ),
                      const SizedBox(height: 8),
                      _buildResultRow(
                        '  (${_activeElementsController.text} elements)',
                        '${_totalDelaySeconds!.toStringAsExponential(3)} s',
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.white.withOpacity(0.1)),
                      const SizedBox(height: 16),
                      _buildResultRow(
                        'Aperture Length (span)',
                        '${_apertureLength!.toStringAsFixed(3)} units',
                      ),
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
                                'Δt magnitude: ${_adjacentDelayMicroseconds!.abs().toStringAsFixed(3)} µs per element',
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

                // Element Delay Table
                if (_elementDelays != null && _elementDelays!.length <= 32) ...[
                  const SizedBox(height: 24),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Individual Element Delays',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: _bgElevated,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(2),
                            },
                            children: [
                              // Header row
                              TableRow(
                                decoration: BoxDecoration(
                                  color: _accentYellow.withOpacity(0.15),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                ),
                                children: [
                                  _buildTableCell('Element', isHeader: true),
                                  _buildTableCell('Delay (µs)', isHeader: true),
                                ],
                              ),
                              // Data rows
                              ..._elementDelays!.map((element) {
                                return TableRow(
                                  children: [
                                    _buildTableCell('#${element['index']}'),
                                    _buildTableCell(
                                      element['delayMicroseconds']
                                          .toStringAsFixed(3),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                          'About Element Time Delay',
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
                      'This calculator computes the time delay between adjacent elements required to electronically steer a phased-array beam to a desired angle in a uniform medium.',
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
                      'θ_rad = θ_deg × (π / 180)\n'
                      'Δt = (e × sin(θ_rad)) / V\n'
                      'Total Delay = (n - 1) × Δt\n'
                      'Aperture Length = (n - 1) × e\n'
                      'Element Delay[i] = i × Δt (for i = 0 to n-1)',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 12,
                        height: 1.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: Colors.orange.shade900,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Disclaimer: Ideal steering delay in a uniform medium; real instruments apply additional wedge/path corrections and focusing laws.',
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
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
              borderSide: BorderSide(color: _accentYellow, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          keyboardType: isInteger
              ? TextInputType.number
              : const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: isInteger
              ? [FilteringTextInputFormatter.digitsOnly]
              : [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
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
            color: isLarge ? _accentYellow : _textPrimary,
            fontSize: isLarge ? 20 : 16,
          ),
        ),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 13 : 14,
          fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
          color: isHeader ? _accentYellow : _textPrimary,
        ),
      ),
    );
  }
}
