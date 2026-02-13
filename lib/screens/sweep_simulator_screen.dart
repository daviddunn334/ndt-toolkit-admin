import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/sweep_simulator_model.dart';
import '../calculators/sweep_simulator_math.dart';
import '../widgets/sweep_simulator_painter.dart';
import '../services/analytics_service.dart';

class SweepSimulatorScreen extends StatefulWidget {
  const SweepSimulatorScreen({super.key});

  @override
  State<SweepSimulatorScreen> createState() => _SweepSimulatorScreenState();
}

class _SweepSimulatorScreenState extends State<SweepSimulatorScreen> {
  // Part / Plot controllers
  final TextEditingController _thicknessController = TextEditingController(text: '10');
  int _legs = 3;
  double _zoom = 1.0;

  // Angle sweep controllers
  final TextEditingController _startAngleController = TextEditingController(text: '40');
  final TextEditingController _endAngleController = TextEditingController(text: '70');
  final TextEditingController _angleStepController = TextEditingController(text: '5');

  // Highlight
  bool _enableHighlight = false;
  double _highlightSliderValue = 0.5; // 0 to 1

  // Results
  SweepSimulatorOutputs? _outputs;
  SweepSimulatorGeometry? _geometry;

  // Colors
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

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _thicknessController.dispose();
    _startAngleController.dispose();
    _endAngleController.dispose();
    _angleStepController.dispose();
    super.dispose();
  }

  void _calculate() {
    try {
      final thickness = double.tryParse(_thicknessController.text) ?? 0;
      final startAngle = double.tryParse(_startAngleController.text) ?? 0;
      final endAngle = double.tryParse(_endAngleController.text) ?? 0;
      final angleStep = double.tryParse(_angleStepController.text) ?? 0;

      final inputs = SweepSimulatorInputs(
        thickness: thickness,
        legs: _legs,
        surfaceOriginX: 0,
        zoom: _zoom,
        startAngle: startAngle,
        endAngle: endAngle,
        angleStep: angleStep,
        highlightAngleIndex: _enableHighlight ? _getHighlightIndex() : null,
      );

      final outputs = SweepSimulatorMath.calculateOutputs(inputs);
      final geometry = SweepSimulatorMath.generateGeometry(inputs, outputs);

      setState(() {
        _outputs = outputs;
        _geometry = geometry;
      });

      // Log analytics if valid
      if (outputs.validInputs) {
        AnalyticsService().logCalculatorUsed(
          'Sweep Simulator',
          inputValues: {
            'thickness': thickness,
            'legs': _legs,
            'start_angle': startAngle,
            'end_angle': endAngle,
            'rays_count': outputs.raysCount,
          },
        );
      }
    } catch (e) {
      // Handle error silently
    }
  }

  int? _getHighlightIndex() {
    if (_outputs == null || !_outputs!.validInputs || _outputs!.angles.isEmpty) {
      return null;
    }
    final index = (_highlightSliderValue * (_outputs!.angles.length - 1)).round();
    return index.clamp(0, _outputs!.angles.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgMain,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 900;
            
            if (isMobile) {
              return _buildMobileLayout();
            } else {
              return _buildDesktopLayout();
            }
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildVisualizationCard(),
          const SizedBox(height: 24),
          _buildInputsCard(),
          const SizedBox(height: 24),
          _buildOutputsCard(),
          const SizedBox(height: 24),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildVisualizationCard(),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildInputsCard(),
                    const SizedBox(height: 24),
                    _buildOutputsCard(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
                '🌈 Sweep Simulator',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Multi-Angle Beam Coverage Visualization',
                style: TextStyle(
                  fontSize: 14,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVisualizationCard() {
    return Container(
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
          Row(
            children: [
              Icon(Icons.grid_on, color: _accentPrimary, size: 22),
              const SizedBox(width: 12),
              Text(
                'Sweep Coverage',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const Spacer(),
              // Zoom slider
              Icon(Icons.zoom_in, color: _textSecondary, size: 20),
              SizedBox(
                width: 120,
                child: Slider(
                  value: _zoom,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  activeColor: _accentPrimary,
                  onChanged: (value) {
                    setState(() {
                      _zoom = value;
                      _calculate();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: _bgElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: _outputs != null && _geometry != null
                  ? CustomPaint(
                      painter: SweepSimulatorPainter(
                        inputs: SweepSimulatorInputs(
                          thickness: double.tryParse(_thicknessController.text) ?? 0,
                          legs: _legs,
                          surfaceOriginX: 0,
                          zoom: _zoom,
                          startAngle: double.tryParse(_startAngleController.text) ?? 0,
                          endAngle: double.tryParse(_endAngleController.text) ?? 0,
                          angleStep: double.tryParse(_angleStepController.text) ?? 0,
                          highlightAngleIndex: _enableHighlight ? _getHighlightIndex() : null,
                        ),
                        outputs: _outputs!,
                        geometry: _geometry!,
                      ),
                    )
                  : Center(
                      child: Text(
                        'Enter valid inputs',
                        style: TextStyle(color: _textMuted),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem('All Rays', _accentPrimary.withOpacity(0.15)),
              if (_enableHighlight) _buildLegendItem('Highlighted', _accentPrimary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: _textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInputsCard() {
    return Container(
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
            'Part / Plot',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _thicknessController,
            label: 'Thickness (T)',
            hint: 'Enter thickness',
            suffix: 'units',
            icon: Icons.straighten,
          ),
          const SizedBox(height: 16),
          Text(
            'Legs to draw: $_legs',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _legs.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: _legs.toString(),
            activeColor: _accentPrimary,
            onChanged: (value) {
              setState(() {
                _legs = value.toInt();
                _calculate();
              });
            },
          ),
          
          const SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 24),
          
          // Angle sweep section
          Text(
            'Angle Sweep',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _startAngleController,
            label: 'Start Angle (θstart)',
            hint: '1-89',
            suffix: 'deg',
            icon: Icons.rotate_left,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _endAngleController,
            label: 'End Angle (θend)',
            hint: '1-89',
            suffix: 'deg',
            icon: Icons.rotate_right,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _angleStepController,
            label: 'Step (Δθ)',
            hint: 'e.g., 1, 2, 5',
            suffix: 'deg',
            icon: Icons.linear_scale,
          ),
          
          const SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 24),
          
          // Highlight section
          Row(
            children: [
              Text(
                'Highlight Angle',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const Spacer(),
              Switch(
                value: _enableHighlight,
                activeColor: _accentPrimary,
                onChanged: (value) {
                  setState(() {
                    _enableHighlight = value;
                    _calculate();
                  });
                },
              ),
            ],
          ),
          if (_enableHighlight && _outputs != null && _outputs!.validInputs) ...[
            const SizedBox(height: 16),
            Text(
              'Select angle: ${_outputs!.highlightedAngle?.toStringAsFixed(1) ?? "N/A"}°',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _highlightSliderValue,
              min: 0,
              max: 1,
              divisions: _outputs!.angles.length > 1 ? _outputs!.angles.length - 1 : 1,
              activeColor: _accentPrimary,
              onChanged: (value) {
                setState(() {
                  _highlightSliderValue = value;
                  _calculate();
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOutputsCard() {
    if (_outputs == null || !_outputs!.validInputs) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _accentAlert.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: _accentAlert, size: 32),
            const SizedBox(height: 12),
            Text(
              _outputs?.errorMessage ?? 'Enter valid inputs',
              style: TextStyle(
                color: _accentAlert,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
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
            children: [
              Icon(Icons.check_circle, color: _accentSuccess, size: 24),
              const SizedBox(width: 12),
              Text(
                'Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildResultRow('Rays Count', _outputs!.raysCount.toString()),
          const SizedBox(height: 12),
          _buildResultRow('Angle Range', '${_outputs!.angles.first.toStringAsFixed(1)}° - ${_outputs!.angles.last.toStringAsFixed(1)}°'),
          const SizedBox(height: 12),
          _buildResultRow('HS Range', '${_outputs!.minHalfSkip.toStringAsFixed(2)} - ${_outputs!.maxHalfSkip.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          _buildResultRow('Max Coverage', _outputs!.maxCoverageWidth.toStringAsFixed(2)),
          
          if (_enableHighlight && _outputs!.highlightedAngle != null) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text(
              'Highlighted Angle',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _accentPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildResultRow('Angle', '${_outputs!.highlightedAngle!.toStringAsFixed(1)}°'),
            const SizedBox(height: 12),
            _buildResultRow('Half Skip', _outputs!.highlightedHS!.toStringAsFixed(3)),
            const SizedBox(height: 12),
            _buildResultRow('Full Skip', _outputs!.highlightedFS!.toStringAsFixed(3)),
            const SizedBox(height: 12),
            _buildResultRow('Coverage', _outputs!.highlightedCoverage!.toStringAsFixed(3)),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
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
            'The Sweep Simulator visualizes multiple UT/PAUT beam paths at once across a range of steering angles. '
            'This helps you understand coverage patterns and optimize inspection parameters.',
            style: TextStyle(
              color: Colors.blue.shade900,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Key Features:',
            style: TextStyle(
              color: Colors.blue.shade900,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '• Visualize multiple angles simultaneously\n'
            '• See coverage envelope across angle range\n'
            '• Highlight specific angles for detailed analysis\n'
            '• Max 50 rays for optimal performance',
            style: TextStyle(
              color: Colors.blue.shade900,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
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
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(color: _textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _textMuted, fontSize: 13),
            suffixText: suffix,
            suffixStyle: TextStyle(color: _textSecondary, fontSize: 12),
            prefixIcon: Icon(icon, color: _textSecondary, size: 18),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            isDense: true,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          onChanged: (_) => _calculate(),
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
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: _textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _textPrimary,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
