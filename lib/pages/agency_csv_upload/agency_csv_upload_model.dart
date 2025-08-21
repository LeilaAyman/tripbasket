import '/flutter_flow/flutter_flow_util.dart';
import 'agency_csv_upload_widget.dart' show AgencyCsvUploadWidget;
import 'package:flutter/material.dart';

class AgencyCsvUploadModel extends FlutterFlowModel<AgencyCsvUploadWidget> {
  // State variables
  bool isLoading = false;
  String uploadStatus = '';
  List<String> uploadErrors = [];
  
  @override
  void initState(BuildContext context) {
    // Initialize state
    isLoading = false;
    uploadStatus = '';
    uploadErrors = [];
  }

  @override
  void dispose() {
    // Clean up resources
    // Note: FlutterFlowModel doesn't have a dispose method, so we don't call super.dispose()
  }
}
