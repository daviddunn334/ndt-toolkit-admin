import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/beam_plot_model.dart';
import '../calculators/beam_plot_math.dart';
import '../widgets/beam_plot_painter.dart';
import '../services/analytics_service.dart';

class BeamPlotVisualizerScreen extends StatefulWidget {
  const BeamPlotVisualizerScreen({super.key});

  @override
  State<BeamPlotVisualizerScreen> createState() => _BeamPlotVisualizerScreenState();
}

class _BeamPlotVisualizerScreenState extends State<BeamPlotVisualizerScreen> {
  // Part / Beam controllers
  final TextEditingController _angleController = TextEditingController(text: '45');
  final TextEditingController _thicknessController = TextEditingController(text: '10');
  int _legs = 3;

  // Cursor controllers
  bool _showCursor = false;
  final TextEditingController _surfaceDistanceController = TextEditingController();

  // Aperture mode
  bool _computeApertureFromElements = true;
  final TextEditingController _activeElementsController = TextEditingController(text: '16');
  final TextEditingController _pitchController = TextEditingController(text: '0.6');
  final TextEditingController _elementWidthController = TextEditingController(text: '0.5');
  final TextEditingController _apertureDirectController = TextEditingController();

  // Wave properties
  final TextEditingController _frequencyController = TextEditingController(text: '5');
  final TextEditingController _velocityController = TextEditingController(text: '5900');

  // Overlays
  bool _showNearField = false;
  bool _showDivergence = false;
  double _zoom = 1.0;

