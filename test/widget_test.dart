import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';

void main() {
  testWidgets('Weather App UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the TextField and Get Weather button are present.
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Get Weather'), findsOneWidget);

    // Simulate entering a city name into the TextField.
    await tester.enterText(find.byType(TextField), 'London');
    await tester.pump();

    // Verify the text was entered.
    expect(find.text('London'), findsOneWidget);

    // Tap the "Get Weather" button and trigger a frame.
    await tester.tap(find.text('Get Weather'));
    await tester.pump();

    // Verify that the loading indicator appears.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Since we aren't mocking the HTTP call, we can't test the weather data display
    // without a real API call. Add a mock for more comprehensive testing (see below).
  });
}