import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/utils/loyalty_utils.dart';
import '/utils/loyalty_redemption.dart';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'cart_model.dart';
export 'cart_model.dart';

class CartWidget extends StatefulWidget {
  const CartWidget({super.key});

  static String routeName = 'cart';
  static String routePath = '/cart';

  @override
  State<CartWidget> createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {
  late CartModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final NumberFormat _money = NumberFormat.currency(symbol: 'EGP ');

  static const double _taxRate = 0.15; // 15%
  static const double _serviceFeeFlat = 40.0;

  int get userPoints => currentUserDocument?.loyaltyPoints ?? 0;
  double get loyaltyDiscountAmount => _model.totalRedemptionDiscount;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CartModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is authenticated
    if (currentUserReference == null) {
      return Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          title: Text(
            'My Cart',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              font: GoogleFonts.poppins(
                color: FlutterFlowTheme.of(context).primaryText,
                fontSize: 28.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          centerTitle: false,
          elevation: 0.0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 48, color: Color(0xFFD76B30)),
              SizedBox(height: 16),
              Text(
                'Please sign in to view your cart',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pushNamed('SignInSignUp'),
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFD76B30)),
                child: Text('Sign In', style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          buttonSize: 46.0,
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFFD76B30),
            size: 25.0,
          ),
          onPressed: () async {
            context.safePop();
          },
        ),
        title: Text(
          'My Cart',
          style: GoogleFonts.poppins(
            color: FlutterFlowTheme.of(context).primaryText,
            fontSize: 28.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.0,
          ),
        ),
        centerTitle: false,
        elevation: 0.0,
      ),
      body: Align(
        alignment: const AlignmentDirectional(0.0, -1.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 24.0),
            child: StreamBuilder<List<CartRecord>>(
              stream: queryCartRecord(
                queryBuilder: (cart) => cart
                    .where('userReference', isEqualTo: currentUserReference),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD76B30)),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Error loading cart',
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Please check your connection and try again',
                          style: GoogleFonts.poppins(color: FlutterFlowTheme.of(context).secondaryText),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return _buildEmptyCart(context);
                }

                final cartItems = snapshot.data!;

                if (cartItems.isEmpty) {
                  return _buildEmptyCart(context);
                }

                return _buildCartList(context, cartItems);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120.0,
            height: 120.0,
            decoration: BoxDecoration(
              color: const Color(0xFFD76B30).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: Color(0xFFD76B30),
              size: 60.0,
            ),
          ),
          const SizedBox(height: 24.0),
          Text(
            'Cart is empty',
            style: GoogleFonts.poppins(
              color: FlutterFlowTheme.of(context).primaryText,
              fontSize: 24.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Looks like you haven\'t added any trips to your cart yet...',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: FlutterFlowTheme.of(context).secondaryText,
              fontSize: 16.0,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32.0),
          FFButtonWidget(
            onPressed: () => context.pushNamed('home'),
            text: 'Browse Trips',
            icon: const Icon(Icons.explore_outlined, size: 20.0),
            options: FFButtonOptions(
              height: 48.0,
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
              color: const Color(0xFFD76B30),
              textStyle: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
              borderRadius: BorderRadius.circular(24.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(BuildContext context, List<CartRecord> cartItems) {
    final double baseTotal = cartItems.fold(0.0, (sum, item) => sum + (item.totalPrice));
    final double taxes = baseTotal * _taxRate;
    final double serviceFee = baseTotal > 0 ? _serviceFeeFlat : 0.0;
    final double subtotal = baseTotal + taxes + serviceFee;
    
    // Apply per-trip redemption discount
    final double loyaltyRedemptionDiscount = _model.totalRedemptionDiscount;
    final double grandTotal = subtotal - loyaltyRedemptionDiscount;

    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
      direction: Axis.horizontal,
      runAlignment: WrapAlignment.start,
      verticalDirection: VerticalDirection.down,
      clipBehavior: Clip.none,
      children: [
        // Cart Items
        Container(
          constraints: const BoxConstraints(maxWidth: 750.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            boxShadow: const [
              BoxShadow(
                blurRadius: 4.0,
                color: Color(0x33000000),
                offset: Offset(0.0, 2.0),
              ),
            ],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Cart',
                  style: GoogleFonts.poppins(
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 12.0),
                  child: Text(
                    'Review your selected trips and proceed to checkout.',
                    style: GoogleFonts.poppins(
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
                ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cartItems.length,
                  itemBuilder: (context, cartIndex) {
                    final cartItem = cartItems[cartIndex];
                    final tripRef = cartItem.tripReference;

                    if (tripRef == null) {
                      return _buildInvalidCartItem(cartItem);
                    }

                    return StreamBuilder<TripsRecord>(
                      stream: TripsRecord.getDocument(tripRef),
                      builder: (context, tripSnapshot) {
                        if (!tripSnapshot.hasData) {
                          return const SizedBox(height: 100.0);
                        }
                        final tripRecord = tripSnapshot.data!;
                        return _buildCartItem(context, cartItem, tripRecord);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Order Summary
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 430.0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            boxShadow: const [BoxShadow(blurRadius: 4.0, color: Color(0x33000000), offset: Offset(0.0, 2.0))],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order Summary', style: GoogleFonts.poppins(color: FlutterFlowTheme.of(context).primaryText, fontSize: 20.0, fontWeight: FontWeight.w600)),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 12.0),
                  child: Text('Below is a list of your items.', style: FlutterFlowTheme.of(context).labelMedium),
                ),
                Divider(height: 32.0, thickness: 2.0, color: FlutterFlowTheme.of(context).alternate),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                        child: Text('Price Breakdown', style: FlutterFlowTheme.of(context).labelMedium),
                      ),
                      _rowPrice(context, 'Base Price', _money.format(baseTotal)),
                      _rowPrice(context, 'Taxes (15%)', _money.format(taxes)),
                      _rowPrice(context, 'Service Fee', _money.format(serviceFee)),
                      // Loyalty discount line (if applicable)
                      if (loyaltyDiscountAmount > 0) ...[
                        _rowPrice(
                          context, 
                          'Loyalty Discount (${Loyalty.formatDiscount(Loyalty.discountFor(userPoints))})', 
                          '-${_money.format(loyaltyDiscountAmount)}',
                          isDiscount: true,
                        ),
                      ],
                      // Loyalty points display (if user has points but no discount yet)
                      if (userPoints > 0 && loyaltyDiscountAmount == 0) ...[
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Loyalty Points: $userPoints',
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                  color: const Color(0xFFD76B30),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${400 - userPoints} more for 10% off!',
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total', style: FlutterFlowTheme.of(context).titleMedium.override(fontSize: 20.0, fontWeight: FontWeight.w500)),
                            Text(_money.format(grandTotal), style: FlutterFlowTheme.of(context).displaySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                FFButtonWidget(
                  onPressed: () async {
                    if (cartItems.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Your cart is empty. Add some trips first.'),
                          backgroundColor: FlutterFlowTheme.of(context).warning,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    // Navigate to payment with the first trip (simplified for demo)
                    final firstTrip = cartItems.first;
                    if (firstTrip.tripReference != null) {
                      final tripDoc = await firstTrip.tripReference!.get();
                      final trip = TripsRecord.fromSnapshot(tripDoc);
                      
                      context.pushNamed('payment', queryParameters: {
                        'tripRecord': trip.reference.id,
                        'totalAmount': grandTotal.toString(),
                      });
                    }
                  },
                  text: 'Proceed to Checkout',
                  icon: const Icon(Icons.shopping_cart_checkout, size: 18),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 50.0,
                    color: const Color(0xFFD76B30),
                    textStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w600),
                    elevation: 2.0,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(BuildContext context, CartRecord cartItem, TripsRecord tripRecord) {
    final userPoints = currentUserDocument?.loyaltyPoints ?? 0;
    final canRedeem = Loyalty.canRedeem(userPoints) && !_model.loyaltyRedeemed;
    final cartItemId = cartItem.reference.id;
    final redemption = _model.getRedemptionForItem(cartItemId);
    final isThisItemSelected = _model.selectedTripIdForRedemption == tripRecord.reference.id;
    
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          boxShadow: const [BoxShadow(blurRadius: 8.0, color: Color(0x1A000000), offset: Offset(0.0, 2.0))],
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isThisItemSelected ? const Color(0xFFD76B30) : FlutterFlowTheme.of(context).alternate, 
            width: isThisItemSelected ? 2.0 : 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      tripRecord.imageUrl.isNotEmpty ? tripRecord.imageUrl : 'https://images.unsplash.com/photo-1519451241324-20b4ea2c4220',
                      width: 70.0,
                      height: 70.0,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).alternate,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tripRecord.title,
                          style: GoogleFonts.poppins(
                            color: FlutterFlowTheme.of(context).primaryText,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Travelers: ${cartItem.travelers}',
                          style: GoogleFonts.poppins(
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (redemption != null) ...[
                        Text(
                          _money.format(cartItem.totalPrice),
                          style: GoogleFonts.poppins(
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        Text(
                          _money.format(redemption.finalPrice),
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFD76B30),
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ] else ...[
                        Text(
                          _money.format(cartItem.totalPrice),
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFD76B30),
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              
              // Loyalty redemption section
              if (canRedeem && userPoints >= 400) ...[
                const SizedBox(height: 12.0),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD76B30).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: const Color(0xFFD76B30).withOpacity(0.3), width: 1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.card_giftcard,
                            color: const Color(0xFFD76B30),
                            size: 20.0,
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            'Redeem Loyalty Points',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFD76B30),
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: isThisItemSelected,
                            onChanged: _model.hasActiveRedemption && !isThisItemSelected
                                ? null // Disable if another item is selected
                                : (value) {
                                    setState(() {
                                      if (value) {
                                        _model.selectTripForRedemption(
                                          cartItemId,
                                          tripRecord.reference.id,
                                          cartItem.totalPrice,
                                        );
                                      } else {
                                        _model.clearRedemption();
                                      }
                                    });
                                  },
                            activeColor: const Color(0xFFD76B30),
                          ),
                        ],
                      ),
                      if (isThisItemSelected) ...[
                        const SizedBox(height: 8.0),
                        Text(
                          'Loyalty Discount (10%): -${_money.format(redemption?.discountAmount ?? 0)}',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFD76B30),
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Note: Your ${userPoints} loyalty points will be reset to 0 after purchase.',
                          style: GoogleFonts.poppins(
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ] else if (_model.hasActiveRedemption) ...[
                        const SizedBox(height: 8.0),
                        Text(
                          'You can only redeem points on one trip per order.',
                          style: GoogleFonts.poppins(
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 16.0),
              InkWell(
                onTap: () => _removeFromCart(cartItem, tripRecord.title),
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  padding: const EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 8.0),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.red.withOpacity(0.3), width: 1.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.delete_outline, color: Colors.red, size: 20.0),
                      const SizedBox(width: 8.0),
                      Text(
                        'Remove from Cart',
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvalidCartItem(CartRecord cartItem) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: FlutterFlowTheme.of(context).alternate),
        ),
        child: ListTile(
          leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
          title: Text('Missing trip reference', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          subtitle: Text('This cart item is invalid. You can remove it.', style: GoogleFonts.poppins()),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              await cartItem.reference.delete();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invalid item removed', style: GoogleFonts.poppins(color: Colors.white)),
                  backgroundColor: const Color(0xFFD76B30),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _rowPrice(BuildContext context, String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: FlutterFlowTheme.of(context).bodySmall.override(
              font: GoogleFonts.outfit(
                fontWeight: FontWeight.normal,
                fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
              ),
              color: isDiscount ? const Color(0xFFD76B30) : FlutterFlowTheme.of(context).secondaryText,
              fontSize: 14.0,
              letterSpacing: 0.0,
              fontWeight: isDiscount ? FontWeight.w600 : FontWeight.normal,
              fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.end,
            style: FlutterFlowTheme.of(context).bodyLarge.override(
              font: GoogleFonts.inter(
                fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
              ),
              color: isDiscount ? const Color(0xFFD76B30) : FlutterFlowTheme.of(context).primaryText,
              letterSpacing: 0.0,
              fontWeight: isDiscount ? FontWeight.w600 : FlutterFlowTheme.of(context).bodyLarge.fontWeight,
              fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _removeFromCart(CartRecord cartItem, String tripTitle) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove from Cart', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: Text('Are you sure you want to remove "$tripTitle" from your cart?', style: GoogleFonts.poppins()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: GoogleFonts.poppins(color: FlutterFlowTheme.of(context).secondaryText)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: Text('Remove', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await cartItem.reference.delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Trip removed from cart', style: GoogleFonts.poppins(color: Colors.white)),
              backgroundColor: const Color(0xFFD76B30),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove trip. Please try again.', style: GoogleFonts.poppins(color: Colors.white)),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
}
