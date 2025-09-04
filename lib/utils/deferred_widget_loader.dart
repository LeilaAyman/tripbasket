import 'package:flutter/material.dart';

/// Utility for implementing deferred widget loading to improve initial app startup
class DeferredWidgetLoader extends StatefulWidget {
  final Future<Widget> Function() loader;
  final Widget placeholder;
  final String routeName;

  const DeferredWidgetLoader({
    Key? key,
    required this.loader,
    required this.placeholder,
    required this.routeName,
  }) : super(key: key);

  @override
  State<DeferredWidgetLoader> createState() => _DeferredWidgetLoaderState();
}

class _DeferredWidgetLoaderState extends State<DeferredWidgetLoader> {
  Widget? _loadedWidget;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  Future<void> _startLoading() async {
    if (_isLoading || _loadedWidget != null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final widget = await widget.loader();
      if (mounted) {
        setState(() {
          _loadedWidget = widget;
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
    if (_loadedWidget != null) {
      return _loadedWidget!;
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Failed to load ${widget.routeName}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _startLoading,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return widget.placeholder;
  }
}

/// Loading placeholder for deferred routes
class RouteLoadingPlaceholder extends StatelessWidget {
  final String routeName;

  const RouteLoadingPlaceholder({
    Key? key,
    required this.routeName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(routeName),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading $routeName...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

/// Factory for creating deferred route widgets
class DeferredRoutes {
  /// Deferred Profile widget
  static Widget createProfileWidget() {
    return DeferredWidgetLoader(
      routeName: 'Profile',
      placeholder: const RouteLoadingPlaceholder(routeName: 'Profile'),
      loader: () async {
        // Small delay to ensure main bundle has loaded
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Dynamic import would go here in a real deferred loading scenario
        // For now, we'll use regular import but with async loading
        final module = await _loadProfileModule();
        return module;
      },
    );
  }

  /// Deferred Payment widget
  static Widget createPaymentWidget(dynamic tripRecord, double totalAmount) {
    return DeferredWidgetLoader(
      routeName: 'Payment',
      placeholder: const RouteLoadingPlaceholder(routeName: 'Payment'),
      loader: () async {
        await Future.delayed(const Duration(milliseconds: 100));
        final module = await _loadPaymentModule(tripRecord, totalAmount);
        return module;
      },
    );
  }

  /// Deferred Admin widgets
  static Widget createAdminUploadWidget() {
    return DeferredWidgetLoader(
      routeName: 'Admin Upload',
      placeholder: const RouteLoadingPlaceholder(routeName: 'Admin Upload'),
      loader: () async {
        await Future.delayed(const Duration(milliseconds: 100));
        final module = await _loadAdminUploadModule();
        return module;
      },
    );
  }

  static Widget createAgencyDashboardWidget() {
    return DeferredWidgetLoader(
      routeName: 'Agency Dashboard',
      placeholder: const RouteLoadingPlaceholder(routeName: 'Agency Dashboard'),
      loader: () async {
        await Future.delayed(const Duration(milliseconds: 100));
        final module = await _loadAgencyDashboardModule();
        return module;
      },
    );
  }

  static Widget createAdminDashboardWidget() {
    return DeferredWidgetLoader(
      routeName: 'Admin Dashboard',
      placeholder: const RouteLoadingPlaceholder(routeName: 'Admin Dashboard'),
      loader: () async {
        await Future.delayed(const Duration(milliseconds: 100));
        final module = await _loadAdminDashboardModule();
        return module;
      },
    );
  }
}

// These functions simulate deferred loading by using dynamic imports
// In a real scenario, these would use deferred loading with 'deferred as' imports

Future<Widget> _loadProfileModule() async {
  // Import and return ProfileWidget
  final ProfileWidget = (await import('../pages/profile/profile_widget.dart')).ProfileWidget;
  return ProfileWidget();
}

Future<Widget> _loadPaymentModule(dynamic tripRecord, double totalAmount) async {
  // Import and return PaymentWidget
  final PaymentWidget = (await import('../pages/payment/payment_widget.dart')).PaymentWidget;
  return PaymentWidget(tripRecord: tripRecord, totalAmount: totalAmount);
}

Future<Widget> _loadAdminUploadModule() async {
  // Import and return AdminUploadWidget
  final AdminUploadWidget = (await import('../pages/admin_upload/admin_upload_widget.dart')).AdminUploadWidget;
  return AdminUploadWidget();
}

Future<Widget> _loadAgencyDashboardModule() async {
  // Import and return AgencyDashboardWidget
  final AgencyDashboardWidget = (await import('../pages/agency_dashboard/agency_dashboard_widget.dart')).AgencyDashboardWidget;
  return AgencyDashboardWidget();
}

Future<Widget> _loadAdminDashboardModule() async {
  // Import and return AdminDashboardWidget
  final AdminDashboardWidget = (await import('../pages/admin_dashboard/admin_dashboard_widget.dart')).AdminDashboardWidget;
  return AdminDashboardWidget();
}

// Helper function for dynamic imports (Dart doesn't support this directly)
// This is a placeholder - in a real implementation, you'd use deferred loading
Future<dynamic> import(String path) async {
  // This is a simulation - in real Dart/Flutter, you'd use:
  // import 'path' deferred as moduleName;
  // await moduleName.loadLibrary();
  throw UnimplementedError('Dynamic imports not supported in Dart. Use deferred loading instead.');
}