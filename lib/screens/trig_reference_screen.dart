import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/analytics_service.dart';
import '../services/trig_reference_service.dart';

class TrigReferenceScreen extends StatefulWidget {
  const TrigReferenceScreen({super.key});

  @override
  State<TrigReferenceScreen> createState() => _TrigReferenceScreenState();
}

class _TrigReferenceScreenState extends State<TrigReferenceScreen> {
  final TextEditingController _angleController = TextEditingController();

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

  bool _isDegrees = true;
  bool _extendedRange = false;
  bool _showAdvanced = true;
  int _decimalPlaces = 6;
  double _sliderValue = 45.0;

  // Results
  Map<String, dynamic>? _results;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _angleController.text = '45';
    _calculate();
  }

  @override
  void dispose() {
    _angleController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _errorMessage = null;
      _results = null;
    });

    if (_angleController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an angle';
      });
      return;
    }

    try {
      final angle = double.parse(_angleController.text);
      
      final results = TrigReferenceService.calculateTrigFunctions(
        angle: angle,
        isDegrees: _isDegrees,
      );

      setState(() {
        _results = results;
      });

      // Log analytics
      AnalyticsService().logCalculatorUsed(
        'Trig Reference Tool',
        inputValues: {
          'angle': angle,
          'unit': _isDegrees ? 'degrees' : 'radians',
          'sin': results['sin'],
          'cos': results['cos'],
          'tan': results['tan'],
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Please enter a valid number';
      });
    }
  }

  void _updateFromSlider(double value) {
    setState(() {
      _sliderValue = value;
      _angleController.text = value.toStringAsFixed(_isDegrees ? 1 : 4);
      _calculate();
    });
  }

  void _toggleUnit() {
    setState(() {
      _isDegrees = !_isDegrees;
      
      // Convert current angle to new unit
      if (_angleController.text.isNotEmpty) {
        try {
          final currentAngle = double.parse(_angleController.text);
          final convertedAngle = _isDegrees
              ? TrigReferenceService.radiansToDegrees(currentAngle)
              : TrigReferenceService.degreesToRadians(currentAngle);
          
          _angleController.text = convertedAngle.toStringAsFixed(_isDegrees ? 1 : 4);
          _sliderValue = _isDegrees ? 45.0 : pi / 4;
        } catch (e) {
          // If conversion fails, reset to default
          _angleController.text = _isDegrees ? '45' : '0.7854';
          _sliderValue = _isDegrees ? 45.0 : pi / 4;
        }
      }
      
      _calculate();
    });
  }

  void _copyToClipboard(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied: $value'),
        duration: const Duration(seconds: 2),
        backgroundColor: _accentSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double maxSlider = _isDegrees 
        ? (_extendedRange ? 360.0 : 90.0)
        : (_extendedRange ? 2 * pi : pi / 2);

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
                          '📐 Trig Quick Tool',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sin/Cos/Tan Reference Calculator',
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

              // Settings Row
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
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildToggleButton(
                            'Degrees',
                            _isDegrees,
                            _toggleUnit,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildToggleButton(
                            'Radians',
                            !_isDegrees,
                            _toggleUnit,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.straighten, color: _textSecondary, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Extended Range',
                              style: TextStyle(
                                fontSize: 14,
                                color: _textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _extendedRange,
                          onChanged: (value) {
                            setState(() {
                              _extendedRange = value;
                              if (_sliderValue > maxSlider) {
                                _sliderValue = maxSlider;
                                _angleController.text = _sliderValue.toStringAsFixed(_isDegrees ? 1 : 4);
                                _calculate();
                              }
                            });
                          },
                          activeColor: _accentPrimary,
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
                      'Angle Input',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Text input
                    TextField(
                      controller: _angleController,
                      style: TextStyle(color: _textPrimary, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Enter angle',
                        hintStyle: TextStyle(color: _textMuted),
                        suffixText: _isDegrees ? '°' : 'rad',
                        suffixStyle: TextStyle(color: _textSecondary),
                        prefixIcon: Icon(Icons.architecture, color: _textSecondary, size: 20),
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
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 20),
                    
                    // Slider
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Quick Select',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _textSecondary,
                              ),
                            ),
                            Text(
                              _isDegrees
                                  ? '0° - ${_extendedRange ? "360" : "90"}°'
                                  : '0 - ${_extendedRange ? "2π" : "π/2"}',
                              style: TextStyle(
                                fontSize: 12,
                                color: _textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: _accentPrimary,
                            inactiveTrackColor: _bgElevated,
                            thumbColor: _accentPrimary,
                            overlayColor: _accentPrimary.withOpacity(0.2),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: _sliderValue.clamp(0.0, maxSlider),
                            min: 0,
                            max: maxSlider,
                            divisions: _isDegrees ? (_extendedRange ? 360 : 90) : 100,
                            onChanged: _updateFromSlider,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Decimal places selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Decimal Places',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _textSecondary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: _bgElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: DropdownButton<int>(
                            value: _decimalPlaces,
                            dropdownColor: _bgCard,
                            underline: const SizedBox(),
                            style: TextStyle(color: _textPrimary, fontSize: 14),
                            items: [2, 4, 6, 8].map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _decimalPlaces = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ],
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

              // Results - Primary Functions
              if (_results != null) ...[
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
                          Icon(Icons.functions, color: _accentPrimary, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Primary Functions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildResultRow(
                        'sin(θ)',
                        TrigReferenceService.formatValue(_results!['sin'], _decimalPlaces),
                        _results!['sin'],
                      ),
                      const SizedBox(height: 12),
                      _buildResultRow(
                        'cos(θ)',
                        TrigReferenceService.formatValue(_results!['cos'], _decimalPlaces),
                        _results!['cos'],
                      ),
                      const SizedBox(height: 12),
                      _buildResultRow(
                        'tan(θ)',
                        _results!['tanWarning'] != null 
                            ? 'undefined'
                            : TrigReferenceService.formatValue(_results!['tan'], _decimalPlaces),
                        _results!['tan'],
                        warning: _results!['tanWarning'],
                      ),
                      if (_results!['complementAngle'] != null) ...[
                        const SizedBox(height: 16),
                        Divider(color: Colors.white.withOpacity(0.1)),
                        const SizedBox(height: 16),
                        _buildResultRow(
                          'Complement (90° - θ)',
                          _isDegrees
                              ? '${_results!['complementAngle'].toStringAsFixed(2)}°'
                              : '${_results!['complementAngle'].toStringAsFixed(4)} rad',
                          _results!['complementAngle'],
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // Advanced Functions (Optional)
              if (_results != null && _showAdvanced) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _accentSuccess.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calculate, color: _accentSuccess, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                'Reciprocal Functions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _textPrimary,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(
                              _showAdvanced ? Icons.visibility : Icons.visibility_off,
                              color: _textSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _showAdvanced = !_showAdvanced;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildResultRow(
                        'cot(θ) = 1/tan',
                        _results!['cotWarning'] != null 
                            ? 'undefined'
                            : TrigReferenceService.formatValue(_results!['cot'], _decimalPlaces),
                        _results!['cot'],
                        warning: _results!['cotWarning'],
                      ),
                      const SizedBox(height: 12),
                      _buildResultRow(
                        'sec(θ) = 1/cos',
                        _results!['secWarning'] != null 
                            ? 'undefined'
                            : TrigReferenceService.formatValue(_results!['sec'], _decimalPlaces),
                        _results!['sec'],
                        warning: _results!['secWarning'],
                      ),
                      const SizedBox(height: 12),
                      _buildResultRow(
                        'csc(θ) = 1/sin',
                        _results!['cscWarning'] != null 
                            ? 'undefined'
                            : TrigReferenceService.formatValue(_results!['csc'], _decimalPlaces),
                        _results!['csc'],
                        warning: _results!['cscWarning'],
                      ),
                    ],
                  ),
                ),
              ],

              // Quick Reference Table
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
                        Icon(Icons.table_chart, color: _accentYellow, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Common Angles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCommonAnglesTable(),
                  ],
                ),
              ),

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
                          'Quick Reference',
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
                      'Trigonometric functions relate angles to side ratios in right triangles. '
                      'This tool provides instant calculations for field use in NDT applications '
                      'including beam path calculations, angle corrections, and geometric measurements.',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Key Formulas:\n'
                      '• Conversion: radians = degrees × (π/180)\n'
                      '• Reciprocals: cot = 1/tan, sec = 1/cos, csc = 1/sin\n'
                      '• Complement: For angle θ, complement = 90° - θ',
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

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
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
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, double? numericValue, {String? warning}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: value == 'undefined' ? _accentAlert : _textPrimary,
                    fontSize: 18,
                  ),
                ),
                if (value != 'undefined' && numericValue != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.copy, size: 16, color: _textSecondary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _copyToClipboard(label, value),
                  ),
                ],
              ],
            ),
          ],
        ),
        if (warning != null) ...[
          const SizedBox(height: 4),
          Text(
            warning,
            style: TextStyle(
              fontSize: 11,
              color: _accentAlert,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ],
    );
  }

  Widget _buildCommonAnglesTable() {
    final commonAngles = TrigReferenceService.getCommonAngles(isDegrees: _isDegrees);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        headingRowColor: WidgetStateProperty.all(_bgElevated),
        dataRowColor: WidgetStateProperty.all(Colors.transparent),
        border: TableBorder.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
        columns: [
          DataColumn(
            label: Text(
              'Angle',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'sin',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'cos',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'tan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ],
        rows: commonAngles.map((angleData) {
          return DataRow(
            cells: [
              DataCell(
                Text(
                  angleData['angleDisplay'],
                  style: TextStyle(color: _textSecondary, fontSize: 12),
                ),
              ),
              DataCell(
                Text(
                  TrigReferenceService.formatValue(angleData['sin'], 4),
                  style: TextStyle(color: _textPrimary, fontSize: 12),
                ),
              ),
              DataCell(
                Text(
                  TrigReferenceService.formatValue(angleData['cos'], 4),
                  style: TextStyle(color: _textPrimary, fontSize: 12),
                ),
              ),
              DataCell(
                Text(
                  angleData['tanWarning'] != null 
                      ? '∞' 
                      : TrigReferenceService.formatValue(angleData['tan'], 4),
                  style: TextStyle(
                    color: angleData['tanWarning'] != null ? _accentAlert : _textPrimary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
