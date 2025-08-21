import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class PaymobService {
  // Real Paymob credentials
  static const String _apiKey = 'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRBMk9UYzVPQ3dpYm1GdFpTSTZJbWx1YVhScFlXd2lmUS5xeEJPR2RRX2V3QzBfTjVoeWJDZTdHWTFaa3FJQzFZcjU2TDg5MzFRMW5abmxHTlhCYVNwa1lkbDh0VzBlcHAwS1FINVZRX2h1azhWTUw5RTlYWVF4UQ==';
  static const String _baseUrl = 'https://accept.paymob.com/api';
  static const int _integrationId = 5240629;
  static const int _iframeId = 950985;

  // Authentication
  Future<String> authenticate() async {
    try {
      print('Paymob: Starting authentication with API key length: ${_apiKey.length}');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/tokens'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'api_key': _apiKey}),
      );

      print('Paymob: Authentication response status: ${response.statusCode}');
      print('Paymob: Authentication response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        throw Exception('Authentication failed with status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Paymob: Authentication error details: $e');
      throw Exception('Authentication error: $e');
    }
  }

  // Create order
  Future<Map<String, dynamic>> createOrder({
    required String authToken,
    required double amountCents,
    required String currency,
    List<Map<String, dynamic>>? items,
  }) async {
    try {
      final orderData = {
        'auth_token': authToken,
        'delivery_needed': 'false',
        'amount_cents': amountCents.toString(),
        'currency': currency,
        'items': items ?? [],
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/ecommerce/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Order creation failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Order creation error: $e');
    }
  }

  // Request payment key
  Future<String> requestPaymentKey({
    required String authToken,
    required int orderId,
    required double amountCents,
    required String currency,
    required Map<String, dynamic> billingData,
  }) async {
    try {
      final paymentData = {
        'auth_token': authToken,
        'amount_cents': amountCents.toString(),
        'expiration': 3600,
        'order_id': orderId,
        'billing_data': billingData,
        'currency': currency,
        'integration_id': _integrationId,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/acceptance/payment_keys'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(paymentData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        throw Exception('Payment key request failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Payment key error: $e');
    }
  }

  // Generate payment URL for iframe
  String generatePaymentUrl(String paymentToken) {
    return 'https://accept.paymob.com/api/acceptance/iframes/$_iframeId?payment_token=$paymentToken';
  }

  // Process full payment flow
  Future<PaymentResult> processPayment({
    required double amount,
    required String currency,
    required String merchantOrderId,
    required Map<String, dynamic> billingData,
    List<Map<String, dynamic>>? items,
  }) async {
    try {
      // Step 1: Authenticate
      final authToken = await authenticate();

      // Step 2: Create order
      final order = await createOrder(
        authToken: authToken,
        amountCents: amount * 100, // Convert to cents
        currency: currency,
        items: items,
      );

      // Step 3: Request payment key
      final paymentToken = await requestPaymentKey(
        authToken: authToken,
        orderId: order['id'],
        amountCents: amount * 100,
        currency: currency,
        billingData: billingData,
      );

      // Step 4: Generate payment URL
      final paymentUrl = generatePaymentUrl(paymentToken);
      
      return PaymentResult(
        success: true,
        paymentUrl: paymentUrl,
        orderId: order['id'],
        paymentToken: paymentToken,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        error: 'Payment processing failed: $e',
      );
    }
  }

  // Verify webhook signature (for production)
  bool verifyWebhookSignature(String payload, String signature, String secret) {
    try {
      final hmac = Hmac(sha512, utf8.encode(secret));
      final digest = hmac.convert(utf8.encode(payload));
      final calculatedSignature = digest.toString();
      return calculatedSignature == signature;
    } catch (e) {
      return false;
    }
  }

  // Parse webhook callback
  Map<String, dynamic> parseWebhookData(String payload) {
    try {
      return jsonDecode(payload);
    } catch (e) {
      throw Exception('Invalid webhook payload: $e');
    }
  }

  // Check transaction status
  Future<Map<String, dynamic>> getTransactionStatus({
    required String authToken,
    required int transactionId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/acceptance/transactions/$transactionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Transaction status check failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Transaction status error: $e');
    }
  }

  // Helper method to create billing data
  static Map<String, dynamic> createBillingData({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String? apartment,
    String? floor,
    String? street,
    String? building,
    String? shippingMethod,
    String? postalCode,
    String? city,
    String? country,
    String? state,
  }) {
    return {
      'apartment': apartment ?? 'NA',
      'email': email,
      'floor': floor ?? 'NA',
      'first_name': firstName,
      'street': street ?? 'NA',
      'building': building ?? 'NA',
      'phone_number': phone,
      'shipping_method': shippingMethod ?? 'PKG',
      'postal_code': postalCode ?? 'NA',
      'city': city ?? 'NA',
      'country': country ?? 'EG',
      'last_name': lastName,
      'state': state ?? 'NA',
    };
  }
}

// Payment result class
class PaymentResult {
  final bool success;
  final String? paymentUrl;
  final String? error;
  final int? orderId;
  final String? paymentToken;

  PaymentResult({
    required this.success,
    this.paymentUrl,
    this.error,
    this.orderId,
    this.paymentToken,
  });
}
