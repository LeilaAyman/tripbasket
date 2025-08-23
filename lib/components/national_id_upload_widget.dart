import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/utils/kyc_utils.dart';

class NationalIdUploadWidget extends StatefulWidget {
  final Function()? onUploadComplete;
  final bool showSkipOption;

  const NationalIdUploadWidget({
    Key? key,
    this.onUploadComplete,
    this.showSkipOption = true,
  }) : super(key: key);

  @override
  State<NationalIdUploadWidget> createState() => _NationalIdUploadWidgetState();
}

class _NationalIdUploadWidgetState extends State<NationalIdUploadWidget> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _uploadPhoto(ImageSource source) async {
    if (!loggedIn || currentUserUid == null) {
      setState(() {
        _errorMessage = 'You must be logged in to upload ID';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await KycUtils.uploadNationalId(
        uid: currentUserUid!,
        source: source,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('National ID uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onUploadComplete?.call();
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user,
                color: FlutterFlowTheme.of(context).primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'National ID Verification',
                style: FlutterFlowTheme.of(context).headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Upload your National ID photo to verify your identity. This is required before making any bookings.',
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '• Accepted formats: JPG, PNG\n• Maximum file size: 5 MB\n• Ensure all details are clearly visible',
            style: FlutterFlowTheme.of(context).bodySmall,
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else
            Row(
              children: [
                Expanded(
                  child: FFButtonWidget(
                    onPressed: () => _uploadPhoto(ImageSource.camera),
                    text: 'Take Photo',
                    icon: const Icon(Icons.camera_alt),
                    options: FFButtonOptions(
                      height: 50,
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'Readex Pro',
                        color: Colors.white,
                      ),
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FFButtonWidget(
                    onPressed: () => _uploadPhoto(ImageSource.gallery),
                    text: 'Choose from Gallery',
                    icon: const Icon(Icons.photo_library),
                    options: FFButtonOptions(
                      height: 50,
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      color: FlutterFlowTheme.of(context).secondary,
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'Readex Pro',
                        color: Colors.white,
                      ),
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          if (widget.showSkipOption) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => widget.onUploadComplete?.call(),
                child: Text(
                  'Skip for now',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Readex Pro',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}