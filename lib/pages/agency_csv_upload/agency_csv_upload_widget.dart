import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/utils/agency_utils.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'agency_csv_upload_model.dart';
export 'agency_csv_upload_model.dart';

class AgencyCsvUploadWidget extends StatefulWidget {
  const AgencyCsvUploadWidget({super.key});

  static String routeName = 'agencyCsvUpload';
  static String routePath = '/agency-csv-upload';

  @override
  State<AgencyCsvUploadWidget> createState() => _AgencyCsvUploadWidgetState();
}

class _AgencyCsvUploadWidgetState extends State<AgencyCsvUploadWidget> {
  late AgencyCsvUploadModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AgencyCsvUploadModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  bool get canAccess {
    final hasAccess = AgencyUtils.canAccessCSVUpload();
    final userDoc = currentUserDocument;
    final roles = userDoc?.role ?? [];
    final agencyRef = userDoc?.agencyReference;
    
    // Debug logging
    print('CSV Upload Access Check:');
    print('  - User document exists: ${userDoc != null}');
    print('  - User roles: $roles');
    print('  - Agency reference: $agencyRef');
    print('  - Has access: $hasAccess');
    print('  - Current user: ${currentUser?.uid}');
    print('  - Current user email: ${currentUser?.email}');
    
    // Also log to console for debugging
    debugPrint('=== CSV UPLOAD ACCESS DEBUG ===');
    debugPrint('User document exists: ${userDoc != null}');
    debugPrint('User roles: $roles');
    debugPrint('Agency reference: $agencyRef');
    debugPrint('Has access: $hasAccess');
    debugPrint('Current user: ${currentUser?.uid}');
    debugPrint('Current user email: ${currentUser?.email}');
    debugPrint('================================');
    
    return hasAccess;
  }

