import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/services/favorites_service.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/components/interactive_trip_rating.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  static String routeName = 'favorites';
  static String routePath = '/favorites';

  @override
  Widget build(BuildContext context) {
    final userRef = currentUserReference;
    
    if (userRef == null) {
      return Scaffold(
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
            'My Favorites',
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 48, color: Color(0xFFD76B30)),
              SizedBox(height: 16),
              Text(
                'Sign in to view favorites',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pushNamed('home'),
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFD76B30)),
                child: Text('Sign In', style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
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
          'My Favorites',
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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FavoritesService.queryForUser(userRef).snapshots(),
        builder: (context, favSnap) {
          print('🔍 Favorites page - Connection state: ${favSnap.connectionState}');
          print('🔍 Favorites page - Has data: ${favSnap.hasData}');
          print('🔍 Favorites page - Has error: ${favSnap.hasError}');
          if (favSnap.hasError) {
            print('🚨 Favorites page - Error: ${favSnap.error}');
          }
          if (favSnap.hasData) {
            print('🔍 Favorites page - Docs count: ${favSnap.data!.docs.length}');
          }
          
          if (!favSnap.hasData) {
            return Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFFD76B30),
                  ),
                ),
              ),
            );
          }

          final docs = favSnap.data!.docs;
          
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'No Favorites Yet',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: FlutterFlowTheme.of(context).primaryText,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Start exploring trips and add them to your favorites!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                  ),
                  SizedBox(height: 32),
                  FFButtonWidget(
                    onPressed: () => context.pushNamed('home'),
                    text: 'Explore Trips',
                    options: FFButtonOptions(
                      width: 200,
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
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => SizedBox(height: 12),
            itemBuilder: (context, i) {
              final fav = docs[i].data();
              final tripRef = fav['trip_reference'] as DocumentReference;
              
              return StreamBuilder<TripsRecord>(
                stream: TripsRecord.getDocument(tripRef),
                builder: (context, tripSnap) {
                  if (!tripSnap.hasData) {
                    return Container(
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD76B30)),
                        ),
                      ),
                    );
                  }

                  final trip = tripSnap.data!;
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 8.0,
                          color: Color(0x230F1113),
                          offset: Offset(0.0, 4.0),
                        )
                      ],
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Trip Image
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.0),
                            topRight: Radius.circular(12.0),
                          ),
                          child: Stack(
                            children: [
                              Image.network(
                                trip.image.isNotEmpty 
                                    ? trip.image
                                    : 'https://images.unsplash.com/photo-1528114039593-4366cc08227d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8OHx8aXRhbHl8ZW58MHx8MHx8&auto=format&fit=crop&w=900&q=60',
                                width: double.infinity,
                                height: 200.0,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: double.infinity,
                                    height: 200.0,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFD76B30).withOpacity(0.3),
                                          Color(0xFFF2D83B).withOpacity(0.3),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.image_not_supported_rounded,
                                      color: Colors.grey[600],
                                      size: 40,
                                    ),
                                  );
                                },
                              ),
                              // Remove favorite button
                              Positioned(
                                top: 12,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () async {
                                    await FavoritesService.remove(userRef, trip.reference);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Removed from favorites'),
                                        backgroundColor: Colors.orange,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Trip Details
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      trip.title,
                                      style: GoogleFonts.poppins(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    InteractiveTripRating(
                                      tripRecord: trip,
                                      initialRating: trip.rating,
                                      showReviewsButton: true,
                                      onRatingChanged: (rating) {
                                        print('Rating changed to: $rating');
                                      },
                                    ),
                                    if (trip.location.isNotEmpty) ...[
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 16,
                                            color: Color(0xFFD76B30),
                                          ),
                                          SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              trip.location,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: FlutterFlowTheme.of(context).secondaryText,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      context.pushNamed(
                                        'bookings',
                                        queryParameters: {
                                          'tripref': serializeParam(
                                            trip.reference,
                                            ParamType.DocumentReference,
                                          ),
                                        }.withoutNulls,
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFD76B30),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '\$${trip.price} USD',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}