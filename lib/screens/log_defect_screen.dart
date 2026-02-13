import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../models/defect_entry.dart';
import '../models/defect_type.dart';
import '../services/defect_service.dart';
import '../services/defect_type_service.dart';
import '../services/pdf_management_service.dart';
import '../services/analytics_service.dart';

class LogDefectScreen extends StatefulWidget {
  const LogDefectScreen({Key? key}) : super(key: key);

  @override
  State<LogDefectScreen> createState() => _LogDefectScreenState();
}

class _LogDefectScreenState extends State<LogDefectScreen> {
  final _formKey = GlobalKey<FormState>();
  final DefectService _defectService = DefectService();
  final DefectTypeService _defectTypeService = DefectTypeService();
  final PdfManagementService _pdfManagementService = PdfManagementService();
  final AnalyticsService _analyticsService = AnalyticsService();
  
  final TextEditingController _pipeODController = TextEditingController();
  final TextEditingController _pipeNWTController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _depthController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  String? _selectedDefectType;
  String? _selectedClient;
  List<DefectType> _defectTypes = [];
  List<String> _clients = [];
  bool _isLoading = false;
  bool _isLoadingTypes = true;
  bool _isLoadingClients = true;

  @override
  void initState() {
    super.initState();
    _loadDefectTypes();
    _loadClients();
  }

  Future<void> _loadDefectTypes() async {
    setState(() => _isLoadingTypes = true);
    _defectTypeService.getActiveDefectTypes().listen((types) {
      setState(() {
        _defectTypes = types;
        _isLoadingTypes = false;
      });
    });
  }

  Future<void> _loadClients() async {
    setState(() => _isLoadingClients = true);
    try {
      final clients = await _pdfManagementService.getCompanies();
      setState(() {
        _clients = clients;
        _isLoadingClients = false;
      });
    } catch (e) {
      print('Error loading clients: $e');
      setState(() => _isLoadingClients = false);
    }
  }

  bool get _isHardspot => 
      _selectedDefectType?.toLowerCase().contains('hardspot') ?? false;

  String get _depthLabel => _isHardspot ? 'Max HB' : 'Depth (in)';

  @override
  void dispose() {
    _pipeODController.dispose();
    _pipeNWTController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _depthController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitDefect() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDefectType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a defect type'),
          backgroundColor: const Color(0xFFFE637E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a client'),
          backgroundColor: const Color(0xFFFE637E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final defectEntry = DefectEntry(
        id: '',
        userId: userId,
        defectType: _selectedDefectType!,
        pipeOD: double.parse(_pipeODController.text),
        pipeNWT: double.parse(_pipeNWTController.text),
        length: double.parse(_lengthController.text),
        width: double.parse(_widthController.text),
        depth: double.parse(_depthController.text),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        clientName: _selectedClient!,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      final newDefectId = await _defectService.addDefectEntry(defectEntry);

      await _analyticsService.logDefectLogged(
        _selectedDefectType!,
        _selectedClient!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Defect logged successfully! AI analysis starting...'),
            backgroundColor: const Color(0xFF00E5A8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging defect: $e'),
            backgroundColor: const Color(0xFFFE637E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E232A),
      appBar: AppBar(
        title: const Text(
          'Log New Defect',
          style: TextStyle(
            color: Color(0xFFEDF9FF),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF242A33),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFEDF9FF)),
      ),
      body: (_isLoadingTypes || _isLoadingClients)
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5BFF)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5BFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF6C5BFF).withOpacity(0.2),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFF6C5BFF),
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'All measurements should be entered in inches',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFEDF9FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Pipe OD Field
                    _buildFieldLabel('Pipe OD (in)'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _pipeODController,
                      hint: 'Enter pipe outside diameter',
                      icon: Icons.straighten,
                      suffix: 'in',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter pipe OD';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Pipe OD must be greater than 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Pipe NWT Field
                    _buildFieldLabel('Pipe NWT (in)'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _pipeNWTController,
                      hint: 'Enter nominal wall thickness',
                      icon: Icons.width_normal,
                      suffix: 'in',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter pipe NWT';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Pipe NWT must be greater than 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Defect Type Dropdown
                    _buildFieldLabel('Defect Type'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedDefectType,
                      hint: 'Select defect type',
                      icon: Icons.category,
                      items: _defectTypes.map((defectType) {
                        return DropdownMenuItem<String>(
                          value: defectType.name,
                          child: Text(defectType.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDefectType = value;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // Length Field
                    _buildFieldLabel('Length (in)'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _lengthController,
                      hint: 'Enter length',
                      icon: Icons.straighten,
                      suffix: 'in',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter length';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Length must be greater than 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Width Field
                    _buildFieldLabel('Width (in)'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _widthController,
                      hint: 'Enter width',
                      icon: Icons.width_normal,
                      suffix: 'in',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter width';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Width must be greater than 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Depth/Max HB Field
                    _buildFieldLabel(_depthLabel),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _depthController,
                      hint: _isHardspot ? 'Enter Max HB value' : 'Enter depth',
                      icon: Icons.height,
                      suffix: _isHardspot ? 'HB' : 'in',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter ${_isHardspot ? 'Max HB' : 'depth'}';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return '${_isHardspot ? 'Max HB' : 'Depth'} must be greater than 0';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Notes Field
                    _buildFieldLabel('Notes (Optional)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 4,
                      style: const TextStyle(color: Color(0xFFEDF9FF)),
                      decoration: InputDecoration(
                        hintText: 'Add any additional notes or observations...',
                        hintStyle: const TextStyle(color: Color(0xFF7F8A96)),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 60),
                          child: Icon(Icons.note, color: Color(0xFFAEBBC8)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF242A33),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF6C5BFF),
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Client Selection Dropdown
                    _buildFieldLabel('Client'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedClient,
                      hint: 'Select client company',
                      icon: Icons.business,
                      items: _clients.map((client) {
                        return DropdownMenuItem<String>(
                          value: client,
                          child: Text(client.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClient = value;
                        });
                      },
                    ),

                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitDefect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5BFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: const Color(0xFF6C5BFF).withOpacity(0.5),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Log Defect',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFFEDF9FF),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String suffix,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      style: const TextStyle(color: Color(0xFFEDF9FF)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF7F8A96)),
        prefixIcon: Icon(icon, color: const Color(0xFFAEBBC8)),
        suffixText: suffix,
        suffixStyle: const TextStyle(color: Color(0xFFAEBBC8)),
        filled: true,
        fillColor: const Color(0xFF242A33),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF6C5BFF),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFFE637E),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFFE637E),
            width: 2,
          ),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFE637E)),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: const Color(0xFF242A33),
      style: const TextStyle(color: Color(0xFFEDF9FF)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF7F8A96)),
        prefixIcon: Icon(icon, color: const Color(0xFFAEBBC8)),
        filled: true,
        fillColor: const Color(0xFF242A33),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF6C5BFF),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFFE637E),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFFE637E),
            width: 2,
          ),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFE637E)),
      ),
      items: items,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select an option';
        }
        return null;
      },
    );
  }
}
