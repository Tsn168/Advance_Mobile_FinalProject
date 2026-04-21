import 'package:advance_mobile/data/repositories/mock_data_store.dart';
import 'package:advance_mobile/data/repositories/pass/pass_repository_mock.dart';
import 'package:advance_mobile/data/repositories/user/user_repository_mock.dart';
import 'package:advance_mobile/model/pass/pass.dart';
import 'package:advance_mobile/ui/screens/plans/plans_screen.dart';
import 'package:advance_mobile/ui/screens/plans/view_model/pass_viewmodel.dart';
import 'package:advance_mobile/ui/widgets/pass_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _buildHarness(PassViewModel viewModel) {
  return ChangeNotifierProvider<PassViewModel>.value(
    value: viewModel,
    child: const MaterialApp(home: PlansScreen()),
  );
}

Future<PassViewModel> _createViewModel({required String userId}) async {
  final store = MockDataStore();
  final viewModel = PassViewModel(
    MockPassRepository(store),
    MockUserRepository(store),
  );
  await viewModel.initialize(userId: userId);
  return viewModel;
}

Future<void> _setLargeSurface(WidgetTester tester) async {
  final binding = tester.binding;
  await binding.setSurfaceSize(const Size(1200, 2800));
}

void main() {
  group('PlansScreen', () {
    testWidgets('6.1/6.2 renders pass cards, badges, descriptions, and prices', (
      tester,
    ) async {
      await _setLargeSurface(tester);
      final viewModel = (await tester.runAsync(
        () => _createViewModel(userId: 'user_elite'),
      ))!;
      addTearDown(viewModel.dispose);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_buildHarness(viewModel));
      await tester.pumpAndSettle();

      expect(find.text('Manage your subscription'), findsOneWidget);
      expect(
        find.text('Fuel your momentum with flexible access to our fleet.'),
        findsOneWidget,
      );

      expect(find.text('QUICK START'), findsOneWidget);
      expect(find.text('BEST VALUE'), findsOneWidget);
      expect(find.text('BEST IDEA'), findsOneWidget);

      expect(find.text('Day Pass'), findsOneWidget);
      expect(find.text('Monthly Pass'), findsOneWidget);
      expect(find.text('Annual Pass'), findsOneWidget);

      expect(find.textContaining('\$5.00', findRichText: true), findsOneWidget);
      expect(find.textContaining('\$25.00', findRichText: true), findsOneWidget);
      expect(find.textContaining('\$150.00', findRichText: true), findsOneWidget);

      expect(find.textContaining('/ single use'), findsOneWidget);
      expect(find.textContaining('/ month'), findsOneWidget);
      expect(find.textContaining('/ year'), findsOneWidget);

      expect(find.textContaining('24 hours validity'), findsOneWidget);
      expect(find.textContaining('30 days validity'), findsOneWidget);
      expect(find.textContaining('365 days validity'), findsOneWidget);
    });

    testWidgets('6.3/6.4 shows active pass indication and disables choose buttons', (
      tester,
    ) async {
      await _setLargeSurface(tester);
      final viewModel = (await tester.runAsync(
        () => _createViewModel(userId: 'user_reyu'),
      ))!;
      addTearDown(viewModel.dispose);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_buildHarness(viewModel));
      await tester.pumpAndSettle();

      expect(find.byType(PassInfoCard), findsOneWidget);
      expect(find.text('MEMBERSHIP STATUS'), findsOneWidget);
      expect(find.textContaining('You already have an active'), findsOneWidget);
      expect(find.text('MANAGE YOUR CURRENT PLAN'), findsOneWidget);

      final chooseButtons = tester.widgetList<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Choose'),
      );
      expect(chooseButtons, isNotEmpty);
      for (final button in chooseButtons) {
        expect(button.onPressed, isNull);
      }
    });

    testWidgets('6.3 manage button only appears for active pass users', (
      tester,
    ) async {
      await _setLargeSurface(tester);
      final viewModel = (await tester.runAsync(
        () => _createViewModel(userId: 'user_elite'),
      ))!;
      addTearDown(viewModel.dispose);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_buildHarness(viewModel));
      await tester.pumpAndSettle();

      expect(find.text('MANAGE YOUR CURRENT PLAN'), findsNothing);
    });

    testWidgets('6.5 choose action purchases pass when user has no active pass', (
      tester,
    ) async {
      await _setLargeSurface(tester);
      final viewModel = (await tester.runAsync(
        () => _createViewModel(userId: 'user_elite'),
      ))!;
      addTearDown(viewModel.dispose);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_buildHarness(viewModel));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Choose').first);
      await tester.pumpAndSettle();

      expect(viewModel.hasActivePass, isTrue);
      expect(find.textContaining('purchased successfully'), findsOneWidget);
      expect(find.text('MANAGE YOUR CURRENT PLAN'), findsOneWidget);
    });

    testWidgets('6.6 Property 1: pass type display completeness', (tester) async {
      // Feature: bike-rental-pass-booking, Property 1: Pass Type Display Completeness
      await _setLargeSurface(tester);
      final scenarios = <({PassType type, String price, String validity})>[
        (type: PassType.day, price: '\$5.00', validity: '24 hours validity'),
        (type: PassType.monthly, price: '\$25.00', validity: '30 days validity'),
        (type: PassType.annual, price: '\$150.00', validity: '365 days validity'),
      ];

      final viewModel = (await tester.runAsync(
        () => _createViewModel(userId: 'user_elite'),
      ))!;
      addTearDown(viewModel.dispose);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_buildHarness(viewModel));
      await tester.pumpAndSettle();

      for (final scenario in scenarios) {
        expect(find.text(scenario.type.displayName), findsOneWidget);
        expect(
          find.textContaining(scenario.price, findRichText: true),
          findsOneWidget,
        );
        expect(find.textContaining(scenario.validity), findsOneWidget);
      }
    });

    testWidgets('6.7 Property 2: active pass indication is always explicit', (
      tester,
    ) async {
      // Feature: bike-rental-pass-booking, Property 2: Active Pass Indication
      await _setLargeSurface(tester);
      final scenarios = <(String, bool)>[
        ('user_reyu', true),
        ('user_elite', false),
        ('user_somnang', false),
      ];
      addTearDown(() => tester.binding.setSurfaceSize(null));

      for (final scenario in scenarios) {
        final userId = scenario.$1;
        final expectsActive = scenario.$2;
        final viewModel = (await tester.runAsync(
          () => _createViewModel(userId: userId),
        ))!;
        addTearDown(viewModel.dispose);

        await tester.pumpWidget(_buildHarness(viewModel));
        await tester.pumpAndSettle();

        if (expectsActive) {
          expect(find.text('MEMBERSHIP STATUS'), findsOneWidget);
          expect(find.text('MANAGE YOUR CURRENT PLAN'), findsOneWidget);
        } else {
          expect(find.text('MEMBERSHIP STATUS'), findsNothing);
          expect(find.text('MANAGE YOUR CURRENT PLAN'), findsNothing);
        }

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }
    });
  });
}
