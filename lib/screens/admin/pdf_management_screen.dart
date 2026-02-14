import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_theme.dart';
import '../../services/pdf_management_service.dart';

class PdfManagementScreen extends StatefulWidget {
  const PdfManagementScreen({super.key});

  @override
  State<PdfManagementScreen> createState() => _PdfManagementScreenState();
}

class _PdfManagementScreenState extends State<PdfManagementScreen> {
  final PdfManagementService _pdfService = PdfManagementService();
  List<String> _companies = [];
  List<Map<String, dynamic>> _pdfs = [];
  String? _selectedCompany;
  bool _isLoading = false;
  bool _isUploading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final companies = await _pdfService.getCompanies();
      setState(() {
        _companies = companies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error loading companies: $e', isError: true);
    }
  }

  Future<void> _loadPdfs(String company) async {
    setState(() {
      _isLoading = true;
      _selectedCompany = company;
    });

    try {
      final pdfs = await _pdfService.getPdfsForCompany(company);
      setState(() {
        _pdfs = pdfs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error loading PDFs: $e', isError: true);
    }
  }

  Future<void> _uploadPdf() async {
    if (_selectedCompany == null) {
      _showSnackBar('Please select a company first', isError: true);
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (!_pdfService.isPdfFile(file.name)) {
          _showSnackBar('Please select a PDF file', isError: true);
          return;
        }

        setState(() {
          _isUploading = true;
        });

        final success = await _pdfService.uploadPdf(_selectedCompany!, file);

        setState(() {
          _isUploading = false;
        });

        if (success) {
          _showSnackBar('PDF uploaded successfully');
          _loadPdfs(_selectedCompany!);
        } else {
          _showSnackBar('Failed to upload PDF', isError: true);
        }
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showSnackBar('Error uploading PDF: $e', isError: true);
    }
  }

  Future<void> _deletePdf(String filename) async {
    if (_selectedCompany == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Delete PDF', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text('Are you sure you want to delete "$filename"?',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success =
            await _pdfService.deletePdf(_selectedCompany!, filename);
        if (success) {
          _showSnackBar('PDF deleted successfully');
          _loadPdfs(_selectedCompany!);
        } else {
          _showSnackBar('Failed to delete PDF', isError: true);
        }
      } catch (e) {
        _showSnackBar('Error deleting PDF: $e', isError: true);
      }
    }
  }

  Future<void> _replacePdf(String filename) async {
    if (_selectedCompany == null) return;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (!_pdfService.isPdfFile(file.name)) {
          _showSnackBar('Please select a PDF file', isError: true);
          return;
        }

        setState(() {
          _isUploading = true;
        });

        final success =
            await _pdfService.replacePdf(_selectedCompany!, filename, file);

        setState(() {
          _isUploading = false;
        });

        if (success) {
          _showSnackBar('PDF replaced successfully');
          _loadPdfs(_selectedCompany!);
        } else {
          _showSnackBar('Failed to replace PDF', isError: true);
        }
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showSnackBar('Error replacing PDF: $e', isError: true);
    }
  }

