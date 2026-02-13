import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/material_property.dart';
import '../data/material_properties_data.dart';
import '../theme/app_theme.dart';

class MaterialVelocityTableScreen extends StatefulWidget {
  const MaterialVelocityTableScreen({super.key});

  @override
  State<MaterialVelocityTableScreen> createState() => _MaterialVelocityTableScreenState();
}

class _MaterialVelocityTableScreenState extends State<MaterialVelocityTableScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  MaterialProperty? _selectedMaterial;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MaterialProperty> get _filteredMaterials {
    if (_searchQuery.isEmpty) {
      return materialPropertiesData;
    }

    return materialPropertiesData.where((material) {
      final name = material.name.toLowerCase();
      final description = material.description?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();

      return name.contains(query) || description.contains(query);
    }).toList();
  }

  void _copyToClipboard(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied: $value'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.secondaryAccent,
      ),
    );
  }

  String _formatValue(double? value, {int decimals = 2, String? unit}) {
    if (value == null) return 'N/A';
    final formatted = value.toStringAsFixed(decimals);
    return unit != null ? '$formatted $unit' : formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Material Properties – Velocity & Modulus'),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search materials...',
                hintStyle: const TextStyle(color: AppTheme.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.textMuted),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
            ),
          ),

          // Materials list
          Expanded(
            child: _filteredMaterials.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppTheme.textMuted.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No materials found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try a different search term',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredMaterials.length + 1, // +1 for disclaimer
                    itemBuilder: (context, index) {
                      if (index == _filteredMaterials.length) {
                        // Disclaimer at bottom
                        return Container(
                          margin: const EdgeInsets.only(top: 16, bottom: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.yellowAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.yellowAccent.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppTheme.yellowAccent,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Reference values only. Actual properties vary by composition, heat treatment, and temperature.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final material = _filteredMaterials[index];
                      return _buildMaterialCard(material);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(MaterialProperty material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedMaterial = material;
            });
            _showMaterialDetail(material);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Material name and icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getMaterialIcon(material),
                        size: 20,
                        color: AppTheme.primaryAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        material.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppTheme.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Key properties in compact view
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildCompactProperty(
                      'VL',
                      _formatValue(material.longitudinalVelocity, unit: 'm/s'),
                      Icons.trending_up,
                    ),
                    if (material.supportsShear)
                      _buildCompactProperty(
                        'VS',
                        _formatValue(material.shearVelocity, unit: 'm/s'),
                        Icons.swap_vert,
                      ),
                    _buildCompactProperty(
                      'ρ',
                      _formatValue(material.density, decimals: 0, unit: 'kg/m³'),
                      Icons.scatter_plot,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactProperty(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.secondaryAccent),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  IconData _getMaterialIcon(MaterialProperty material) {
    final name = material.name.toLowerCase();
    
    if (name.contains('steel') || name.contains('iron')) {
      return Icons.iron;
    } else if (name.contains('aluminum') || name.contains('titanium') || name.contains('magnesium')) {
      return Icons.flight;
    } else if (name.contains('water') || name.contains('oil') || name.contains('glycerin')) {
      return Icons.water_drop;
    } else if (name.contains('air')) {
      return Icons.air;
    } else if (name.contains('acrylic') || name.contains('plastic') || name.contains('polymer') || name.contains('rexolite')) {
      return Icons.layers;
    } else if (name.contains('glass') || name.contains('concrete') || name.contains('ceramic')) {
      return Icons.window;
    } else if (name.contains('fiber') || name.contains('composite')) {
      return Icons.texture;
    } else if (name.contains('rubber')) {
      return Icons.circle_outlined;
    } else {
      return Icons.category;
    }
  }

  void _showMaterialDetail(MaterialProperty material) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getMaterialIcon(material),
                              size: 24,
                              color: AppTheme.primaryAccent,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  material.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                if (material.description != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    material.description!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Velocity Section
                      _buildDetailSection(
                        'Wave Velocities',
                        Icons.waves,
                        AppTheme.secondaryAccent,
                        [
                          _buildDetailRow(
                            'Longitudinal Velocity (VL)',
                            _formatValue(material.longitudinalVelocity, decimals: 1, unit: 'm/s'),
                            material.longitudinalVelocity,
                          ),
                          if (material.supportsShear)
                            _buildDetailRow(
                              'Shear Velocity (VS)',
                              _formatValue(material.shearVelocity, decimals: 1, unit: 'm/s'),
                              material.shearVelocity,
                            )
                          else
                            _buildDetailRow(
                              'Shear Velocity (VS)',
                              'N/A (fluid/gas)',
                              null,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Mechanical Properties Section
                      _buildDetailSection(
                        'Mechanical Properties',
                        Icons.build,
                        AppTheme.primaryAccent,
                        [
                          _buildDetailRow(
                            'Density (ρ)',
                            _formatValue(material.density, decimals: 1, unit: 'kg/m³'),
                            material.density,
                          ),
                          _buildDetailRow(
                            'Young\'s Modulus (E)',
                            _formatValue(material.youngsModulus, decimals: 1, unit: 'GPa'),
                            material.youngsModulus,
                          ),
                          _buildDetailRow(
                            'Shear Modulus (G)',
                            _formatValue(material.shearModulus, decimals: 1, unit: 'GPa'),
                            material.shearModulus,
                          ),
                          _buildDetailRow(
                            'Poisson\'s Ratio (ν)',
                            _formatValue(material.poissonRatio, decimals: 3),
                            material.poissonRatio,
                          ),
                        ],
                      ),

                      // Derived velocities (if available)
                      if (material.canDeriveVelocities) ...[
                        const SizedBox(height: 16),
                        _buildDetailSection(
                          'Derived Values (Informational)',
                          Icons.calculate,
                          AppTheme.yellowAccent,
                          [
                            _buildDetailRow(
                              'Calculated VL from E, ρ, ν',
                              _formatValue(material.derivedLongitudinalVelocity, decimals: 1, unit: 'm/s'),
                              material.derivedLongitudinalVelocity,
                              subtitle: 'VL ≈ √[(E(1-ν))/(ρ(1+ν)(1-2ν))]',
                            ),
                            if (material.shearModulus != null && material.density != null)
                              _buildDetailRow(
                                'Calculated VS from G, ρ',
                                _formatValue(material.derivedShearVelocity, decimals: 1, unit: 'm/s'),
                                material.derivedShearVelocity,
                                subtitle: 'VS ≈ √(G/ρ)',
                              ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Action buttons
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryAccent.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: AppTheme.primaryAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Use these values in Snell\'s Law, TOF, or PAUT calculators',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildDetailSection(String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, double? numericValue, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: value == 'N/A' || value.contains('N/A') 
                          ? AppTheme.textMuted 
                          : AppTheme.textPrimary,
                    ),
                  ),
                  if (numericValue != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      color: AppTheme.textSecondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _copyToClipboard(label, numericValue.toString()),
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
