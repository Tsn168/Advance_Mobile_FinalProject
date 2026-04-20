import 'package:advance_mobile/model/bike/bike.dart';
import 'package:advance_mobile/model/pass/pass.dart';
import 'package:advance_mobile/model/station/station.dart';
import 'package:advance_mobile/ui/widgets/bike_slot_card.dart';
import 'package:advance_mobile/ui/widgets/pass_card.dart';
import 'package:advance_mobile/ui/widgets/pass_info_card.dart';
import 'package:advance_mobile/ui/widgets/station_availability_buttons.dart';
import 'package:advance_mobile/ui/widgets/station_bottom_sheet.dart';
import 'package:advance_mobile/ui/widgets/station_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  group('BikeSlotCard', () {
    testWidgets('renders available bike and handles tap', (tester) async {
      var tapped = false;
      final bike = Bike(
        id: '009',
        stationId: 'station-1',
        slotNumber: 10,
        status: BikeStatus.available,
        condition: BikeCondition.good,
        model: 'City Rider',
      );

      await tester.pumpWidget(
        _wrap(
          BikeSlotCard(
            bike: bike,
            slotNumber: bike.slotNumber,
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('BikeID: #009'), findsOneWidget);
      expect(find.text('Slot: no.10'), findsOneWidget);
      expect(find.text('AVAILABLE'), findsOneWidget);

      await tester.tap(find.byType(BikeSlotCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('renders unavailable and empty states distinctly', (
      tester,
    ) async {
      final unavailableBike = Bike(
        id: '902',
        stationId: 'station-1',
        slotNumber: 20,
        status: BikeStatus.booked,
        condition: BikeCondition.fair,
        model: 'Road Pro',
      );

      await tester.pumpWidget(
        _wrap(
          Column(
            children: [
              BikeSlotCard(bike: unavailableBike, slotNumber: 20),
              const SizedBox(height: 12),
              const BikeSlotCard(bike: null, slotNumber: 21),
            ],
          ),
        ),
      );

      expect(find.text('UNAVAILABLE'), findsOneWidget);
      expect(find.text('Empty Slot'), findsOneWidget);
      expect(find.text('EMPTY'), findsOneWidget);
    });
  });

  group('StationAvailabilityButtons', () {
    testWidgets('shows counts and triggers bikes callback', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        _wrap(
          StationAvailabilityButtons(
            availableBikes: 10,
            emptySlots: 4,
            onViewBikes: () => tapped = true,
          ),
        ),
      );

      expect(find.text('10'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('BIKES AVAILABLE'), findsOneWidget);
      expect(find.text('EMPTY SLOTS'), findsOneWidget);

      await tester.tap(find.text('BIKES AVAILABLE'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('PassCard', () {
    testWidgets(
      'renders pass name, price, validity, badge, and choose action',
      (tester) async {
        var chose = false;

        await tester.pumpWidget(
          _wrap(
            PassCard(
              passType: PassType.monthly,
              badgeText: 'BEST VALUE',
              badgeColor: const Color(0xFFFF9800),
              description: '30 days validity for daily rides.',
              onChoose: () => chose = true,
            ),
          ),
        );

        expect(find.text('Monthly Pass'), findsOneWidget);
        expect(
          find.textContaining('49.99', findRichText: true),
          findsOneWidget,
        );
        expect(find.textContaining('/ month'), findsOneWidget);
        expect(find.text('BEST VALUE'), findsOneWidget);
        expect(find.text('Choose'), findsOneWidget);

        await tester.tap(find.text('Choose'));
        await tester.pump();
        expect(chose, isTrue);
      },
    );
  });

  group('PassInfoCard', () {
    testWidgets('shows active pass state', (tester) async {
      final activePass = Pass(
        id: 'pass-1',
        userId: 'user-1',
        type: PassType.day,
        startDate: DateTime(2026, 4, 20),
        expiryDate: DateTime(2026, 4, 21),
        isActive: true,
        price: 5.99,
      );

      await tester.pumpWidget(_wrap(PassInfoCard(activePass: activePass)));

      expect(find.text('MEMBERSHIP STATUS'), findsOneWidget);
      expect(find.text('Day Pass Active'), findsOneWidget);
      expect(find.text('Expires: 04/21/2026'), findsOneWidget);
    });

    testWidgets('shows null state', (tester) async {
      await tester.pumpWidget(_wrap(const PassInfoCard(activePass: null)));

      expect(find.text('No Active Pass'), findsOneWidget);
      expect(find.text('Purchase a pass to start riding'), findsOneWidget);
    });
  });

  group('StationMarker', () {
    testWidgets('renders selected and unselected visual states', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const Row(
            children: [
              StationMarker(availableBikes: 5, isSelected: true),
              SizedBox(width: 12),
              StationMarker(availableBikes: 0, isSelected: false),
            ],
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);

      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(StationMarker),
          matching: find.byType(Container),
        ),
      );
      final decorations = containers
          .map((container) => container.decoration)
          .whereType<BoxDecoration>()
          .where((decoration) => decoration.shape == BoxShape.circle)
          .toList();

      expect(
        decorations.any(
          (decoration) => decoration.color == const Color(0xFF00C853),
        ),
        isTrue,
      );
      expect(
        decorations.any((decoration) => decoration.color == Colors.white),
        isTrue,
      );
    });
  });

  group('StationBottomSheet', () {
    testWidgets('renders station info and composes availability buttons', (
      tester,
    ) async {
      var tapped = false;
      final station = Station(
        id: 'station-1',
        name: 'Central Park North',
        latitude: 40.0,
        longitude: -73.0,
        totalSlots: 14,
        availableBikes: 10,
        address: '0.4 miles away',
      );

      await tester.pumpWidget(
        _wrap(
          StationBottomSheet(
            station: station,
            onViewBikes: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Station: Central Park North'), findsOneWidget);
      expect(find.text('SELECTED'), findsOneWidget);
      expect(find.text('0.4 miles away'), findsOneWidget);
      expect(find.byType(StationAvailabilityButtons), findsOneWidget);

      await tester.tap(find.text('BIKES AVAILABLE'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
