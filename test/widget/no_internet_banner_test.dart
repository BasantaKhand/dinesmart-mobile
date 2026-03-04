import 'package:dinesmart_app/core/providers/connectivity_provider.dart';
import 'package:dinesmart_app/core/widgets/no_internet_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoInternetBanner', () {
    testWidgets('is hidden when connected', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectivityStreamProvider.overrideWith((ref) => Stream.value(true)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  NoInternetBanner(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('No internet connection'), findsNothing);
    });

    testWidgets('is visible when disconnected', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectivityStreamProvider.overrideWith((ref) => Stream.value(false)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  NoInternetBanner(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('No internet connection'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry is provided and disconnected', (tester) async {
      bool retryCalled = false;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectivityStreamProvider.overrideWith((ref) => Stream.value(false)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  NoInternetBanner(
                    onRetry: () {
                      retryCalled = true;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryCalled, true);
    });
  });

  group('NoInternetPlaceholder', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NoInternetPlaceholder(),
          ),
        ),
      );

      expect(find.text('You\'re Offline'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });

    testWidgets('calls onRetry when button is tapped', (tester) async {
      bool retryCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoInternetPlaceholder(
              onRetry: () {
                retryCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Try Again'));
      await tester.pump();

      expect(retryCalled, true);
    });
  });
}
