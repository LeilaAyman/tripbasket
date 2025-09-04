import 'package:flutter/material.dart';
import 'deferred_imports.dart';

/// Wrapper widget that shows a loading indicator while deferred modules load
class DeferredLoadingWrapper extends StatelessWidget {
  final Future<Widget> Function() widgetBuilder;
  final String? loadingText;

  const DeferredLoadingWrapper({
    super.key,
    required this.widgetBuilder,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: widgetBuilder(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load page',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text('Error: ${snapshot.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return snapshot.data!;
        }

        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  loadingText ?? 'Loading...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}