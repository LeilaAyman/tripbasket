import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // <- for currency formatting
import 'mybookings_model.dart';
export 'mybookings_model.dart';

class MybookingsWidget extends StatefulWidget {
  const MybookingsWidget({super.key});

  static String routeName = 'mybookings';
  static String routePath = '/mybookings';

  @override
  State<MybookingsWidget> createState() => _MybookingsWidgetState();
}

class _MybookingsWidgetState extends State<MybookingsWidget> {
  late MybookingsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final NumberFormat _money = NumberFormat.currency(symbol: '\$'); // simple USD formatter

  static const double _taxRate = 0.15; // 15%
  static const double _serviceFeeFlat = 40.0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MybookingsModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            color: Color(0xFFD76B30), // Orange theme color
            size: 25.0,
          ),
          onPressed: () async {
            context.safePop();
          },
        ),
        actions: const [],
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
                // If still loading initial connection
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(); // <- no spinner, just empty
                }

                if (!snapshot.hasData) {
                  return const SizedBox(); // no spinner, just nothing
                }

                final cartItems = snapshot.data!;

                // Immediately show empty state if no items
                if (cartItems.isEmpty) {
                  return _buildEmptyCart(context);
                }

                // Otherwise show cart items
                return _buildCartList(context, cartItems);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _rowPrice(BuildContext context, String label, String value) {
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
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: 14.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.normal,
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
                  letterSpacing: 0.0,
                  fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                ),
          ),
        ],
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
    final double grandTotal = baseTotal + taxes + serviceFee;
    final bool hasItemsNeedingPaperwork = cartItems.any((item) => item.requiresAdditionalPaperwork);

    return Wrap(
      key: ValueKey('cart_wrap_${cartItems.length}'),
      spacing: 16.0,
      runSpacing: 16.0,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
      direction: Axis.horizontal,
      runAlignment: WrapAlignment.start,
      verticalDirection: VerticalDirection.down,
      clipBehavior: Clip.none,
      children: [
        // LEFT: My Cart
        Container(
          key: ValueKey('cart_container_${cartItems.length}'),
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
              mainAxisSize: MainAxisSize.max,
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
                  key: ValueKey('cart_list_${cartItems.length}'),
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cartItems.length,
                  itemBuilder: (context, cartIndex) {
                    final cartItem = cartItems[cartIndex];
                    final tripRef = cartItem.tripReference;

                    if (tripRef == null) {
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

                    return StreamBuilder<TripsRecord>(
                      key: ValueKey(cartItem.reference.id),
                      stream: TripsRecord.getDocument(tripRef),
                      builder: (context, tripSnapshot) {
                        if (!tripSnapshot.hasData) {
                          return const SizedBox(height: 100.0);
                        }
                        final tripRecord = tripSnapshot.data!;

                        return Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              boxShadow: const [BoxShadow(blurRadius: 8.0, color: Color(0x1A000000), offset: Offset(0.0, 2.0))],
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(color: FlutterFlowTheme.of(context).alternate, width: 1.0),
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
                                          tripRecord.imageUrl.isNotEmpty ? tripRecord.imageUrl : 'https://images.unsplash.com/photo-1519451241324-20b4ea2c4220?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
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
                                      Text(
                                        _money.format(cartItem.totalPrice),
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFFD76B30),
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16.0),
                                  InkWell(
                                    onTap: () async {
                                      final bool? confirmDelete = await showDialog<bool>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Remove from Cart', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                            content: Text('Are you sure you want to remove "${tripRecord.title}" from your cart?', style: GoogleFonts.poppins()),
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
                                    },
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
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // RIGHT: Order Summary
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Proceeding to checkout...'),
                        backgroundColor: FlutterFlowTheme.of(context).success,
                        duration: const Duration(seconds: 2),
                      ),
                    );
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
}
