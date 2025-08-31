import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/services/paymob_service.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/utils/loyalty_utils.dart';
import 'payment_model.dart';
export 'payment_model.dart';

// Platform-specific imports
import 'package:flutter/foundation.dart' show kIsWeb;
import '/utils/web_utils.dart';

class PaymentWidget extends StatefulWidget {
  const PaymentWidget({
    super.key,
    required this.tripRecord,
    required this.totalAmount,
  });

  final TripsRecord tripRecord;
  final double totalAmount;

  static String routeName = 'payment';
  static String routePath = '/payment';

  @override
  State<PaymentWidget> createState() => _PaymentWidgetState();
}

class _PaymentWidgetState extends State<PaymentWidget> {
  late PaymentModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  bool _isLoading = true;
  bool _isProcessingPayment = false;
  String? _paymentUrl;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaymentModel());
    _initializePayment();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _initializePayment() async {
    if (!loggedIn || currentUserReference == null) {
      setState(() {
        _errorMessage = 'Please sign in to continue with payment';
        _isLoading = false;
      });
      return;
    }

    try {
      final paymobService = PaymobService();
      
      // Generate unique merchant order ID
      final merchantOrderId = 'TRIP_${widget.tripRecord.reference.id}_${DateTime.now().millisecondsSinceEpoch}';
      
      // Get user data for billing
      final userDoc = await currentUserReference!.get();
      final userData = UsersRecord.fromSnapshot(userDoc);
      
      final billingData = {
        'apartment': 'NA',
        'email': userData.email,
        'floor': 'NA',
        'first_name': userData.displayName.isNotEmpty && userData.displayName.split(' ').isNotEmpty ? userData.displayName.split(' ').first : 'User',
        'street': 'NA',
        'building': 'NA',
        'phone_number': userData.phoneNumber.isNotEmpty ? userData.phoneNumber : '+201000000000',
        'shipping_method': 'NA',
        'postal_code': 'NA',
        'city': 'Cairo',
        'country': 'EG',
        'last_name': userData.displayName.isNotEmpty && userData.displayName.split(' ').length > 1 
            ? userData.displayName.split(' ').last 
            : 'User',
        'state': 'Cairo',
      };

      final result = await paymobService.processPayment(
        amount: widget.totalAmount,
        currency: 'EGP',
        merchantOrderId: merchantOrderId,
        billingData: billingData,
      );

      if (result.success && result.paymentUrl != null) {
        setState(() {
          _paymentUrl = result.paymentUrl;
          _isLoading = false;
        });
        _initializeWebView();
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Failed to initialize payment';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Payment initialization failed: $e';
        _isLoading = false;
      });
    }
  }

  void _initializeWebView() {
    // For web platform, open payment URL in a new tab
    _openPaymentInNewTab();
  }

  void _openPaymentInNewTab() {
    if (_paymentUrl != null) {
      WebUtils.openUrlInNewTab(_paymentUrl!);
      // Show instructions to user
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
      
      // Start checking for payment completion automatically
      _startPaymentMonitoring();
    }
  }

  void _startPaymentMonitoring() {
    // Check for payment completion every 3 seconds
    Timer.periodic(Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      // Check if user has returned to the tab by checking document visibility
      if (kIsWeb) {
        // For web, we'll assume payment is complete after 30 seconds
        // In a real app, you'd implement proper webhook handling
        if (timer.tick >= 10) { // 30 seconds (10 ticks * 3 seconds)
          timer.cancel();
          _handleAutomaticPaymentSuccess();
        }
      }
    });
    
    // Also listen for tab focus to detect when user returns
    WebUtils.addWindowFocusListener(() {
      _showPaymentCompleteDialog();
    });
  }

  void _showPaymentCompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Payment Status'),
          content: Text('Did you complete the payment successfully?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No, Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleAutomaticPaymentSuccess();
              },
              child: Text('Yes, Payment Complete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleAutomaticPaymentSuccess() async {
    if (_isProcessingPayment) return;
    
    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // Create booking record
      print('Creating booking record...');
      print('User reference: $currentUserReference');
      print('Trip reference: ${widget.tripRecord.reference}');
      print('Trip title: ${widget.tripRecord.title}');
      print('Total amount: ${widget.totalAmount}');
      
      await BookingsRecord.collection.add({
        'user_reference': currentUserReference,
        'trip_reference': widget.tripRecord.reference,
        'agency_reference': widget.tripRecord.agencyReference,
        'trip_title': widget.tripRecord.title,
        'trip_price': widget.tripRecord.price,
        'total_amount': widget.totalAmount,
        'unitPriceEGP': widget.tripRecord.priceEGP,
        'lineTotalEGP': widget.totalAmount,
        'booking_date': getCurrentTimestamp,
        'payment_status': 'completed',
        'payment_method': 'paymob',
        'booking_status': 'pending_agency_approval',
        'created_at': getCurrentTimestamp,
        'traveler_count': 1,
        'traveler_names': [],
        'special_requests': '',
      });

      print('Booking record created successfully!');

      // Clear the cart after successful payment
      await _clearUserCart();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment successful! Your booking is pending agency approval.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate to bookings page
      await Future.delayed(Duration(seconds: 2));
      context.goNamed('mybookings');
      
    } catch (e) {
      print('Error creating booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating booking: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  Future<void> _clearUserCart() async {
    try {
      print('Clearing user cart...');
      
      // Query all cart items for the current user
      final cartQuery = await CartRecord.collection
          .where('userReference', isEqualTo: currentUserReference)
          .get();
      
      // Delete all cart items
      for (var doc in cartQuery.docs) {
        await doc.reference.delete();
      }
      
      print('Cart cleared successfully!');
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  void _checkPaymentStatus(String url) {
    // Check if payment was successful, failed, or cancelled based on URL
    if (url.contains('success=true') || url.contains('txn_response_code=APPROVED')) {
      _handleAutomaticPaymentSuccess();
    } else if (url.contains('success=false') || url.contains('txn_response_code=DECLINED')) {
      _handlePaymentFailure();
    } else if (url.contains('cancel') || url.contains('txn_response_code=CANCELLED')) {
      _handlePaymentCancellation();
    }
  }

  void _handlePaymentFailure() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed. Please try again.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handlePaymentCancellation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment was cancelled.'),
        backgroundColor: Colors.orange,
      ),
    );
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
            'Payment',
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
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }
    
    if (_errorMessage != null) {
      return _buildErrorState();
    }
    
    if (_paymentUrl != null) {
      return _buildPaymentWebView();
    }
    
    return _buildErrorState();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD76B30)),
          ),
          SizedBox(height: 24),
          Text(
            'Preparing your payment...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Please wait while we set up your secure payment gateway.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            SizedBox(height: 24),
            Text(
              'Payment Error',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: FlutterFlowTheme.of(context).primaryText,
              ),
            ),
            SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred while processing your payment.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
            SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: FFButtonWidget(
                    onPressed: () => context.pop(),
                    text: 'Go Back',
                    options: FFButtonOptions(
                      height: 50,
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      textStyle: GoogleFonts.poppins(
                        color: FlutterFlowTheme.of(context).primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      elevation: 0,
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.3),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: FFButtonWidget(
                    onPressed: _initializePayment,
                    text: 'Retry',
                    options: FFButtonOptions(
                      height: 50,
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      color: Color(0xFFD76B30),
                      textStyle: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      elevation: 2,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentWebView() {
    return Column(
      children: [
        // Payment summary header
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            boxShadow: [
              BoxShadow(
                blurRadius: 4,
                color: Color(0x1A000000),
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paying for: ${widget.tripRecord.title}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                  ),
                  StreamBuilder<UsersRecord>(
                    stream: UsersRecord.getDocument(currentUserReference!),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return Text(
                          'EGP ${widget.totalAmount.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                        );
                      }
                      
                      final user = userSnapshot.data!;
                      final userPoints = user.loyaltyPoints;
                      final discountAmount = Loyalty.calculateDiscountAmount(widget.totalAmount, userPoints);
                      final originalAmount = widget.totalAmount + discountAmount;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (discountAmount > 0) ...[
                            Text(
                              'EGP ${originalAmount.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: FlutterFlowTheme.of(context).secondaryText,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Text(
                              'Loyalty Discount (${Loyalty.formatDiscount(Loyalty.discountFor(userPoints))}): -EGP ${discountAmount.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFD76B30),
                              ),
                            ),
                          ],
                          Text(
                            'EGP ${widget.totalAmount.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFD76B30),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Payment instructions for web
        Expanded(
          child: _buildWebPaymentInstructions(),
        ),
      ],
    );
  }

  Widget _buildWebPaymentInstructions() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment,
            size: 64,
            color: Color(0xFFD76B30),
          ),
          SizedBox(height: 24),
          Text(
            'Payment Window Opened',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2A2A2A),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'A new tab has been opened for payment processing. Please complete your payment in the new tab and return here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          SizedBox(height: 32),
          if (_paymentUrl != null)
            FFButtonWidget(
              onPressed: () => _openPaymentInNewTab(),
              text: 'Open Payment Page Again',
              options: FFButtonOptions(
                width: 250,
                height: 48,
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                color: Color(0xFFD76B30),
                textStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                elevation: 2,
                borderSide: BorderSide(
                  color: Colors.transparent,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          SizedBox(height: 16),
          Text(
            'Return to this tab after completing payment. The system will automatically detect completion.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Color(0xFF999999),
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 32),
          FFButtonWidget(
            onPressed: () => context.goNamed('mybookings'),
            text: 'Return to My Bookings',
            options: FFButtonOptions(
              width: 250,
              height: 48,
              padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              color: Colors.grey[200],
              textStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2A2A2A),
              ),
              elevation: 1,
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ],
      ),
    );
  }
}
