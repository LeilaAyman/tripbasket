import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/utils/image_upload_utils.dart';

class ImageUploadWidget extends StatefulWidget {
  final String? initialImageUrl;
  final Function(String?) onImageUploaded;
  final String agencyId;
  final String tripId;
  final bool isRequired;
  final String label;

  const ImageUploadWidget({
    Key? key,
    this.initialImageUrl,
    required this.onImageUploaded,
    required this.agencyId,
    required this.tripId,
    this.isRequired = true,
    this.label = 'Trip Image',
  }) : super(key: key);

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.initialImageUrl;
  }

  Future<void> _uploadImage(ImageSource source) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uploadedUrl = await ImageUploadUtils.uploadTripImage(
        agencyId: widget.agencyId,
        tripId: widget.tripId,
        source: source,
      );

      if (uploadedUrl != null && mounted) {
        setState(() {
          _currentImageUrl = uploadedUrl;
        });
        widget.onImageUploaded(uploadedUrl);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.label} uploaded successfully!'),
            backgroundColor: const Color(0xFFD76B30),
            behavior: SnackBarBehavior.floating,
          ),
        );
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

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Select Image Source',
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildSourceOption(
                        'Camera',
                        Icons.camera_alt,
                        () => _uploadImage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSourceOption(
                        'Gallery',
                        Icons.photo_library,
                        () => _uploadImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSourceOption(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFD76B30).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD76B30).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFFD76B30),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                color: const Color(0xFFD76B30),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _currentImageUrl = null;
    });
    widget.onImageUploaded(null);
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
                  Icons.image,
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
              ],
            ),
          ),
          
          // Content Area
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Image Preview or Upload Area
                if (_currentImageUrl != null)
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(_currentImageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            onPressed: _removeImage,
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: _isLoading ? null : _showImageSourceDialog,
                    child: Container(
                      width: double.infinity,
                      height: 200,
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
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFD76B30),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text('Uploading image...'),
                                ],
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Tap to upload ${widget.label.toLowerCase()}',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'JPG, PNG, WebP • Max 5MB',
                                  style: FlutterFlowTheme.of(context).labelSmall.override(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                
                // Change Image Button (when image exists)
                if (_currentImageUrl != null && !_isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: FFButtonWidget(
                      onPressed: _showImageSourceDialog,
                      text: 'Change Image',
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