  // Results
  BeamPlotOutputs? _outputs;
  BeamPlotGeometry? _geometry;

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
    _angleController.dispose();
    _thicknessController.dispose();
    _surfaceDistanceController.dispose();
    _activeElementsController.dispose();
    _pitchController.dispose();
    _elementWidthController.dispose();
    _apertureDirectController.dispose();
    _frequencyController.dispose();
    _velocityController.dispose();
    super.dispose();
  }

  void _calculate() {
    try {
      final angle = double.tryParse(_angleController.text) ?? 0;
      final thickness = double.tryParse(_thicknessController.text) ?? 0;
      final surfaceDistance = double.tryParse(_surfaceDistanceController.text) ?? 0;
      
      final activeElements = int.tryParse(_activeElementsController.text) ?? 1;
      final pitch = double.tryParse(_pitchController.text) ?? 0;
      final elementWidth = double.tryParse(_elementWidthController.text) ?? 0;
      final apertureDirect = double.tryParse(_apertureDirectController.text) ?? 0;
      
      final frequency = double.tryParse(_frequencyController.text) ?? 0;
      final velocity = double.tryParse(_velocityController.text) ?? 0;

      final inputs = BeamPlotInputs(
        probeAngle: angle,
        thickness: thickness,
        legs: _legs,
        showCursor: _showCursor,
        surfaceDistance: surfaceDistance,
        computeApertureFromElements: _computeApertureFromElements,
        activeElements: activeElements,
        pitch: pitch,
        elementWidth: elementWidth,
        apertureDirect: apertureDirect,
        frequency: frequency,
        velocity: velocity,
        showNearField: _showNearField,
        showDivergence: _showDivergence,
        zoom: _zoom,
      );

      final outputs = BeamPlotMath.calculateOutputs(inputs);
      final geometry = BeamPlotMath.generateGeometry(inputs, outputs);

      setState(() {
        _outputs = outputs;
        _geometry = geometry;
      });

      // Log analytics if valid
      if (outputs.validInputs) {
        AnalyticsService().logCalculatorUsed(
          'Dynamic Beam Plot Visualizer',
          inputValues: {
            'angle': angle,
            'thickness': thickness,
            'legs': _legs,
            'half_skip': outputs.halfSkip,
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
                '📊 Dynamic Beam Plot Visualizer',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'UT/PAUT Beam Geometry Visualization',
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
              Icon(Icons.visibility, color: _accentPrimary, size: 22),
              const SizedBox(width: 12),
              Text(
                'Beam Plot',
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
                      painter: BeamPlotPainter(
                        inputs: BeamPlotInputs(
                          probeAngle: double.tryParse(_angleController.text) ?? 0,
                          thickness: double.tryParse(_thicknessController.text) ?? 0,
                          legs: _legs,
                          showCursor: _showCursor,
                          surfaceDistance: double.tryParse(_surfaceDistanceController.text) ?? 0,
                          computeApertureFromElements: _computeApertureFromElements,
                          activeElements: int.tryParse(_activeElementsController.text) ?? 1,
                          pitch: double.tryParse(_pitchController.text) ?? 0,
                          elementWidth: double.tryParse(_elementWidthController.text) ?? 0,
                          apertureDirect: double.tryParse(_apertureDirectController.text) ?? 0,
                          frequency: double.tryParse(_frequencyController.text) ?? 0,
                          velocity: double.tryParse(_velocityController.text) ?? 0,
                          showNearField: _showNearField,
                          showDivergence: _showDivergence,
                          zoom: _zoom,
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
              _buildLegendItem('Beam Path', _accentPrimary),
              if (_showNearField) _buildLegendItem('Near Field', _accentSuccess),
              if (_showDivergence) _buildLegendItem('Divergence', _accentYellow),
              if (_showCursor) _buildLegendItem('Cursor', _accentAlert),
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
            'Part / Beam',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _angleController,
            label: 'Probe Angle (θ)',
            hint: '1-89',
            suffix: 'deg',
            icon: Icons.rotate_right,
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
          
          // Cursor section
          Row(
            children: [
              Text(
                'Cursor',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const Spacer(),
              Switch(
                value: _showCursor,
                activeColor: _accentPrimary,
                onChanged: (value) {
                  setState(() {
                    _showCursor = value;
                    _calculate();
                  });
                },
              ),
            ],
          ),
          if (_showCursor) ...[
            const SizedBox(height: 16),
            _buildInputField(
              controller: _surfaceDistanceController,
              label: 'Surface Distance (SD)',
              hint: 'Enter distance',
              suffix: 'units',
              icon: Icons.straighten,
            ),
          ],
          
          const SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 24),
          
          // Aperture section
          Text(
            'Aperture / Wave',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildModeButton(
                  'Compute n/e/a',
                  _computeApertureFromElements,
                  () {
                    setState(() {
                      _computeApertureFromElements = true;
                      _calculate();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModeButton(
                  'Enter D',
                  !_computeApertureFromElements,
                  () {
                    setState(() {
                      _computeApertureFromElements = false;
                      _calculate();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_computeApertureFromElements) ...[
            _buildInputField(
              controller: _activeElementsController,
              label: 'Active Elements (n)',
              hint: 'Enter elements',
              suffix: 'elem',
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
              hint: 'Enter width',
              suffix: 'units',
              icon: Icons.width_normal,
            ),
          ] else ...[
            _buildInputField(
              controller: _apertureDirectController,
              label: 'Aperture (D)',
              hint: 'Enter aperture',
              suffix: 'units',
              icon: Icons.open_in_full,
            ),
          ],
          
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
            hint: 'Enter velocity',
            suffix: 'dist/sec',
            icon: Icons.speed,
          ),
          
          const SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 24),
          
          // Overlays
          Text(
            'Overlays',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: Text(
                    'Near Field',
                    style: TextStyle(color: _textSecondary, fontSize: 14),
                  ),
                  value: _showNearField,
                  activeColor: _accentSuccess,
                  onChanged: (value) {
                    setState(() {
                      _showNearField = value ?? false;
                      _calculate();
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: Text(
                    'Divergence',
                    style: TextStyle(color: _textSecondary, fontSize: 14),
                  ),
                  value: _showDivergence,
                  activeColor: _accentYellow,
                  onChanged: (value) {
                    setState(() {
                      _showDivergence = value ?? false;
                      _calculate();
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            ],
          ),
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
          _buildResultRow('Half Skip (HS)', _outputs!.halfSkip.toStringAsFixed(3)),
          const SizedBox(height: 12),
          _buildResultRow('Full Skip (FS)', _outputs!.fullSkip.toStringAsFixed(3)),
          const SizedBox(height: 12),
          _buildResultRow('Aperture (D)', _outputs!.aperture.toStringAsFixed(3)),
          
          if (_outputs!.wavelength > 0) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            _buildResultRow('Wavelength (λ)', _outputs!.wavelength.toStringAsFixed(4)),
            const SizedBox(height: 12),
            _buildResultRow('Near Field (N)', _outputs!.nearFieldLength.toStringAsFixed(3)),
            const SizedBox(height: 12),
            _buildResultRow('Divergence (α)', '${_outputs!.divergenceAngle.toStringAsFixed(2)}°'),
          ],
          
          if (_showCursor && _outputs!.cursorDepth != null) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text(
              'Cursor Position',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _accentAlert,
              ),
            ),
            const SizedBox(height: 12),
            _buildResultRow('Leg', _outputs!.cursorLeg.toString()),
            const SizedBox(height: 12),
            _buildResultRow('Depth', _outputs!.cursorDepth!.toStringAsFixed(3)),
            const SizedBox(height: 12),
            _buildResultRow('Leg Distance (p)', _outputs!.cursorP!.toStringAsFixed(3)),
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
            'This tool visualizes UT/PAUT beam geometry in a 2D plate cross-section. '
            'It shows the beam path centerline, multiple reflection legs, and optional overlays for near field zone and beam divergence.',
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
            'HS = T × tan(θ)\n'
            'FS = 2 × HS\n'
            'D = (n - 1) × e + a  [if computing from elements]\n'
            'N = (D² × f) / (4 × V)\n'
            'α = arcsin(0.61 × λ / D)',
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

  Widget _buildModeButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
            fontSize: 12,
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
}
