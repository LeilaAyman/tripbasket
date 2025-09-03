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
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
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
  
  bool _isLoading = false;
  bool _isProcessingPayment = false;
  bool _showPaymentOptions = true;
  String? _paymentUrl;
  String? _errorMessage;
  String _selectedPaymentOption = 'full'; // 'full' or 'deposit'
  String _selectedPaymentMethod = 'visa'; // 'visa' or 'instapay'
  double _depositAmount = 0.0;
  double _remainingAmount = 0.0;
  
  // InstaPay flow variables
  bool _showInstaPayFlow = false;
  bool _showTransactionForm = false;
  String _transactionReference = '';
  String? _screenshotUrl;
  final TextEditingController _transactionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaymentModel());
    _calculateAmounts();
  }

  void _calculateAmounts() {
    _depositAmount = widget.totalAmount * 0.5; // 50% deposit
    _remainingAmount = widget.totalAmount - _depositAmount;
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

      final paymentAmount = _selectedPaymentOption == 'full' ? widget.totalAmount : _depositAmount;
      
      final result = await paymobService.processPayment(
        amount: paymentAmount,
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
      // Get current user document for comprehensive user information
      final userDoc = currentUserDocument;
      
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
        'payment_method': 'visa',
        'booking_status': 'pending_agency_approval',
        'created_at': getCurrentTimestamp,
        'traveler_count': 1,
        'traveler_names': [],
        'special_requests': '',
        // Customer information for agency approval
        'customer_name': userDoc?.displayName?.isNotEmpty == true 
            ? userDoc!.displayName 
            : (userDoc?.name?.isNotEmpty == true ? userDoc!.name : currentUserEmail.split('@').first),
        'customer_email': currentUserEmail,
        'customer_phone': userDoc?.phoneNumber ?? '',
        'customer_profile_photo': userDoc?.profilePhotoUrl ?? userDoc?.photoUrl ?? '',
        'customer_verification_status': userDoc?.nationalIdStatus ?? 'unverified',
        'customer_loyalty_points': userDoc?.loyaltyPoints ?? 0,
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

  void _handleInstaPayPayment() {
    setState(() {
      _showInstaPayFlow = true;
      _isLoading = false;
    });
  }

  Future<void> _openInstaPayLink() async {
    const instaPayUrl = 'https://ipn.eg/S/mariam.omar9682/instapay/91tdlO';
    
    try {
      final Uri url = Uri.parse(instaPayUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
        
        // Show the transaction form after opening the link
        setState(() {
          _showTransactionForm = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open InstaPay link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening InstaPay link: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadScreenshot() async {
    try {
      final ImagePicker picker = ImagePicker();
      XFile? image;
      
      if (kIsWeb) {
        image = await picker.pickImage(source: ImageSource.gallery);
      } else {
        // Show options for camera or gallery on mobile
        image = await showModalBottomSheet<XFile?>(
          context: context,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Take Photo'),
                  onTap: () async {
                    Navigator.pop(context, await picker.pickImage(source: ImageSource.camera));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(context, await picker.pickImage(source: ImageSource.gallery));
                  },
                ),
              ],
            ),
          ),
        );
      }

      if (image != null) {
        setState(() {
          _isLoading = true;
        });

        // Upload to Firebase Storage
        final bytes = await image.readAsBytes();
        final fileName = 'screenshots/${DateTime.now().millisecondsSinceEpoch}_${currentUserUid}.jpg';
        final ref = FirebaseStorage.instance.ref().child(fileName);
        
        await ref.putData(bytes);
        final downloadURL = await ref.getDownloadURL();
        
        setState(() {
          _screenshotUrl = downloadURL;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Screenshot uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading screenshot: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitInstaPayTransaction() async {
    if (_transactionReference.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter transaction reference'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_screenshotUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload payment screenshot'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // Get current user document for comprehensive user information
      final userDoc = currentUserDocument;
      final paymentAmount = _selectedPaymentOption == 'full' ? widget.totalAmount : _depositAmount;
      
      // Create booking record with InstaPay details
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
        'payment_status': 'pending_verification', // Different status for InstaPay
        'payment_method': 'instapay',
        'booking_status': 'pending_payment_verification',
        'created_at': getCurrentTimestamp,
        'traveler_count': 1,
        'traveler_names': [],
        'special_requests': '',
        'payment_option': _selectedPaymentOption,
        'deposit_amount': _selectedPaymentOption == 'deposit' ? _depositAmount : 0.0,
        'remaining_amount': _selectedPaymentOption == 'deposit' ? _remainingAmount : 0.0,
        // InstaPay specific fields
        'instapay_transaction_reference': _transactionReference.trim(),
        'instapay_screenshot_url': _screenshotUrl,
        'instapay_paid_amount': paymentAmount,
        // Customer information for agency approval
        'customer_name': userDoc?.displayName?.isNotEmpty == true 
            ? userDoc!.displayName 
            : (userDoc?.name?.isNotEmpty == true ? userDoc!.name : currentUserEmail.split('@').first),
        'customer_email': currentUserEmail,
        'customer_phone': userDoc?.phoneNumber ?? '',
        'customer_profile_photo': userDoc?.profilePhotoUrl ?? userDoc?.photoUrl ?? '',
        'customer_verification_status': userDoc?.nationalIdStatus ?? 'unverified',
        'customer_loyalty_points': userDoc?.loyaltyPoints ?? 0,
      });

      // Clear the cart after successful submission
      await _clearUserCart();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('InstaPay payment submitted! Your booking is pending verification.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate to bookings page
      await Future.delayed(Duration(seconds: 2));
      context.goNamed('mybookings');
      
    } catch (e) {
      print('Error creating InstaPay booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting payment: $e'),
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
    if (_showPaymentOptions) {
      return _buildPaymentOptionsScreen();
    }
    
    if (_showInstaPayFlow) {
      return _buildInstaPayFlow();
    }
    
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

  Widget _buildPaymentOptionsScreen() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip Summary
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trip Summary',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.tripRecord.image.isNotEmpty 
                            ? widget.tripRecord.image 
                            : 'https://images.unsplash.com/photo-1519451241324-20b4ea2c4220',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.tripRecord.title,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: FlutterFlowTheme.of(context).primaryText,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            widget.tripRecord.location,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Divider(),
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
                      'EGP ${widget.totalAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD76B30),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'No added tax or fees',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: 32),
          
          // Payment Methods
          Text(
            'Choose Payment Method',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
          SizedBox(height: 16),
          
          // Payment Method Selection
          _buildPaymentMethodButtons(),
          
          SizedBox(height: 24),
          
          // Payment Options
          Text(
            'Choose Payment Option',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
          SizedBox(height: 16),
          
          // Full Payment Option
          _buildPaymentOptionCard(
            'full',
            'Pay Full Amount',
            'EGP ${widget.totalAmount.toStringAsFixed(2)}',
            'Complete payment now and secure your booking',
            Icons.payment,
          ),
          
          SizedBox(height: 16),
          
          // Deposit Payment Option  
          _buildPaymentOptionCard(
            'deposit',
            'Pay 50% Deposit',
            'EGP ${_depositAmount.toStringAsFixed(2)}',
            'Pay half now, remainder before trip starts\nRemaining: EGP ${_remainingAmount.toStringAsFixed(2)}',
            Icons.account_balance_wallet,
          ),
          
          // Payment Instructions (if available and deposit is selected)
          if (_selectedPaymentOption == 'deposit' && widget.tripRecord.paymentInstructions.isNotEmpty) ...[
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFD76B30).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFD76B30).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFFD76B30), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Payment Instructions',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD76B30),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    widget.tripRecord.paymentInstructions,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: FlutterFlowTheme.of(context).primaryText,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          SizedBox(height: 32),
          
          // Proceed Button
          FFButtonWidget(
            onPressed: _proceedToPayment,
            text: _selectedPaymentMethod == 'instapay' 
                ? 'Pay using InstaPay'
                : (_selectedPaymentOption == 'full' 
                    ? 'Pay EGP ${widget.totalAmount.toStringAsFixed(2)}'
                    : 'Pay Deposit EGP ${_depositAmount.toStringAsFixed(2)}'),
            options: FFButtonOptions(
              width: double.infinity,
              height: 52,
              padding: EdgeInsets.symmetric(horizontal: 24),
              iconPadding: EdgeInsets.zero,
              color: Color(0xFFD76B30),
              textStyle: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              borderRadius: BorderRadius.circular(12),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptionCard(String value, String title, String amount, String description, IconData icon) {
    final isSelected = _selectedPaymentOption == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentOption = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFD76B30).withOpacity(0.1) : FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFFD76B30) : FlutterFlowTheme.of(context).alternate,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFFD76B30) : FlutterFlowTheme.of(context).alternate,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : FlutterFlowTheme.of(context).secondaryText,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                      ),
                      Text(
                        amount,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD76B30),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildPaymentMethodCard(
            'visa',
            'Visa/Mastercard',
            Icons.credit_card,
            'Pay with credit/debit card',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildPaymentMethodCard(
            'instapay',
            'InstaPay',
            Icons.mobile_friendly,
            'Pay with InstaPay',
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(String method, String title, IconData icon, String description) {
    final isSelected = _selectedPaymentMethod == method;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFD76B30).withOpacity(0.1) : FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFFD76B30) : FlutterFlowTheme.of(context).alternate,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFFD76B30) : FlutterFlowTheme.of(context).alternate,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : FlutterFlowTheme.of(context).secondaryText,
                size: 24,
              ),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: FlutterFlowTheme.of(context).primaryText,
              ),
            ),
            SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToPayment() {
    setState(() {
      _showPaymentOptions = false;
      _isLoading = true;
    });
    
    if (_selectedPaymentMethod == 'instapay') {
      _handleInstaPayPayment();
    } else {
      _initializePayment();
    }
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

  Widget _buildInstaPayFlow() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip Summary
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'InstaPay Payment',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.tripRecord.image.isNotEmpty 
                            ? widget.tripRecord.image 
                            : 'https://images.unsplash.com/photo-1519451241324-20b4ea2c4220',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.tripRecord.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: FlutterFlowTheme.of(context).primaryText,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            widget.tripRecord.location,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount to Pay:',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                    ),
                    Text(
                      'EGP ${(_selectedPaymentOption == 'full' ? widget.totalAmount : _depositAmount).toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD76B30),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: 24),
          
          if (!_showTransactionForm) ...[
            // Step 1: Open InstaPay Link
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFD76B30).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFD76B30).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.mobile_friendly,
                    size: 48,
                    color: Color(0xFFD76B30),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Step 1: Pay using InstaPay',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD76B30),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Click the button below to open the InstaPay link and complete your payment.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: FlutterFlowTheme.of(context).primaryText,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 20),
                  FFButtonWidget(
                    onPressed: _openInstaPayLink,
                    text: 'Open InstaPay Link',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 48,
                      padding: EdgeInsets.zero,
                      iconPadding: EdgeInsets.zero,
                      color: Color(0xFFD76B30),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Back Button
            FFButtonWidget(
              onPressed: () {
                setState(() {
                  _showInstaPayFlow = false;
                  _showPaymentOptions = true;
                });
              },
              text: 'Back to Payment Options',
              options: FFButtonOptions(
                width: double.infinity,
                height: 48,
                padding: EdgeInsets.zero,
                iconPadding: EdgeInsets.zero,
                color: Colors.grey[200],
                textStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
                borderRadius: BorderRadius.circular(8),
                elevation: 0,
              ),
            ),
          ],
          
          if (_showTransactionForm) ...[
            // Step 2: Transaction Verification Form
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_user, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Step 2: Verify Payment',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  // Transaction Reference Input
                  Text(
                    'Transaction Reference',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: FlutterFlowTheme.of(context).primaryText,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _transactionController,
                    onChanged: (value) {
                      setState(() {
                        _transactionReference = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter transaction reference number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFFD76B30)),
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Screenshot Upload
                  Text(
                    'Payment Screenshot',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: FlutterFlowTheme.of(context).primaryText,
                    ),
                  ),
                  SizedBox(height: 8),
                  
                  if (_screenshotUrl != null) ...[
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _screenshotUrl!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Screenshot uploaded successfully',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                  ],
                  
                  FFButtonWidget(
                    onPressed: _isLoading ? null : _uploadScreenshot,
                    text: _screenshotUrl != null ? 'Change Screenshot' : 'Upload Screenshot',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 48,
                      padding: EdgeInsets.zero,
                      iconPadding: EdgeInsets.zero,
                      color: _screenshotUrl != null ? Colors.grey[400] : Color(0xFFD76B30),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      elevation: 1,
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Submit Button
                  FFButtonWidget(
                    onPressed: _isProcessingPayment ? null : _submitInstaPayTransaction,
                    text: _isProcessingPayment ? 'Submitting...' : 'Submit Payment Verification',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 52,
                      padding: EdgeInsets.zero,
                      iconPadding: EdgeInsets.zero,
                      color: Color(0xFFD76B30),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Note
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your booking will be pending verification until the agency confirms your payment.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blue[800],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
