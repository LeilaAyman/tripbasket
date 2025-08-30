import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/utils/image_upload_utils.dart';

class MultipleImageUploadWidget extends StatefulWidget {
  final List<String> initialImageUrls;
  final Function(List<String>) onImagesUploaded;
  final String agencyId;
  final String tripId;
  final String label;
  final int? maxImages;

  const MultipleImageUploadWidget({
    Key? key,
    this.initialImageUrls = const [],
    required this.onImagesUploaded,
    required this.agencyId,
    required this.tripId,
    this.label = 'Trip Gallery',
    this.maxImages,
  }) : super(key: key);

  @override
  State<MultipleImageUploadWidget> createState() => _MultipleImageUploadWidgetState();
}

class _MultipleImageUploadWidgetState extends State<MultipleImageUploadWidget> {
  bool _isLoading = false;
  String? _errorMessage;
  List<String> _currentImageUrls = [];

  @override
  void initState() {
    super.initState();
    _currentImageUrls = List.from(widget.initialImageUrls);
  }

  Future<void> _uploadMultipleImages() async {
    if (widget.maxImages != null && _currentImageUrls.length >= widget.maxImages!) {
      setState(() {
        _errorMessage = 'Maximum ${widget.maxImages} images allowed';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final maxToAdd = widget.maxImages != null 
          ? widget.maxImages! - _currentImageUrls.length 
          : 20; // Default max per batch
      
      final uploadedUrls = await ImageUploadUtils.uploadMultipleImages(
        agencyId: widget.agencyId,
        tripId: widget.tripId,
        maxImages: maxToAdd,
      );

      if (uploadedUrls.isNotEmpty && mounted) {
        if (kDebugMode) {
          print('Multiple images upload successful! URLs: $uploadedUrls');
          print('Total images now: ${_currentImageUrls.length + uploadedUrls.length}');
        }
        setState(() {
          _currentImageUrls.addAll(uploadedUrls);
        });
        widget.onImagesUploaded(_currentImageUrls);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${uploadedUrls.length} image${uploadedUrls.length > 1 ? 's' : ''} uploaded successfully!'),
            backgroundColor: const Color(0xFFD76B30),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted && uploadedUrls.isEmpty) {
        if (kDebugMode) {
          print('Multiple image upload completed but no URLs returned');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed - no images were uploaded'),
            backgroundColor: Colors.red,
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

  Future<void> _uploadSingleImage(ImageSource source) async {
    if (widget.maxImages != null && _currentImageUrls.length >= widget.maxImages!) {
      setState(() {
        _errorMessage = 'Maximum ${widget.maxImages} images allowed';
      });
      return;
    }

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
          _currentImageUrls.add(uploadedUrl);
        });
        widget.onImagesUploaded(_currentImageUrls);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image uploaded successfully!'),
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

  void _removeImage(int index) {
    setState(() {
      _currentImageUrls.removeAt(index);
    });
    widget.onImagesUploaded(_currentImageUrls);
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
                  'Add Images',
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Multiple Images Option
                _buildSourceOption(
                  'Select Multiple from Gallery',
                  Icons.photo_library,
                  () => _uploadMultipleImages(),
                  isFullWidth: true,
                ),
                const SizedBox(height: 12),
                
                // Single Image Options
                Row(
                  children: [
                    Expanded(
                      child: _buildSourceOption(
                        'Camera',
                        Icons.camera_alt,
                        () => _uploadSingleImage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSourceOption(
                        'Gallery',
                        Icons.photo,
                        () => _uploadSingleImage(ImageSource.gallery),
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

  Widget _buildSourceOption(String title, IconData icon, VoidCallback onTap, {bool isFullWidth = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          vertical: isFullWidth ? 16 : 20,
          horizontal: isFullWidth ? 16 : 8,
        ),
        decoration: BoxDecoration(
          color: isFullWidth 
              ? const Color(0xFFD76B30).withOpacity(0.1)
              : const Color(0xFFD76B30).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD76B30).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: isFullWidth 
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: const Color(0xFFD76B30),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      color: const Color(0xFFD76B30),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Column(
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
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
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
                  Icons.photo_library,
                  color: const Color(0xFFD76B30),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.label,
                    style: FlutterFlowTheme.of(context).labelMedium.override(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: FlutterFlowTheme.of(context).primaryText,
                    ),
                  ),
                ),
                if (_currentImageUrls.isNotEmpty)
                  Text(
                    '${_currentImageUrls.length}${widget.maxImages != null ? '/${widget.maxImages}' : ''} photos',
                    style: FlutterFlowTheme.of(context).labelSmall.override(
                      color: Colors.grey.shade600,
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
                // Images Grid
                if (_currentImageUrls.isNotEmpty) ...[
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: _currentImageUrls.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(_currentImageUrls[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Add Images Button or Upload Area
                if (_isLoading)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    child: const Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFD76B30),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text('Uploading images...'),
                      ],
                    ),
                  )
                else
                  FFButtonWidget(
                    onPressed: (widget.maxImages != null && _currentImageUrls.length >= widget.maxImages!)
                        ? null
                        : _showImageSourceDialog,
                    text: _currentImageUrls.isEmpty 
                        ? 'Add Photos' 
                        : 'Add More Photos',
                    icon: Icon(
                      _currentImageUrls.isEmpty ? Icons.add_photo_alternate : Icons.add,
                      size: 18,
                    ),
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 48,
                      padding: EdgeInsets.zero,
                      color: (widget.maxImages != null && _currentImageUrls.length >= widget.maxImages!)
                          ? Colors.grey.shade300
                          : const Color(0xFFD76B30),
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        color: (widget.maxImages != null && _currentImageUrls.length >= widget.maxImages!)
                            ? Colors.grey.shade600
                            : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      elevation: 0,
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                
                // Info Text
                if (_currentImageUrls.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Upload photos from your device. JPG, PNG, WebP • Max 5MB per image',
                      style: FlutterFlowTheme.of(context).labelSmall.override(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
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