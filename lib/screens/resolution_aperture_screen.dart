import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/resolution_aperture_models.dart';
import '../calculators/resolution_aperture_math.dart';
import '../widgets/resolution_aperture_chart.dart';
import '../services/analytics_service.dart';

class ResolutionApertureScreen extends StatefulWidget {
  const ResolutionApertureScreen({super.key});

  @override
  State<ResolutionApertureScreen> createState() => _ResolutionApertureScreenState();
}

class _ResolutionApertureScreenState extends State<ResolutionApertureScreen> {
  // Input controllers
  final TextEditingController _pitchController = TextEditingController(text: '0.6');
  final TextEditingController _elementWidthController = TextEditingController(text: '0.5');
  final TextEditingController _maxElementsController = TextEditingController(text: '32');
  final TextEditingController _frequencyController = TextEditingController(text: '5.0');
  final TextEditingController _velocityController = TextEditingController(text: '5900');
  final TextEditingController _depthController = TextEditingController(text: '50');

  // Toggle states
  bool _showDivergence = true;
  bool _showBeamwidth = true;

  // Results
  ResolutionApertureOutputs? _outputs;
  AperturePoint? _selectedPoint;

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
    _pitchController.dispose();
    _elementWidthController.dispose();
    _maxElementsController.dispose();
    _frequencyController.dispose();
    _velocityController.dispose();
    _depthController.dispose();
    super.dispose();
  }

  void _calculate() {
    try {
      final pitch = double.tryParse(_pitchController.text) ?? 0;
      final elementWidth = double.tryParse(_elementWidthController.text) ?? 0;
      final maxElements = int.tryParse(_maxElementsController.text) ?? 0;
      final frequency = double.tryParse(_frequencyController.text) ?? 0;
      final velocity = double.tryParse(_velocityController.text) ?? 0;
      final depth = double.tryParse(_depthController.text) ?? 0;

      final inputs = ResolutionApertureInputs(
        pitch: pitch,
        elementWidth: elementWidth,
        maxElements: maxElements,
        frequency: frequency,
        velocity: velocity,
        depth: depth,
        showDivergence: _showDivergence,
        showBeamwidth: _showBeamwidth,
      );

      final outputs = ResolutionApertureMath.calculate(inputs);

      setState(() {
        _outputs = outputs;
      });

      // Log analytics if valid
      if (outputs.validInputs) {
        AnalyticsService().logCalculatorUsed(
          'Resolution vs Aperture Graph',
          inputValues: {
            'pitch': pitch,
            'element_width': elementWidth,
            'max_elements': maxElements,
            'frequency': frequency,
            'depth': depth,
          },
        );
      }
    } catch (e) {
      // Handle error silently
    }
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
          _buildInputsCard(),
          const SizedBox(height: 24),
          _buildComputedValuesCard(),
          const SizedBox(height: 24),
          _buildChartCard(),
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
                child: _buildChartCard(),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildInputsCard(),
                    const SizedBox(height: 24),
                    _buildComputedValuesCard(),
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
                '📊 Resolution vs Aperture',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PAUT Visualization Tool',
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
            'Array Geometry',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _pitchController,
            label: 'Pitch (e)',
            hint: 'Element pitch',
            suffix: 'units',
            icon: Icons.straighten,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _elementWidthController,
            label: 'Element Width (a)',
            hint: 'Width per element',
            suffix: 'units',
            icon: Icons.width_normal,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _maxElementsController,
            label: 'Max Active Elements (Nmax)',
            hint: '1-128',
            suffix: 'elem',
            icon: Icons.grid_4x4,
            isInteger: true,
          ),
          
          const SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 24),
          
          Text(
            'Wave Properties',
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
            label: 'Velocity (V)',
            hint: 'Sound velocity',
            suffix: 'units/s',
            icon: Icons.speed,
          ),
          
          const SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 24),
          
          Text(
            'Resolution Depth',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _depthController,
            label: 'Depth (z)',
            hint: 'Measurement depth',
            suffix: 'units',
            icon: Icons.vertical_align_center,
          ),
          
          const SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 24),
          
          Text(
            'Graph Options',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: Text(
              'Show Divergence Angle (α°)',
              style: TextStyle(color: _textSecondary, fontSize: 14),
            ),
            value: _showDivergence,
            activeColor: _accentYellow,
            onChanged: (value) {
              setState(() {
                _showDivergence = value ?? true;
              });
            },
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: Text(
              'Show Beamwidth at Depth (W)',
              style: TextStyle(color: _textSecondary, fontSize: 14),
            ),
            value: _showBeamwidth,
            activeColor: _accentPrimary,
            onChanged: (value) {
              setState(() {
                _showBeamwidth = value ?? true;
              });
            },
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  Widget _buildComputedValuesCard() {
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
                'Computed Values',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildResultRow('Wavelength (λ)', _formatScientific(_outputs!.wavelength)),
          const SizedBox(height: 12),
          _buildResultRow('Data Points', '${_outputs!.dataPoints.length}'),
          
          if (_selectedPoint != null) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text(
              'Selected Point',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _accentAlert,
              ),
            ),
            const SizedBox(height: 12),
            _buildResultRow('Elements (n)', '${_selectedPoint!.n}'),
            const SizedBox(height: 12),
            _buildResultRow('Aperture (D)', _selectedPoint!.D.toStringAsFixed(3)),
            const SizedBox(height: 12),
            _buildResultRow('Divergence (α)', '${_selectedPoint!.alphaDeg.toStringAsFixed(2)}°'),
            const SizedBox(height: 12),
            _buildResultRow('Beamwidth (W)', _selectedPoint!.beamWidth.toStringAsFixed(3)),
          ],
        ],
      ),
    );
  }

  Widget _buildChartCard() {
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
              Icon(Icons.show_chart, color: _accentPrimary, size: 22),
              const SizedBox(width: 12),
              Text(
                'Resolution vs Aperture Graph',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
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
              child: _outputs != null
                  ? ResolutionApertureChart(
                      outputs: _outputs!,
                      showBeamwidth: _showBeamwidth,
                      showDivergence: _showDivergence,
                      onPointSelected: (point) {
                        setState(() {
                          _selectedPoint = point;
                        });
                      },
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
              if (_showBeamwidth) _buildLegendItem('Beamwidth (W)', _accentPrimary),
              if (_showDivergence) _buildLegendItem('Divergence (α°)', _accentYellow),
              if (_selectedPoint != null) _buildLegendItem('Selected', _accentAlert),
            ],
          ),
          if (_outputs != null && _outputs!.validInputs) ...[
            const SizedBox(height: 16),
            Text(
              'Tap or drag on the chart to see values at any point',
              style: TextStyle(
                fontSize: 12,
                color: _textMuted,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
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
            'This tool visualizes how changing the active aperture affects beam divergence and lateral resolution '
            '(beamwidth) at a chosen depth. The graph sweeps from 1 to Nmax elements, computing aperture size, '
            'divergence angle, and beamwidth for each configuration.',
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
            'D(n) = (n - 1) × e + a\n'
            'λ = V / (f × 10⁶)\n'
            'α = arcsin(0.61 × λ / D)\n'
            'W = 2 × z × tan(α)',
            style: TextStyle(
              color: Colors.blue.shade900,
              fontSize: 12,
              height: 1.5,
              fontFamily: 'monospace',
            ),
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
          keyboardType: isInteger 
              ? TextInputType.number 
              : const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: isInteger
              ? [FilteringTextInputFormatter.digitsOnly]
              : [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
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

  String _formatScientific(double value) {
    if (value == 0) return '0';
    if (value >= 0.0001 && value < 10000) {
      return value.toStringAsFixed(4);
    }
    return value.toStringAsExponential(3);
  }
}
