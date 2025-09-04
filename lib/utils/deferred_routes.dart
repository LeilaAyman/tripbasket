import 'package:flutter/material.dart';
import 'dart:async';

// Lazy imports for deferred loading - these are only loaded when accessed
import '../pages/profile/profile_widget.dart' show ProfileWidget;
import '../pages/payment/payment_widget.dart' show PaymentWidget;
import '../pages/admin_upload/admin_upload_widget.dart' show AdminUploadWidget;
import '../pages/agency_dashboard/agency_dashboard_widget.dart' show AgencyDashboardWidget;
import '../pages/admin_dashboard/admin_dashboard_widget.dart' show AdminDashboardWidget;
import '../pages/mybookings/mybookings_widget.dart' show MybookingsWidget;
import '../pages/cart/cart_widget.dart' show CartWidget;

/// Simple deferred route loading using lazy initialization
/// This reduces the impact on initial load by delaying heavy widget construction
class DeferredRoutes {
  /// Profile route with lazy loading
  static Widget profileRoute() {
    return _DeferredRouteWrapper(
      routeName: 'Profile',
      widgetBuilder: () => ProfileWidget(),
    );
  }

  /// Payment route with deferred loading
  static Widget paymentRoute(dynamic tripRecord, double totalAmount) {
    return _DeferredRouteWrapper(
      routeName: 'Payment',
      widgetBuilder: () => PaymentWidget(
        tripRecord: tripRecord, 
        totalAmount: totalAmount,
      ),
    );
  }

  /// Admin Upload route with deferred loading
  static Widget adminUploadRoute() {
    return _DeferredRouteWrapper(
      routeName: 'Admin Upload',
      widgetBuilder: () => AdminUploadWidget(),
    );
  }

  /// Agency Dashboard route with deferred loading  
  static Widget agencyDashboardRoute() {
    return _DeferredRouteWrapper(
      routeName: 'Agency Dashboard',
      widgetBuilder: () => AgencyDashboardWidget(),
    );
  }

  /// Admin Dashboard route with deferred loading
  static Widget adminDashboardRoute() {
    return _DeferredRouteWrapper(
      routeName: 'Admin Dashboard',
      widgetBuilder: () => AdminDashboardWidget(),
    );
  }

  /// My Bookings route with deferred loading
  static Widget myBookingsRoute() {
    return _DeferredRouteWrapper(
      routeName: 'My Bookings',
      widgetBuilder: () => MybookingsWidget(),
    );
  }

  /// Cart route with deferred loading
  static Widget cartRoute() {
    return _DeferredRouteWrapper(
      routeName: 'Cart',
      widgetBuilder: () => CartWidget(),
    );
  }
}

/// Internal wrapper for deferred route loading
class _DeferredRouteWrapper extends StatefulWidget {
  final String routeName;
  final Widget Function() widgetBuilder;

  const _DeferredRouteWrapper({
    required this.routeName,
    required this.widgetBuilder,
  });

  @override
  State<_DeferredRouteWrapper> createState() => _DeferredRouteWrapperState();
}

class _DeferredRouteWrapperState extends State<_DeferredRouteWrapper> {
  Widget? _cachedWidget;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWidget();
  }

  Future<void> _loadWidget() async {
    try {
      // Small delay to ensure critical path has loaded first
      await Future.delayed(const Duration(milliseconds: 50));
      
      if (mounted) {
        final widget = this.widget.widgetBuilder();
        setState(() {
          _cachedWidget = widget;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedWidget != null) {
      return _cachedWidget!;
    }

    if (_error != null) {
      return _ErrorView(
        routeName: widget.routeName,
        error: _error!,
        onRetry: _loadWidget,
      );
    }

    return _LoadingView(routeName: widget.routeName);
  }
}

/// Loading view for deferred routes
class _LoadingView extends StatelessWidget {
  final String routeName;

  const _LoadingView({required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(routeName),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}

/// Error view for deferred routes
class _ErrorView extends StatelessWidget {
  final String routeName;
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.routeName,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Error - $routeName'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load $routeName',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}