  Future<void> _pickAndProcessCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _model.isLoading = true;
          _model.uploadStatus = 'Processing CSV file...';
        });

        Uint8List? fileBytes = result.files.first.bytes;
        if (fileBytes != null) {
          String csvString = utf8.decode(fileBytes);
          await _processCSVData(csvString);
        }
      }
    } catch (e) {
      setState(() {
        _model.isLoading = false;
        _model.uploadStatus = 'Error picking file: $e';
      });
    }
  }

  Future<void> _processCSVData(String csvString) async {
    try {
      List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);
      
      if (csvData.isEmpty) {
        setState(() {
          _model.isLoading = false;
          _model.uploadStatus = 'CSV file is empty';
        });
        return;
      }

      // Skip header row if present
      List<List<dynamic>> dataRows = csvData.length > 1 ? csvData.skip(1).toList() : csvData;
      
      int successCount = 0;
      int errorCount = 0;
      List<String> errors = [];

      for (int i = 0; i < dataRows.length; i++) {
        try {
          List<dynamic> row = dataRows[i];
          
          // Expected CSV format: title, price, location, description, image, itinerary, start_date, end_date, quantity
          if (row.length >= 9) {
            await _addTripToFirestore(
              title: row[0].toString().trim(),
              price: int.tryParse(row[1].toString().trim()) ?? 0,
              location: row[2].toString().trim(),
              description: row[3].toString().trim(),
              image: row[4].toString().trim(),
              itinerary: row[5].toString().trim(),
              startDate: DateTime.tryParse(row[6].toString().trim()),
              endDate: DateTime.tryParse(row[7].toString().trim()),
              quantity: int.tryParse(row[8].toString().trim()) ?? 1,
            );
            successCount++;
          } else {
            errorCount++;
            errors.add('Row ${i + 1}: Insufficient data (${row.length} columns, expected 9)');
          }
        } catch (e) {
          errorCount++;
          errors.add('Row ${i + 1}: $e');
        }
      }

      setState(() {
        _model.isLoading = false;
        _model.uploadStatus = 'Upload complete! $successCount trips added, $errorCount errors.';
        _model.uploadErrors = errors;
      });

      if (successCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully uploaded $successCount trips!'),
            backgroundColor: FlutterFlowTheme.of(context).success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      if (errors.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$errorCount errors occurred during upload'),
            backgroundColor: FlutterFlowTheme.of(context).warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _model.isLoading = false;
        _model.uploadStatus = 'Error processing CSV: $e';
      });
    }
  }

  Future<void> _addTripToFirestore({
    required String title,
    required int price,
    required String location,
    required String description,
    required String image,
    required String itinerary,
    DateTime? startDate,
    DateTime? endDate,
    required int quantity,
  }) async {
    final agencyRef = AgencyUtils.getCurrentAgencyRef();
    if (agencyRef == null) {
      throw Exception('Agency reference not found');
    }

    final tripData = createTripsRecordData(
      title: title,
      price: price,
      location: location,
      description: description,
      image: image,
      itenarary: [itinerary],
      startDate: startDate ?? DateTime.now().add(Duration(days: 7)),
      endDate: endDate ?? DateTime.now().add(Duration(days: 14)),
      quantity: quantity,
      availableSeats: quantity,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      agencyReference: agencyRef,
      rating: 0.0,
    );

    await FirebaseFirestore.instance.collection('trips').add(tripData);
  }

  @override
  Widget build(BuildContext context) {
    if (!canAccess) {
      return Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: true,
          title: Text(
            'CSV Upload',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
          centerTitle: false,
          elevation: 2,
        ),
                 body: Center(
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Icon(
                 Icons.block,
                 size: 64,
                 color: FlutterFlowTheme.of(context).error,
               ),
               SizedBox(height: 16),
               Text(
                 'Access Denied',
                 style: FlutterFlowTheme.of(context).headlineMedium,
               ),
               SizedBox(height: 8),
               Text(
                 'You do not have permission to access CSV upload.',
                 style: FlutterFlowTheme.of(context).bodyMedium,
                 textAlign: TextAlign.center,
               ),
               SizedBox(height: 16),
               // Debug information
               Container(
                 padding: EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: FlutterFlowTheme.of(context).secondaryBackground,
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(
                     color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                   ),
                 ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                                            Text(
                         'Debug Info:',
                         style: FlutterFlowTheme.of(context).titleSmall.override(
                           fontFamily: 'Poppins',
                           fontWeight: FontWeight.w600,
                         ),
                       ),
                     SizedBox(height: 8),
                     Text(
                       'User Roles: ${currentUserDocument?.role.join(', ') ?? 'None'}',
                       style: FlutterFlowTheme.of(context).bodySmall,
                     ),
                     Text(
                       'Agency Reference: ${currentUserDocument?.agencyReference != null ? 'Yes' : 'No'}',
                       style: FlutterFlowTheme.of(context).bodySmall,
                     ),
                     Text(
                       'User ID: ${currentUser?.uid ?? 'None'}',
                       style: FlutterFlowTheme.of(context).bodySmall,
                     ),
                   ],
                 ),
               ),
             ],
           ),
         ),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: true,
          title: Text(
            'Upload Trips CSV',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Poppins',
              color: Colors.white,
            ),
          ),
          centerTitle: false,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        FlutterFlowTheme.of(context).primary,
                        FlutterFlowTheme.of(context).primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.upload_file,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Bulk Upload Trips',
                        style: FlutterFlowTheme.of(context).headlineSmall.override(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Upload multiple trips at once using a CSV file',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Inter',
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                // CSV Format Instructions
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
                    ),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: FlutterFlowTheme.of(context).primary,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'CSV Format Required',
                            style: FlutterFlowTheme.of(context).titleMedium.override(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Your CSV should have the following columns (in order):',
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'title, price, location, description, image_url, itinerary, start_date, end_date, quantity',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: 'Monaco',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Dates should be in YYYY-MM-DD format\n• Price and quantity should be numbers\n• Image URL should be a valid image link',
                        style: FlutterFlowTheme.of(context).bodySmall,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Upload Button
                Container(
                  width: double.infinity,
                  child: FFButtonWidget(
                    onPressed: _model.isLoading ? null : _pickAndProcessCSV,
                    text: _model.isLoading ? 'Processing...' : 'Choose CSV File',
                    icon: Icon(
                      _model.isLoading ? Icons.hourglass_empty : Icons.upload_file,
                      size: 20,
                    ),
                    options: FFButtonOptions(
                      height: 56,
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      elevation: 3,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Status Display
                if (_model.uploadStatus.isNotEmpty)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _model.uploadStatus.contains('Error') || _model.uploadStatus.contains('error')
                          ? FlutterFlowTheme.of(context).error.withOpacity(0.1)
                          : FlutterFlowTheme.of(context).success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _model.uploadStatus.contains('Error') || _model.uploadStatus.contains('error')
                            ? FlutterFlowTheme.of(context).error.withOpacity(0.3)
                            : FlutterFlowTheme.of(context).success.withOpacity(0.3),
                      ),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _model.uploadStatus.contains('Error') || _model.uploadStatus.contains('error')
                                  ? Icons.error_outline
                                  : Icons.check_circle_outline,
                              color: _model.uploadStatus.contains('Error') || _model.uploadStatus.contains('error')
                                  ? FlutterFlowTheme.of(context).error
                                  : FlutterFlowTheme.of(context).success,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Upload Status',
                              style: FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          _model.uploadStatus,
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                      ],
                    ),
                  ),
                
                // Error Details
                if (_model.uploadErrors.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).error.withOpacity(0.3),
                      ),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: FlutterFlowTheme.of(context).error,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Error Details',
                              style: FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        ...(_model.uploadErrors.map((error) => Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            '• $error',
                            style: FlutterFlowTheme.of(context).bodySmall,
                          ),
                        ))),
                      ],
                    ),
                  ),
                ],
                
                Spacer(),
                
                // Download Template Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FFButtonWidget(
                    onPressed: () => _downloadTemplate(),
                    text: 'Download CSV Template',
                    icon: Icon(
                      Icons.download,
                      size: 20,
                    ),
                    options: FFButtonOptions(
                      height: 48,
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: FlutterFlowTheme.of(context).primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                      elevation: 1,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _downloadTemplate() {
    // This would typically download a CSV template file
    // For now, we'll show a snackbar with instructions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CSV Template: title,price,location,description,image_url,itinerary,start_date,end_date,quantity'),
        backgroundColor: FlutterFlowTheme.of(context).info,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 5),
      ),
    );
  }
}
