import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'report_preview_screen.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _technicianNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _pipeDiameterController = TextEditingController();
  final _wallThicknessController = TextEditingController();
  final _findingsController = TextEditingController();
  final _correctiveActionsController = TextEditingController();
  final _additionalNotesController = TextEditingController();
  
  DateTime _inspectionDate = DateTime.now();
  String _selectedMethod = 'MT';

  final List<String> _inspectionMethods = [
    'MT',
    'UT',
    'PT',
    'PAUT',
    'Visual',
  ];

  @override
  void dispose() {
    _technicianNameController.dispose();
    _locationController.dispose();
    _pipeDiameterController.dispose();
    _wallThicknessController.dispose();
    _findingsController.dispose();
    _correctiveActionsController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _inspectionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _inspectionDate) {
      setState(() {
        _inspectionDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Navigate to preview screen with form data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReportPreviewScreen(
            technicianName: _technicianNameController.text,
            inspectionDate: _inspectionDate,
            location: _locationController.text,
            pipeDiameter: _pipeDiameterController.text,
            wallThickness: _wallThicknessController.text,
            method: _selectedMethod,
            findings: _findingsController.text,
            correctiveActions: _correctiveActionsController.text,
            additionalNotes: _additionalNotesController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NDT Report Form'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  side: const BorderSide(color: AppTheme.divider),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inspection Details',
                        style: AppTheme.titleLarge,
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),
                      TextFormField(
                        controller: _technicianNameController,
                        decoration: const InputDecoration(
                          labelText: 'Technician Name',
                          hintText: 'Enter your name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Date of Inspection'),
                        subtitle: Text(
                          '${_inspectionDate.year}-${_inspectionDate.month.toString().padLeft(2, '0')}-${_inspectionDate.day.toString().padLeft(2, '0')}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location / Station #',
                          hintText: 'Enter location or station number',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter location';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.paddingLarge),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  side: const BorderSide(color: AppTheme.divider),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pipe Specifications',
                        style: AppTheme.titleLarge,
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),
                      TextFormField(
                        controller: _pipeDiameterController,
                        decoration: const InputDecoration(
                          labelText: 'Pipe Diameter',
                          hintText: 'Enter pipe diameter',
                          suffixText: 'inches',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter pipe diameter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                      TextFormField(
                        controller: _wallThicknessController,
                        decoration: const InputDecoration(
                          labelText: 'Wall Thickness',
                          hintText: 'Enter wall thickness',
                          suffixText: 'inches',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter wall thickness';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                      DropdownButtonFormField<String>(
                        value: _selectedMethod,
                        decoration: const InputDecoration(
                          labelText: 'Method Used',
                        ),
                        items: _inspectionMethods.map((String method) {
                          return DropdownMenuItem<String>(
                            value: method,
                            child: Text(method),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedMethod = newValue;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.paddingLarge),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  side: const BorderSide(color: AppTheme.divider),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inspection Results',
                        style: AppTheme.titleLarge,
                      ),
                      const SizedBox(height: AppTheme.paddingLarge),
                      TextFormField(
                        controller: _findingsController,
                        decoration: const InputDecoration(
                          labelText: 'Description of Findings',
                          hintText: 'Describe what was found during inspection',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please describe your findings';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                      TextFormField(
                        controller: _correctiveActionsController,
                        decoration: const InputDecoration(
                          labelText: 'Corrective Actions Taken',
                          hintText: 'Describe any corrective actions taken',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please describe corrective actions';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                      TextFormField(
                        controller: _additionalNotesController,
                        decoration: const InputDecoration(
                          labelText: 'Additional Notes',
                          hintText: 'Any additional information or notes',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.paddingLarge),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Generate Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 