import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/utils/review_import_utils.dart';
import '/utils/agency_utils.dart';

class ReviewImportDialog extends StatefulWidget {
  const ReviewImportDialog({super.key});

  @override
  State<ReviewImportDialog> createState() => _ReviewImportDialogState();
}

class _ReviewImportDialogState extends State<ReviewImportDialog> {
  bool _isLoading = false;
  String? _errorMessage;
  String? _csvData;
  String? _fileName;
  ReviewImportResult? _importResult;

  Future<void> _pickCsvFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final csvContent = utf8.decode(bytes);
        
        setState(() {
          _csvData = csvContent;
          _fileName = result.files.single.name;
          _errorMessage = null;
          _importResult = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error reading file: $e';
      });
    }
  }

  Future<void> _importReviews() async {
    if (_csvData == null) {
      setState(() {
        _errorMessage = 'Please select a CSV file first';
      });
      return;
    }

    final agencyRef = AgencyUtils.getCurrentAgencyRef();
    if (agencyRef == null) {
      setState(() {
        _errorMessage = 'No agency reference found';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ReviewImportUtils.importReviewsFromCsv(
        csvData: _csvData!,
        agencyRef: agencyRef,
      );

      setState(() {
        _importResult = result;
        _isLoading = false;
      });

      if (result.successful > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully imported ${result.successful} reviews!'),
            backgroundColor: const Color(0xFFD76B30),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _downloadTemplate() {
    final template = ReviewImportUtils.generateCsvTemplate();
    // In a real implementation, you would trigger a download here
    // For now, we'll show the template in a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CSV Template'),
        content: SingleChildScrollView(
          child: SelectableText(
            template,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD76B30).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.upload_file,
                      color: Color(0xFFD76B30),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Import Reviews',
                      style: FlutterFlowTheme.of(context).headlineSmall.override(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD76B30).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFD76B30).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFFD76B30),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Instructions',
                          style: FlutterFlowTheme.of(context).titleSmall.override(
                            color: const Color(0xFFD76B30),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Your CSV must include columns: trip_title, user_name, rating, comment\n'
                      '2. Optional: date column for review date\n'
                      '3. Rating must be between 1.0 and 5.0\n'
                      '4. Trip titles must match existing trips in your agency\n'
                      '5. Duplicate reviews (same user + trip) will be skipped',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Template download
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Need a template?',
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _downloadTemplate,
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Download Template'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFD76B30),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // File picker
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _csvData != null ? const Color(0xFFD76B30) : Colors.grey.shade300,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: _csvData != null 
                      ? const Color(0xFFD76B30).withOpacity(0.05)
                      : Colors.grey.shade50,
                ),
                child: Column(
                  children: [
                    if (_csvData == null) ...[
                      Icon(
                        Icons.cloud_upload,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Select CSV file to import reviews',
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FFButtonWidget(
                        onPressed: _pickCsvFile,
                        text: 'Choose File',
                        icon: const Icon(Icons.folder_open, size: 18),
                        options: FFButtonOptions(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          color: const Color(0xFFD76B30),
                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.check_circle,
                        size: 48,
                        color: const Color(0xFFD76B30),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'File selected: $_fileName',
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                          color: const Color(0xFFD76B30),
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: _pickCsvFile,
                            child: const Text('Change File'),
                          ),
                          const SizedBox(width: 16),
                          FFButtonWidget(
                            onPressed: _isLoading ? null : _importReviews,
                            text: _isLoading ? 'Importing...' : 'Import Reviews',
                            icon: _isLoading 
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.upload, size: 18),
                            options: FFButtonOptions(
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              color: const Color(0xFFD76B30),
                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Import result
              if (_importResult != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Import Complete',
                            style: FlutterFlowTheme.of(context).titleSmall.override(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _importResult!.summary,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          color: Colors.green.shade700,
                        ),
                      ),
                      if (_importResult!.errors.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Errors:',
                          style: FlutterFlowTheme.of(context).labelMedium.override(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 120),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _importResult!.errors.map((error) => 
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    '• $error',
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                      color: Colors.red.shade600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ).toList(),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}