  Future<void> _renamePdf(String oldFilename) async {
    if (_selectedCompany == null) return;

    final controller = TextEditingController(text: oldFilename);
    final newFilename = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Rename PDF', style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            labelText: 'New filename',
            labelStyle: TextStyle(color: AppTheme.textSecondary),
            hintText: 'Enter new filename',
            hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.secondaryAccent),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text('Rename', style: TextStyle(color: AppTheme.secondaryAccent)),
          ),
        ],
      ),
    );

    if (newFilename != null &&
        newFilename.isNotEmpty &&
        newFilename != oldFilename) {
      try {
        final success = await _pdfService.renamePdf(
            _selectedCompany!, oldFilename, newFilename);
        if (success) {
          _showSnackBar('PDF renamed successfully');
          _loadPdfs(_selectedCompany!);
        } else {
          _showSnackBar('Failed to rename PDF', isError: true);
        }
      } catch (e) {
        _showSnackBar('Error renaming PDF: $e', isError: true);
      }
    }
  }

  Future<void> _createCompanyFolder() async {
    final controller = TextEditingController();
    final companyName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Create Company Folder',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            labelText: 'Company name',
            labelStyle: TextStyle(color: AppTheme.textSecondary),
            hintText: 'Enter company name',
            hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.textSecondary.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.secondaryAccent),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text('Create', style: TextStyle(color: AppTheme.secondaryAccent)),
          ),
        ],
      ),
    );

    if (companyName != null && companyName.isNotEmpty) {
      try {
        final success =
            await _pdfService.createCompanyFolder(companyName.toLowerCase());
        if (success) {
          _showSnackBar('Company folder created successfully');
          _loadCompanies();
        } else {
          _showSnackBar('Failed to create company folder', isError: true);
        }
      } catch (e) {
        _showSnackBar('Error creating company folder: $e', isError: true);
      }
    }
  }

  List<Map<String, dynamic>> get _filteredPdfs {
    if (_searchQuery.isEmpty) return _pdfs;

    return _pdfs.where((pdf) {
      final filename = pdf['name'].toString().toLowerCase();
      return filename.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppTheme.secondaryAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Modern Header
          _buildModernHeader(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildMainContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.textPrimary.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.secondaryAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.picture_as_pdf,
                color: AppTheme.secondaryAccent,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PDF Management',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage company documents and procedures',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.secondaryAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.secondaryAccent.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _createCompanyFolder,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.create_new_folder,
                            size: 18, color: AppTheme.secondaryAccent),
                        const SizedBox(width: 8),
                        Text(
                          'New Company',
                          style: TextStyle(
                            color: AppTheme.secondaryAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (MediaQuery.of(context).size.width < 1200) ...[
              const SizedBox(width: 16),
              Builder(
                builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: Icon(Icons.menu, color: AppTheme.textPrimary, size: 28),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Companies sidebar
        Expanded(
          flex: 1,
          child: _buildCompaniesList(),
        ),
        const SizedBox(width: 24),

        // PDFs section
        Expanded(
          flex: 2,
          child: _buildPdfsSection(),
        ),
      ],
    );
  }

  Widget _buildCompaniesList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.textPrimary.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Companies', Icons.business, AppTheme.secondaryAccent),
          const SizedBox(height: 20),
          if (_isLoading)
            Center(
                child: CircularProgressIndicator(color: AppTheme.secondaryAccent))
          else if (_companies.isEmpty)
            _buildEmptyState(
              icon: Icons.business,
              title: 'No companies found',
              subtitle: 'Create your first company folder',
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _companies.length,
              itemBuilder: (context, index) {
                final company = _companies[index];
                final isSelected = company == _selectedCompany;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => _loadPdfs(company),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.secondaryAccent.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.secondaryAccent.withOpacity(0.3)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder,
                            color: isSelected
                                ? AppTheme.secondaryAccent
                                : AppTheme.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              company.toUpperCase(),
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppTheme.secondaryAccent
                                    : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: AppTheme.secondaryAccent,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPdfsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.textPrimary.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSectionHeader(
                  _selectedCompany != null
                      ? '${_selectedCompany!.toUpperCase()} Documents'
                      : 'Documents',
                  Icons.picture_as_pdf,
                  AppTheme.secondaryAccent,
                ),
              ),
              if (_selectedCompany != null)
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.secondaryAccent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isUploading ? null : _uploadPdf,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isUploading)
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.secondaryAccent,
                                ),
                              )
                            else
                              Icon(Icons.upload_file,
                                  size: 18, color: AppTheme.secondaryAccent),
                            const SizedBox(width: 8),
                            Text(
                              'Upload PDF',
                              style: TextStyle(
                                color: AppTheme.secondaryAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          if (_selectedCompany != null) ...[
            // Search bar
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search PDFs...',
                hintStyle: TextStyle(color: AppTheme.textSecondary),
                prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: Icon(Icons.clear, color: AppTheme.textSecondary),
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // PDFs list
          if (_selectedCompany == null)
            _buildEmptyState(
              icon: Icons.picture_as_pdf,
              title: 'Select a company',
              subtitle: 'Choose a company from the left to view documents',
            )
          else if (_isLoading)
            Center(
                child: CircularProgressIndicator(color: AppTheme.secondaryAccent))
          else if (_filteredPdfs.isEmpty)
            _buildEmptyState(
              icon: Icons.picture_as_pdf,
              title: _searchQuery.isNotEmpty
                  ? 'No PDFs found for "$_searchQuery"'
                  : 'No PDFs found',
              subtitle: _searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'Upload your first PDF to get started',
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredPdfs.length,
              itemBuilder: (context, index) {
                final pdf = _filteredPdfs[index];
                return _buildPdfCard(pdf);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPdfCard(Map<String, dynamic> pdf) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.textPrimary.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.picture_as_pdf,
              color: Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pdf['name'] ?? 'Unknown',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _pdfService.formatFileSize(pdf['size']),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if (pdf['updatedAt'] != null) ...[
                      const SizedBox(width: 16),
                      Text(
                        'Updated: ${_formatDate(pdf['updatedAt'])}',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handlePdfAction(value, pdf),
            icon: Icon(Icons.more_vert, color: AppTheme.textSecondary),
            color: AppTheme.surface,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility,
                        size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    Text('View', style: TextStyle(color: AppTheme.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'download',
                child: Row(
                  children: [
                    Icon(Icons.download,
                        size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    Text('Download',
                        style: TextStyle(color: AppTheme.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'replace',
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz,
                        size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    Text('Replace',
                        style: TextStyle(color: AppTheme.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    Text('Rename', style: TextStyle(color: AppTheme.textPrimary)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handlePdfAction(String action, Map<String, dynamic> pdf) async {
    switch (action) {
      case 'view':
        _showSnackBar('PDF viewer not implemented yet');
        break;
      case 'download':
        _showSnackBar('Download not implemented yet');
        break;
      case 'replace':
        await _replacePdf(pdf['name']);
        break;
      case 'rename':
        await _renamePdf(pdf['name']);
        break;
      case 'delete':
        await _deletePdf(pdf['name']);
        break;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
