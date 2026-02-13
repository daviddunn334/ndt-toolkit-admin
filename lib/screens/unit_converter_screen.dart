import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/units_registry.dart';
import '../services/unit_converter_service.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  // New Dark Color System
  static const Color _bgMain = Color(0xFF1E232A);
  static const Color _bgCard = Color(0xFF2A313B);
  static const Color _textPrimary = Color(0xFFEDF9FF);
  static const Color _textSecondary = Color(0xFFAEBBC8);
  static const Color _textMuted = Color(0xFF7F8A96);
  static const Color _accentPrimary = Color(0xFF6C5BFF);
  static const Color _accentSuccess = Color(0xFF00E5A8);
  static const Color _accentAlert = Color(0xFFFE637E);
  static const Color _accentYellow = Color(0xFFF8B800);

  // State
  UnitCategory _selectedCategory = UnitCategory.length;
  String? _fromUnitId;
  String? _toUnitId;
  final TextEditingController _inputController = TextEditingController();
  String _outputValue = '0';
  bool _isFavorite = false;
  int _decimalPlaces = 3;

  @override
  void initState() {
    super.initState();
    _loadLastUsed();
    _inputController.addListener(_performConversion);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _loadLastUsed() async {
    final categoryDef = UnitsRegistry.getCategoryDef(_selectedCategory);
    if (categoryDef != null && categoryDef.units.isNotEmpty) {
      setState(() {
        _fromUnitId = categoryDef.units.first.id;
        _toUnitId = categoryDef.units.length > 1
            ? categoryDef.units[1].id
            : categoryDef.units.first.id;
      });
      _checkFavorite();
    }
  }

  Future<void> _checkFavorite() async {
    if (_fromUnitId != null && _toUnitId != null) {
      final isFav = await UnitConverterService.isFavorite(
        category: _selectedCategory,
        fromUnitId: _fromUnitId!,
        toUnitId: _toUnitId!,
      );
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  void _performConversion() {
    final inputText = _inputController.text.trim();
    if (inputText.isEmpty) {
      setState(() {
        _outputValue = '0';
      });
      return;
    }

    final inputValue = UnitConverterService.parseInput(inputText);
    if (inputValue == null || _fromUnitId == null || _toUnitId == null) {
      setState(() {
        _outputValue = 'Invalid';
      });
      return;
    }

    final result = UnitConverterService.convert(
      value: inputValue,
      category: _selectedCategory,
      fromUnitId: _fromUnitId!,
      toUnitId: _toUnitId!,
    );

    if (result == null) {
      setState(() {
        _outputValue = 'Error';
      });
      return;
    }

    setState(() {
      _outputValue = UnitConverterService.formatValue(result, decimals: _decimalPlaces);
    });

    // Save last used
    UnitConverterService.saveLastUsed(
      category: _selectedCategory,
      fromUnitId: _fromUnitId!,
      toUnitId: _toUnitId!,
    );
  }

  void _swapUnits() {
    if (_fromUnitId == null || _toUnitId == null) return;

    setState(() {
      final temp = _fromUnitId;
      _fromUnitId = _toUnitId;
      _toUnitId = temp;
    });

    _performConversion();
    _checkFavorite();
  }

  void _toggleFavorite() async {
    if (_fromUnitId == null || _toUnitId == null) return;

    if (_isFavorite) {
      await UnitConverterService.removeFavorite(
        category: _selectedCategory,
        fromUnitId: _fromUnitId!,
        toUnitId: _toUnitId!,
      );
    } else {
      await UnitConverterService.saveFavorite(
        category: _selectedCategory,
        fromUnitId: _fromUnitId!,
        toUnitId: _toUnitId!,
      );
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void _copyResult() {
    Clipboard.setData(ClipboardData(text: _outputValue));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Copied: $_outputValue',
          style: const TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: _bgCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _useCommonPair(CommonPair pair) {
    setState(() {
      _fromUnitId = pair.fromUnitId;
      _toUnitId = pair.toUnitId;
    });
    _performConversion();
    _checkFavorite();
  }

  @override
  Widget build(BuildContext context) {
    final categoryDef = UnitsRegistry.getCategoryDef(_selectedCategory);

    return Scaffold(
      backgroundColor: _bgMain,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth <= 900;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  _buildHeader(context),
                  const SizedBox(height: 24),

                  // Category Selector
                  _buildCategorySelector(isMobile),
                  const SizedBox(height: 24),

                  // Converter Card
                  _buildConverterCard(categoryDef, isMobile),
                  const SizedBox(height: 20),

                  // Common Pairs (if available)
                  if (categoryDef?.commonPairs != null && categoryDef!.commonPairs!.isNotEmpty)
                    _buildCommonPairs(categoryDef.commonPairs!),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                'Unit Converter',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Comprehensive unit conversion for NDT work',
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

  Widget _buildCategorySelector(bool isMobile) {
    return Container(
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
              Text(
                'Category',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                _selectedCategory.icon,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: _bgMain,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: DropdownButton<UnitCategory>(
              value: _selectedCategory,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: _bgCard,
              style: TextStyle(
                color: _textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              icon: Icon(Icons.keyboard_arrow_down, color: _textSecondary),
              items: UnitCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text('${category.icon}  ${category.label}'),
                );
              }).toList(),
              onChanged: (newCategory) {
                if (newCategory != null) {
                  setState(() {
                    _selectedCategory = newCategory;
                    final categoryDef = UnitsRegistry.getCategoryDef(newCategory);
                    if (categoryDef != null && categoryDef.units.isNotEmpty) {
                      _fromUnitId = categoryDef.units.first.id;
                      _toUnitId = categoryDef.units.length > 1
                          ? categoryDef.units[1].id
                          : categoryDef.units.first.id;
                    }
                  });
                  _performConversion();
                  _checkFavorite();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConverterCard(UnitCategoryDef? categoryDef, bool isMobile) {
    if (categoryDef == null) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // From Section
          _buildInputSection(categoryDef, isMobile),
          const SizedBox(height: 20),

          // Swap Button
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: _accentPrimary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _accentPrimary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: Icon(Icons.swap_vert, color: _accentPrimary),
                onPressed: _swapUnits,
                tooltip: 'Swap units',
              ),
            ),
          ),
          const SizedBox(height: 20),

          // To Section
          _buildOutputSection(categoryDef, isMobile),
          const SizedBox(height: 20),

          // Actions Row
          Row(
            children: [
              // Decimal places selector
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _bgMain,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Decimals:',
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<int>(
                          value: _decimalPlaces,
                          underline: const SizedBox(),
                          dropdownColor: _bgCard,
                          isExpanded: true,
                          style: TextStyle(color: _textPrimary, fontSize: 12),
                          items: List.generate(7, (i) => i).map((i) {
                            return DropdownMenuItem(
                              value: i,
                              child: Text(i.toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _decimalPlaces = value;
                              });
                              _performConversion();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Copy button
              _buildActionButton(
                icon: Icons.copy,
                label: 'Copy',
                onPressed: _copyResult,
                color: _accentSuccess,
              ),
              const SizedBox(width: 12),
              // Favorite button
              _buildActionButton(
                icon: _isFavorite ? Icons.star : Icons.star_border,
                label: _isFavorite ? 'Saved' : 'Save',
                onPressed: _toggleFavorite,
                color: _accentYellow,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(UnitCategoryDef categoryDef, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FROM',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textMuted,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _inputController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter value',
                  hintStyle: TextStyle(color: _textMuted),
                  filled: true,
                  fillColor: _bgMain,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _accentPrimary.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _bgMain,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                ),
                child: DropdownButton<String>(
                  value: _fromUnitId,
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: _bgCard,
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  items: categoryDef.units.map((unit) {
                    return DropdownMenuItem(
                      value: unit.id,
                      child: Text(unit.displayLabel),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _fromUnitId = value;
                    });
                    _performConversion();
                    _checkFavorite();
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOutputSection(UnitCategoryDef categoryDef, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TO',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textMuted,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _accentSuccess.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _accentSuccess.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _outputValue,
                  style: TextStyle(
                    color: _accentSuccess,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _bgMain,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                ),
                child: DropdownButton<String>(
                  value: _toUnitId,
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: _bgCard,
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  items: categoryDef.units.map((unit) {
                    return DropdownMenuItem(
                      value: unit.id,
                      child: Text(unit.displayLabel),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _toUnitId = value;
                    });
                    _performConversion();
                    _checkFavorite();
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommonPairs(List<CommonPair> commonPairs) {
    return Container(
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
            'COMMON CONVERSIONS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: commonPairs.map((pair) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _useCommonPair(pair),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _accentPrimary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _accentPrimary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      pair.label,
                      style: TextStyle(
                        color: _accentPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
