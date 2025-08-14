import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'admin_upload_model.dart';
export 'admin_upload_model.dart';

class AdminUploadWidget extends StatefulWidget {
  const AdminUploadWidget({super.key});

  static String routeName = 'adminUpload';
  static String routePath = '/admin-upload';

  @override
  State<AdminUploadWidget> createState() => _AdminUploadWidgetState();
}

class _AdminUploadWidgetState extends State<AdminUploadWidget> {
  late AdminUploadModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminUploadModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  bool get isAdmin {
    return currentUserDocument?.role.contains('admin') ?? false;
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
          
          // Expected CSV format: title, price, location, description, image, itinerary
          if (row.length >= 6) {
            await _addTripToFirestore(
              title: row[0].toString().trim(),
              price: _parsePrice(row[1].toString().trim()),
              location: row[2].toString().trim(),
              description: row[3].toString().trim(),
              image: row[4].toString().trim(),
              itinerary: row[5].toString().trim(),
            );
            successCount++;
            
            setState(() {
              _model.uploadStatus = 'Processing... $successCount trips added';
            });
          } else {
            errorCount++;
            errors.add('Row ${i + 1}: Insufficient data (expected 6 columns, got ${row.length})');
          }
        } catch (e) {
          errorCount++;
          errors.add('Row ${i + 1}: $e');
        }
      }

      setState(() {
        _model.isLoading = false;
        _model.uploadStatus = 'Upload complete! $successCount trips added successfully. $errorCount errors.';
        if (errors.isNotEmpty) {
          _model.uploadStatus += '\n\nErrors:\n${errors.take(5).join('\n')}';
          if (errors.length > 5) {
            _model.uploadStatus += '\n... and ${errors.length - 5} more errors';
          }
        }
      });

    } catch (e) {
      setState(() {
        _model.isLoading = false;
        _model.uploadStatus = 'Error processing CSV: $e';
      });
    }
  }

  double _parsePrice(String priceStr) {
    // Remove currency symbols and parse
    String cleanPrice = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanPrice) ?? 0.0;
  }

  Future<void> _addTripToFirestore({
    required String title,
    required double price,
    required String location,
    required String description,
    required String image,
    required String itinerary,
  }) async {
    final docTrips = FirebaseFirestore.instance.collection('trips').doc();
    
    // Convert itinerary string to list by splitting on " | "
    List<String> itineraryList = itinerary.split(' | ').map((day) => day.trim()).toList();
    
    await docTrips.set({
      'title': title,
      'price': price.toInt(), // Convert to int to match data model
      'location': location,
      'description': description,
      'image': image,
      'itenarary': itineraryList, // Use the existing field name with typo
      'created_at': DateTime.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthUserStreamWidget(
      builder: (context) => Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 30.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Admin - Upload Trips',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Inter Tight',
              letterSpacing: 0.0,
            ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: !isAdmin
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.security,
                      size: 80.0,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                      child: Text(
                        'Access Denied',
                        style: FlutterFlowTheme.of(context).headlineMedium.override(
                          fontFamily: 'Inter Tight',
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 0.0),
                      child: Text(
                        'You need admin privileges to access this page.',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Inter',
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : SafeArea(
                top: true,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Trips via CSV',
                        style: FlutterFlowTheme.of(context).headlineMedium.override(
                          fontFamily: 'Inter Tight',
                          letterSpacing: 0.0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                        child: Text(
                          'CSV format: title, price, location, description, image_url, itinerary',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).alternate,
                              width: 2.0,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.cloud_upload,
                                  size: 60.0,
                                  color: _model.isLoading 
                                      ? FlutterFlowTheme.of(context).secondaryText
                                      : FlutterFlowTheme.of(context).primary,
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                                  child: Text(
                                    _model.isLoading ? 'Uploading...' : 'Select CSV File',
                                    style: FlutterFlowTheme.of(context).titleMedium.override(
                                      fontFamily: 'Inter Tight',
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                ),
                                if (!_model.isLoading)
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                                    child: Text(
                                      'Choose a CSV file to upload trip data',
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        fontFamily: 'Inter',
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ),
                                if (_model.isLoading)
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        FlutterFlowTheme.of(context).primary,
                                      ),
                                    ),
                                  ),
                                if (!_model.isLoading)
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                                    child: FFButtonWidget(
                                      onPressed: _pickAndProcessCSV,
                                      text: 'Choose File',
                                      options: FFButtonOptions(
                                        width: double.infinity,
                                        height: 50.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                        iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                        color: FlutterFlowTheme.of(context).primary,
                                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                          fontFamily: 'Inter Tight',
                                          color: Colors.white,
                                          letterSpacing: 0.0,
                                        ),
                                        elevation: 3.0,
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_model.uploadStatus.isNotEmpty)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: _model.uploadStatus.contains('Error') || _model.uploadStatus.contains('errors')
                                  ? FlutterFlowTheme.of(context).error.withOpacity(0.1)
                                  : FlutterFlowTheme.of(context).success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: _model.uploadStatus.contains('Error') || _model.uploadStatus.contains('errors')
                                    ? FlutterFlowTheme.of(context).error
                                    : FlutterFlowTheme.of(context).success,
                                width: 1.0,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
                              child: Text(
                                _model.uploadStatus,
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Inter',
                                  color: _model.uploadStatus.contains('Error') || _model.uploadStatus.contains('errors')
                                      ? FlutterFlowTheme.of(context).error
                                      : FlutterFlowTheme.of(context).success,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 0.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CSV Format Example:',
                                  style: FlutterFlowTheme.of(context).titleSmall.override(
                                    fontFamily: 'Inter Tight',
                                    letterSpacing: 0.0,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                                  child: Text(
                                    'Bali Adventure,1500,Bali Indonesia,Explore the beautiful beaches and temples,https://example.com/bali.jpg\nTokyo City Tour,2000,Tokyo Japan,Discover modern culture and traditions,https://example.com/tokyo.jpg',
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: 'Courier New',
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
}
