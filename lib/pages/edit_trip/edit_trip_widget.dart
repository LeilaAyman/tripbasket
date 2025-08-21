import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'edit_trip_model.dart';
export 'edit_trip_model.dart';

class EditTripWidget extends StatefulWidget {
  const EditTripWidget({
    super.key,
    required this.tripRef,
  });

  final String tripRef;

  static String routeName = 'edit_trip';
  static String routePath = '/edit-trip';

  @override
  State<EditTripWidget> createState() => _EditTripWidgetState();
}

class _EditTripWidgetState extends State<EditTripWidget> {
  late EditTripModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  DocumentReference? tripDocRef;
  TripsRecord? currentTrip;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditTripModel());
    
    // Get trip reference
    tripDocRef = FirebaseFirestore.instance.collection('trips').doc(widget.tripRef);
    
    _initializeControllers();
    _loadTripData();
  }

  void _initializeControllers() {
    _model.titleTextController ??= TextEditingController();
    _model.titleFocusNode ??= FocusNode();
    
    _model.locationTextController ??= TextEditingController();
    _model.locationFocusNode ??= FocusNode();
    
    _model.priceTextController ??= TextEditingController();
    _model.priceFocusNode ??= FocusNode();
    
    _model.imageUrlTextController ??= TextEditingController();
    _model.imageUrlFocusNode ??= FocusNode();
    
    _model.descriptionTextController ??= TextEditingController();
    _model.descriptionFocusNode ??= FocusNode();
    
    _model.itineraryTextController ??= TextEditingController();
    _model.itineraryFocusNode ??= FocusNode();
    
    _model.availableSeatsTextController ??= TextEditingController();
    _model.availableSeatsFocusNode ??= FocusNode();
  }

  Future<void> _loadTripData() async {
    try {
      final tripDoc = await tripDocRef!.get();
      if (tripDoc.exists) {
        currentTrip = TripsRecord.fromSnapshot(tripDoc);
        
        // Populate form fields
        setState(() {
          _model.titleTextController.text = currentTrip!.title;
          _model.locationTextController.text = currentTrip!.location;
          _model.priceTextController.text = currentTrip!.price.toString();
          _model.imageUrlTextController.text = currentTrip!.image;
          _model.descriptionTextController.text = currentTrip!.description;
          _model.availableSeatsTextController.text = currentTrip!.availableSeats.toString();
          
          // Join itinerary array with ' | '
          _model.itineraryTextController.text = currentTrip!.itenarary.join(' | ');
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading trip data: $e'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Edit Trip',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          ),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 0.0),
              child: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 30.0,
                borderWidth: 1.0,
                buttonSize: 60.0,
                icon: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 30.0,
                ),
                onPressed: () async {
                  await _updateTrip();
                },
              ),
            ),
          ],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: currentTrip == null
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Preview
                        Container(
                          width: double.infinity,
                          height: 200.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).alternate,
                              width: 2.0,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: _model.imageUrlTextController.text.isNotEmpty
                                ? Image.network(
                                    _model.imageUrlTextController.text,
                                    width: double.infinity,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildImagePlaceholder();
                                    },
                                  )
                                : _buildImagePlaceholder(),
                          ),
                        ),
                        
                        SizedBox(height: 24.0),
                        
                        // Trip Title
                        Text(
                          'Trip Title',
                          style: FlutterFlowTheme.of(context).titleMedium.override(
                                font: GoogleFonts.poppins(
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          controller: _model.titleTextController,
                          focusNode: _model.titleFocusNode,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Enter trip title...',
                            labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                  font: GoogleFonts.inter(
                                    letterSpacing: 0.0,
                                  ),
                                ),
                            hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                  font: GoogleFonts.inter(
                                    letterSpacing: 0.0,
                                  ),
                                ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                          ),
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(
                                  letterSpacing: 0.0,
                                ),
                              ),
                          validator: _model.titleTextControllerValidator.asValidator(context),
                        ),
                        
                        SizedBox(height: 16.0),
                        
                        // Location
                        Text(
                          'Location',
                          style: FlutterFlowTheme.of(context).titleMedium.override(
                                font: GoogleFonts.poppins(
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          controller: _model.locationTextController,
                          focusNode: _model.locationFocusNode,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Enter destination...',
                            labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                  font: GoogleFonts.inter(
                                    letterSpacing: 0.0,
                                  ),
                                ),
                            hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                  font: GoogleFonts.inter(
                                    letterSpacing: 0.0,
                                  ),
                                ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                          ),
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(
                                  letterSpacing: 0.0,
                                ),
                              ),
                          validator: _model.locationTextControllerValidator.asValidator(context),
                        ),
                        
                        SizedBox(height: 16.0),
                        
                        // Price & Available Seats Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Price (USD)',
                                    style: FlutterFlowTheme.of(context).titleMedium.override(
                                          font: GoogleFonts.poppins(
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                  ),
                                  SizedBox(height: 8.0),
                                  TextFormField(
                                    controller: _model.priceTextController,
                                    focusNode: _model.priceFocusNode,
                                    autofocus: false,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText: '\$0',
                                      labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                            font: GoogleFonts.inter(
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context).alternate,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context).primary,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      filled: true,
                                      fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                    ),
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          font: GoogleFonts.inter(
                                            letterSpacing: 0.0,
                                          ),
                                        ),
                                    keyboardType: TextInputType.number,
                                    validator: _model.priceTextControllerValidator.asValidator(context),
                                  ),
                                ],
                              ),
                            ),
                            
                            SizedBox(width: 16.0),
                            
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Available Seats',
                                    style: FlutterFlowTheme.of(context).titleMedium.override(
                                          font: GoogleFonts.poppins(
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                  ),
                                  SizedBox(height: 8.0),
                                  TextFormField(
                                    controller: _model.availableSeatsTextController,
                                    focusNode: _model.availableSeatsFocusNode,
                                    autofocus: false,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText: '0',
                                      labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                            font: GoogleFonts.inter(
                                              letterSpacing: 0.0,
                                            ),
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context).alternate,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context).primary,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      filled: true,
                                      fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                    ),
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          font: GoogleFonts.inter(
                                            letterSpacing: 0.0,
                                          ),
                                        ),
                                    keyboardType: TextInputType.number,
                                    validator: _model.availableSeatsTextControllerValidator.asValidator(context),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 16.0),
                        
                        // Image URL
                        Text(
                          'Image URL',
                          style: FlutterFlowTheme.of(context).titleMedium.override(
                                font: GoogleFonts.poppins(
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          controller: _model.imageUrlTextController,
                          focusNode: _model.imageUrlFocusNode,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'https://example.com/image.jpg',
                            labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                  font: GoogleFonts.inter(
                                    letterSpacing: 0.0,
                                  ),
                                ),
                            hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                  font: GoogleFonts.inter(
                                    letterSpacing: 0.0,
                                  ),
                                ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                          ),
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(
                                  letterSpacing: 0.0,
                                ),
                              ),
                          onChanged: (value) {
                            setState(() {
                              // Trigger rebuild to update image preview
                            });
                          },
                          validator: _model.imageUrlTextControllerValidator.asValidator(context),
                        ),
                        
                        SizedBox(height: 16.0),
                        
                        // Description
                        Text(
                          'Description',
                          style: FlutterFlowTheme.of(context).titleMedium.override(
                                font: GoogleFonts.poppins(
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          controller: _model.descriptionTextController,
                          focusNode: _model.descriptionFocusNode,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Describe your amazing trip...',
                            labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                  font: GoogleFonts.inter(
                                    letterSpacing: 0.0,
                                  ),
                                ),
                            alignLabelWithHint: true,
                            hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                  font: GoogleFonts.inter(
                                    letterSpacing: 0.0,
                                  ),
                                ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                          ),
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(
                                  letterSpacing: 0.0,
                                ),
                              ),
                          maxLines: 4,
                          validator: _model.descriptionTextControllerValidator.asValidator(context),
                        ),
                        
                        SizedBox(height: 16.0),
                        
                        // Itinerary
                        Text(
                          'Itinerary',
                          style: FlutterFlowTheme.of(context).titleMedium.override(
                                font: GoogleFonts.poppins(
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          'Separate each day with " | " (e.g., Day 1: Arrival | Day 2: City Tour)',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                font: GoogleFonts.inter(
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  letterSpacing: 0.0,
                                ),
                              ),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          controller: _model.itineraryTextController,
                          focusNode: _model.itineraryFocusNode,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Day 1: Arrival and check-in | Day 2: City exploration...',
                            labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                  font: GoogleFonts.inter(
                                    letterSpacing: 0.0,
                                  ),
                                ),
                            alignLabelWithHint: true,
                            hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                  font: GoogleFonts.inter(
                                    letterSpacing: 0.0,
                                  ),
                                ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                          ),
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.inter(
                                  letterSpacing: 0.0,
                                ),
                              ),
                          maxLines: 6,
                          validator: _model.itineraryTextControllerValidator.asValidator(context),
                        ),
                        
                        SizedBox(height: 32.0),
                        
                        // Update Trip Button
                        FFButtonWidget(
                          onPressed: () async {
                            await _updateTrip();
                          },
                          text: 'Update Trip',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 54.0,
                            padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.poppins(
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            elevation: 3.0,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        
                        SizedBox(height: 24.0),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 200.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            color: FlutterFlowTheme.of(context).secondaryText,
            size: 64.0,
          ),
          SizedBox(height: 8.0),
          Text(
            'Enter image URL to preview',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateTrip() async {
    // Validate form
    if (_model.titleTextController.text.isEmpty ||
        _model.locationTextController.text.isEmpty ||
        _model.priceTextController.text.isEmpty ||
        _model.descriptionTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return;
    }

    try {
      // Parse price
      int price = int.parse(_model.priceTextController.text);
      int availableSeats = int.parse(_model.availableSeatsTextController.text.isEmpty ? '0' : _model.availableSeatsTextController.text);
      
      // Parse itinerary
      List<String> itineraryList = _model.itineraryTextController.text
          .split(' | ')
          .map((day) => day.trim())
          .where((day) => day.isNotEmpty)
          .toList();

      // Update trip data
      await tripDocRef!.update({
        'title': _model.titleTextController.text,
        'location': _model.locationTextController.text,
        'price': price,
        'description': _model.descriptionTextController.text,
        'image': _model.imageUrlTextController.text.isEmpty 
            ? 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800&h=600&fit=crop'
            : _model.imageUrlTextController.text,
        'itenarary': itineraryList,
        'available_seats': availableSeats,
        'modified_at': DateTime.now(),
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Trip updated successfully!'),
          backgroundColor: FlutterFlowTheme.of(context).success,
        ),
      );

      // Navigate back
      context.pop();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating trip: $e'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }
}
