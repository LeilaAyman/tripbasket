import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '/backend/backend.dart';
import 'package:flutter/foundation.dart';

class PdfService {
  static Future<void> downloadItineraryPdf({
    required TripsRecord trip,
    required BookingsRecord booking,
    required BuildContext context,
  }) async {
    try {
      final pdf = await generateItineraryPdf(trip: trip, booking: booking);
      
      if (kIsWeb) {
        // For web, use printing package to download
        await Printing.layoutPdf(
          onLayout: (format) => pdf.save(),
          name: 'itinerary_${trip.title}_${booking.reference.id}.pdf',
        );
      } else {
        // For mobile, save to downloads folder
        final bytes = await pdf.save();
        await _savePdfToDevice(
          bytes,
          'itinerary_${trip.title}_${booking.reference.id}.pdf',
          context,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<pw.Document> generateItineraryPdf({
    required TripsRecord trip,
    required BookingsRecord booking,
  }) async {
    final pdf = pw.Document();

    // Get itinerary items
    List<String> itineraryItems = trip.itenarary.isNotEmpty 
        ? trip.itenarary
        : _getDefaultItinerary(trip.title);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 20),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    color: PdfColors.orange,
                    width: 2,
                  ),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'TripsBasket',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.orange,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Trip Itinerary',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 30),
            
            // Trip Information
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Trip Details',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  _buildInfoRow('Trip Name:', trip.title),
                  _buildInfoRow('Location:', trip.location),
                  if (trip.startDate != null && trip.endDate != null)
                    _buildInfoRow('Duration:', '${trip.endDate!.difference(trip.startDate!).inDays + 1} days'),
                  _buildInfoRow('Price:', '\$${trip.price}'),
                  if (trip.startDate != null)
                    _buildInfoRow('Start Date:', _formatDate(trip.startDate!)),
                  if (trip.endDate != null)
                    _buildInfoRow('End Date:', _formatDate(trip.endDate!)),
                ],
              ),
            ),
            
            pw.SizedBox(height: 30),
            
            // Booking Information
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Booking Information',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  _buildInfoRow('Booking ID:', booking.reference.id),
                  _buildInfoRow('Traveler Count:', '${booking.travelerCount} travelers'),
                  if (booking.bookingDate != null)
                    _buildInfoRow('Booking Date:', _formatDate(booking.bookingDate!)),
                  _buildInfoRow('Payment Status:', booking.paymentStatus),
                  _buildInfoRow('Booking Status:', booking.bookingStatus),
                  if (booking.travelerNames.isNotEmpty) ...[
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Travelers:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    ...booking.travelerNames.map((name) => 
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 16, top: 2),
                        child: pw.Text('• $name'),
                      ),
                    ),
                  ],
                  if (booking.specialRequests.isNotEmpty) ...[
                    pw.SizedBox(height: 10),
                    _buildInfoRow('Special Requests:', booking.specialRequests),
                  ],
                ],
              ),
            ),
            
            pw.SizedBox(height: 30),
            
            // Itinerary
            pw.Text(
              'Detailed Itinerary',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            
            pw.SizedBox(height: 20),
            
            // Itinerary Items
            ...itineraryItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 30,
                      height: 30,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.orange,
                        borderRadius: pw.BorderRadius.circular(15),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          '${index + 1}',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            item.contains(':') 
                                ? '${item.split(':')[0]}:'
                                : 'Day ${index + 1}',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          if (item.contains(':')) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              item.split(':').skip(1).join(':').trim(),
                              style: const pw.TextStyle(fontSize: 11),
                            ),
                          ] else ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              item,
                              style: const pw.TextStyle(fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            
            pw.SizedBox(height: 30),
            
            // Footer
            pw.Container(
              padding: const pw.EdgeInsets.only(top: 20),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(
                    color: PdfColors.grey300,
                    width: 1,
                  ),
                ),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    'Thank you for choosing TripsBasket!',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.orange,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'For questions or support, contact us at info@tripsbasket.com',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Generated on ${_formatDate(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static List<String> _getDefaultItinerary(String tripTitle) {
    final tripName = tripTitle.toLowerCase();
    
    if (tripName.contains('dahab')) {
      return [
        'Day 1: Arrival in Dahab - Check into accommodation and welcome dinner',
        'Day 2: Blue Hole diving experience - World famous diving spot',
        'Day 3: Camel trek in the desert - Sunset adventure with Bedouin camp',
        'Day 4: Snorkeling at Three Pools - Crystal clear waters and coral reefs',
        'Day 5: Free time and departure - Last minute shopping and relaxation',
      ];
    } else if (tripName.contains('paris')) {
      return [
        'Day 1: Arrival in Paris - Eiffel Tower visit and Seine river cruise',
        'Day 2: Louvre Museum and Champs-Élysées shopping',
        'Day 3: Versailles Palace day trip',
        'Day 4: Montmartre and Sacré-Cœur exploration',
        'Day 5: Free time and departure',
      ];
    } else {
      return [
        'Day 1: Arrival and check-in',
        'Day 2: City exploration and local attractions',
        'Day 3: Adventure activities and cultural experiences',
        'Day 4: Free time and optional excursions',
        'Day 5: Departure',
      ];
    }
  }

  static Future<void> _savePdfToDevice(
    Uint8List bytes,
    String fileName,
    BuildContext context,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved to ${file.path}'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Share',
              onPressed: () => Printing.sharePdf(bytes: bytes, filename: fileName),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}