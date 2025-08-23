import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/pages/national_id_upload/national_id_upload_page.dart';
import '/utils/kyc_utils.dart';
import 'book_trip_model.dart';
export 'book_trip_model.dart';

class BookTripWidget extends StatefulWidget {
  const BookTripWidget({
    super.key,
    required this.tripRecord,
  });

  final TripsRecord tripRecord;

  static String routeName = 'book_trip';
  static String routePath = '/book_trip';

  @override
  State<BookTripWidget> createState() => _BookTripWidgetState();
}

class _BookTripWidgetState extends State<BookTripWidget> {
  late BookTripModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BookTripModel());

    _model.travelerCountTextController ??= TextEditingController(text: '1');
    _model.travelerCountFocusNode ??= FocusNode();

    _model.specialRequestsTextController ??= TextEditingController();
    _model.specialRequestsFocusNode ??= FocusNode();

    _model.travelerNamesTextController ??= TextEditingController();
    _model.travelerNamesFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  double get totalAmount {
    final travelerCount = int.tryParse(_model.travelerCountTextController.text) ?? 1;
    return widget.tripRecord.price.toDouble() * travelerCount;
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
          backgroundColor: Color(0xFFD76B30),
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
            'Book Trip',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
            ),
          ),
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Trip Summary Card
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Color(0x1A000000),
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Trip image
                        if (widget.tripRecord.image.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.tripRecord.image,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  height: 200,
                                  color: FlutterFlowTheme.of(context).alternate,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                    size: 50,
                                  ),
                                );
                              },
                            ),
                          ),
                        SizedBox(height: 16),
                        
                        // Trip title and price
                        Text(
                          widget.tripRecord.title,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                        ),
                        SizedBox(height: 8),
                        
                        Text(
                          'Price per person: EGP ${widget.tripRecord.price.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFD76B30),
                          ),
                        ),
                        
                        if (widget.tripRecord.description.isNotEmpty) ...[
                          SizedBox(height: 12),
                          Text(
                            widget.tripRecord.description,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Booking Details Form
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Color(0x1A000000),
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking Details',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Number of travelers
                        Text(
                          'Number of Travelers',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _model.travelerCountTextController,
                          focusNode: _model.travelerCountFocusNode,
                          onChanged: (_) => setState(() {}),
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Enter number of travelers',
                            hintStyle: GoogleFonts.poppins(
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFFD76B30),
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 0.0),
                          ),
                          style: GoogleFonts.poppins(
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter number of travelers';
                            }
                            final count = int.tryParse(value);
                            if (count == null || count < 1) {
                              return 'Please enter a valid number (minimum 1)';
                            }
                            if (count > 10) {
                              return 'Maximum 10 travelers per booking';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // Traveler names
                        Text(
                          'Traveler Names',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Enter names separated by commas (e.g., John Doe, Jane Smith)',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _model.travelerNamesTextController,
                          focusNode: _model.travelerNamesFocusNode,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Enter traveler names',
                            hintStyle: GoogleFonts.poppins(
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFFD76B30),
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 0.0),
                          ),
                          style: GoogleFonts.poppins(
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter traveler names';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // Special requests
                        Text(
                          'Special Requests (Optional)',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _model.specialRequestsTextController,
                          focusNode: _model.specialRequestsFocusNode,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Any special requirements or requests',
                            hintStyle: GoogleFonts.poppins(
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFFD76B30),
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 0.0),
                          ),
                          style: GoogleFonts.poppins(
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),

                // Price Summary
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Color(0x1A000000),
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price Summary',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                        ),
                        SizedBox(height: 12),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Price per person:',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                            ),
                            Text(
                              'EGP ${widget.tripRecord.price.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Number of travelers:',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                            ),
                            Text(
                              _model.travelerCountTextController.text.isNotEmpty 
                                  ? _model.travelerCountTextController.text 
                                  : '1',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                            ),
                          ],
                        ),
                        
                        Divider(thickness: 1),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount:',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                            ),
                            Text(
                              'EGP ${totalAmount.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD76B30),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Proceed to Payment Button
                Padding(
                  padding: EdgeInsets.all(16),
                  child: FFButtonWidget(
                    onPressed: () async {
                      if (!loggedIn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please sign in to book a trip'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Check if user has valid National ID
                      final hasValidId = await KycUtils.hasValidNationalId(currentUserUid!);
                      if (!hasValidId) {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NationalIdUploadPage(isRequired: true),
                          ),
                        );
                        
                        // If user didn't upload ID, don't proceed
                        if (result != true) {
                          return;
                        }
                      }

                      // Validate form
                      final travelerCount = int.tryParse(_model.travelerCountTextController.text);
                      if (travelerCount == null || travelerCount < 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter a valid number of travelers'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (_model.travelerNamesTextController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter traveler names'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Navigate to payment page
                      context.pushNamed(
                        'payment',
                        extra: {
                          'tripRecord': widget.tripRecord,
                          'totalAmount': totalAmount,
                        },
                      );
                    },
                    text: 'Proceed to Payment',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 50,
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      color: Color(0xFFD76B30),
                      textStyle: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      elevation: 3,
                      borderRadius: BorderRadius.circular(8),
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
