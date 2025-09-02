import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/utils/pdf_upload_utils.dart';

class PdfUploadWidget extends StatefulWidget {
  final String? initialPdfUrl;
  final Function(String?) onPdfUploaded;
  final String agencyId;
  final String tripId;
  final bool isRequired;
  final String label;

  const PdfUploadWidget({
    Key? key,
    this.initialPdfUrl,
    required this.onPdfUploaded,
    required this.agencyId,
    required this.tripId,
    this.isRequired = false,
    this.label = 'Trip Itinerary PDF',
  }) : super(key: key);

  @override
  State<PdfUploadWidget> createState() => _PdfUploadWidgetState();
}

class _PdfUploadWidgetState extends State<PdfUploadWidget> {
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentPdfUrl;
  String? _currentPdfName;

  @override
  void initState() {
    super.initState();
    _currentPdfUrl = widget.initialPdfUrl;
    if (_currentPdfUrl != null) {
      _currentPdfName = _extractFileNameFromUrl(_currentPdfUrl!);
    }
  }

  String _extractFileNameFromUrl(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    if (segments.isNotEmpty) {
      final fileName = segments.last;
      // Remove Firebase Storage tokens and return clean filename
      final cleanName = fileName.split('?').first;
      return cleanName.contains('_') ? cleanName.split('_').last : cleanName;
    }
    return 'document.pdf';
  }

  Future<void> _uploadPdf() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final fileName = result.files.single.name;
        
        if (kDebugMode) {
          print('PDF selected: $fileName');
        }

        final uploadedUrl = await PdfUploadUtils.uploadTripPdf(
          agencyId: widget.agencyId,
          tripId: widget.tripId,
          filePath: result.files.single.path!,
          fileName: fileName,
        );

        if (uploadedUrl != null && mounted) {
          if (kDebugMode) {
            print('PDF upload successful! URL: $uploadedUrl');
          }
          setState(() {
            _currentPdfUrl = uploadedUrl;
            _currentPdfName = fileName;
          });
          widget.onPdfUploaded(uploadedUrl);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.label} uploaded successfully!'),
              backgroundColor: const Color(0xFFD76B30),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (mounted && uploadedUrl == null) {
          if (kDebugMode) {
            print('Upload completed but URL is null');
          }
          setState(() {
            _errorMessage = 'Upload failed - please try again';
          });
        }
      } else {
        if (kDebugMode) {
          print('No file selected');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _removePdf() {
    setState(() {
      _currentPdfUrl = null;
      _currentPdfName = null;
    });
    widget.onPdfUploaded(null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _errorMessage != null 
              ? Colors.red.shade300 
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.picture_as_pdf,
                  color: const Color(0xFFD76B30),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: FlutterFlowTheme.of(context).labelMedium.override(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
                if (widget.isRequired)
                  Text(
                    ' *',
                    style: FlutterFlowTheme.of(context).labelMedium.override(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const Spacer(),
                Text(
                  '(Optional)',
                  style: FlutterFlowTheme.of(context).labelSmall.override(
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Content Area
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // PDF Preview or Upload Area
                if (_currentPdfUrl != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD76B30).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFD76B30).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD76B30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentPdfName ?? 'document.pdf',
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'PDF Document',
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _removePdf,
                          icon: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  GestureDetector(
                    onTap: _isLoading ? null : _uploadPdf,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: _isLoading
                          ? const Column(
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFD76B30),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text('Uploading PDF...'),
                              ],
                            )
                          : Column(
                              children: [
                                Icon(
                                  Icons.cloud_upload,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Tap to upload PDF',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'PDF • Max 10MB • Optional',
                                  style: FlutterFlowTheme.of(context).labelSmall.override(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                
                // Change PDF Button (when PDF exists)
                if (_currentPdfUrl != null && !_isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: FFButtonWidget(
                      onPressed: _uploadPdf,
                      text: 'Change PDF',
                      icon: const Icon(Icons.edit, size: 18),
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 40,
                        padding: EdgeInsets.zero,
                        color: Colors.transparent,
                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          color: const Color(0xFFD76B30),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        elevation: 0,
                        borderSide: const BorderSide(
                          color: Color(0xFFD76B30),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                
                // Error Message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.shade200,
                          width: 1,
                        ),
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
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}