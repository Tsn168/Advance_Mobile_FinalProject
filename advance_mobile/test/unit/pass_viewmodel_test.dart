import 'package:advance_mobile/data/repositories/mock_data_store.dart';
import 'package:advance_mobile/data/repositories/pass/pass_repository_mock.dart';
import 'package:advance_mobile/data/repositories/user/user_repository_mock.dart';
import 'package:advance_mobile/model/pass/pass.dart';
import 'package:advance_mobile/model/user/user.dart';
import 'package:advance_mobile/ui/screens/plans/view_model/pass_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PassViewModel', () {
    late MockDataStore store;
    late MockPassRepository passRepository;
    late MockUserRepository userRepository;
    late PassViewModel viewModel;

    setUp(() {
      store = MockDataStore();
      passRepository = MockPassRepository(store);
      userRepository = MockUserRepository(store);
      viewModel = PassViewModel(passRepository, userRepository);
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('initialize loads available passes and user passes', () async {
      await viewModel.initialize(userId: 'user_elite');

      expect(viewModel.availablePasses, isNotEmpty);
      expect(viewModel.userPasses, isA<List<Pass>>());
    });

    test('8.4 canPurchasePass with active pass returns false', () async {
      await viewModel.initialize(userId: 'user_reyu');
      final canPurchase = await viewModel.canPurchasePass();

      expect(canPurchase, isFalse);
    });

    test('8.4 canPurchasePass with expired pass returns true', () async {
      store.users.add(
        User(
          id: 'user_expired_only',
          email: 'expired@example.com',
          name: 'Expired User',
          activePassId: null,
          createdAt: DateTime.now(),
        ),
      );

      store.passes.add(
        Pass(
          id: 'pass_expired_only',
          userId: 'user_expired_only',
          type: PassType.day,
          startDate: DateTime.now().subtract(const Duration(days: 2)),
          expiryDate: DateTime.now().subtract(const Duration(days: 1)),
          isActive: true,
          price: 5.00,
          ridesUsed: 1,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      );

      await viewModel.initialize(userId: 'user_expired_only');
      final canPurchase = await viewModel.canPurchasePass();

      expect(canPurchase, isTrue);
    });

    test('8.4 canPurchasePass with no pass returns true', () async {
      await viewModel.initialize(userId: 'user_elite');
      final canPurchase = await viewModel.canPurchasePass();

      expect(canPurchase, isTrue);
    });

    test('8.4 getActivePassInfo includes pass type and expiration', () async {
      await viewModel.initialize(userId: 'user_reyu');
      final info = viewModel.getActivePassInfo();

      expect(info, contains('Monthly Pass'));
      expect(info, contains('active'));
      expect(info, contains('/'));
    });

    test('8.4 purchase is prevented when active pass exists', () async {
      await viewModel.initialize(userId: 'user_reyu');
      viewModel.selectPassType(PassType.annual);

      final success = await viewModel.purchaseSelectedPass();

      expect(success, isFalse);
      expect(viewModel.errorMessage, contains('You already have an active'));
      expect(viewModel.activePass?.type, PassType.monthly);
    });

    test('8.5 Property 3: expiration date equals purchase time + validity period', () async {
      // Feature: bike-rental-pass-booking, Property 3: Expiration Date Calculation
      final scenarios = [PassType.day, PassType.monthly, PassType.annual];

      for (final passType in scenarios) {
        final localStore = MockDataStore();
        final localViewModel = PassViewModel(
          MockPassRepository(localStore),
          MockUserRepository(localStore),
        );
        addTearDown(localViewModel.dispose);

        await localViewModel.initialize(userId: 'user_elite');
        localViewModel.selectPassType(passType);

        final success = await localViewModel.purchaseSelectedPass();
        expect(success, isTrue);

        final activePass = localViewModel.activePass;
        expect(activePass, isNotNull);

        final diffDays = activePass!.expiryDate
            .toUtc()
            .difference(activePass.startDate.toUtc())
            .inDays;
        expect(diffDays, passType.durationDays);
      }
    });

    test('8.6 Property 4: created pass round trip preserves key fields', () async {
      // Feature: bike-rental-pass-booking, Property 4: Pass Purchase Round Trip
      final userIds = ['user_reyu', 'user_elite', 'user_somnang'];
      final passTypes = [PassType.day, PassType.monthly, PassType.annual];

      for (final userId in userIds) {
        for (final passType in passTypes) {
          final now = DateTime.now().toUtc();
          final created = await passRepository.createPass(
            Pass(
              id: '',
              userId: userId,
              type: passType,
              startDate: now,
              expiryDate: now.add(Duration(days: passType.durationDays)),
              isActive: true,
              price: passType == PassType.day
                  ? 5.00
                  : passType == PassType.monthly
                  ? 25.00
                  : 150.00,
              ridesUsed: 0,
              createdAt: now,
            ),
          );

          final fetched = await passRepository.getPassById(created.id);
          expect(fetched, isNotNull);
          expect(fetched!.id, created.id);
          expect(fetched.userId, created.userId);
          expect(fetched.type, created.type);
          expect(fetched.expiryDate.toUtc(), created.expiryDate.toUtc());
        }
      }
    });

    test('8.7 Property 5: active pass enforces single-pass ownership', () async {
      // Feature: bike-rental-pass-booking, Property 5: Single Active Pass Enforcement
      final activeUsers = ['user_reyu'];

      for (final userId in activeUsers) {
        final localStore = MockDataStore();
        final localViewModel = PassViewModel(
          MockPassRepository(localStore),
          MockUserRepository(localStore),
        );
        addTearDown(localViewModel.dispose);

        await localViewModel.initialize(userId: userId);
        localViewModel.selectPassType(PassType.day);
        final success = await localViewModel.purchaseSelectedPass();

        expect(success, isFalse);
        expect(localViewModel.errorMessage, contains('active'));
      }
    });

    test('8.8 Property 6: prevention message contains pass type and expiration', () async {
      // Feature: bike-rental-pass-booking, Property 6: Active Pass Purchase Prevention Message
      await viewModel.initialize(userId: 'user_reyu');
      viewModel.selectPassType(PassType.day);
      await viewModel.purchaseSelectedPass();

      final message = viewModel.errorMessage;
      expect(message, isNotNull);
      expect(message, contains('Monthly Pass'));
      expect(message, contains('/'));
    });

    test('8.9 Property 7: past expiration means pass is expired', () {
      // Feature: bike-rental-pass-booking, Property 7: Pass Expiration State
      final pastDates = [
        DateTime.now().subtract(const Duration(minutes: 1)),
        DateTime.now().subtract(const Duration(days: 1)),
        DateTime.now().subtract(const Duration(days: 365)),
      ];

      for (final expiryDate in pastDates) {
        final pass = Pass(
          id: 'p_${expiryDate.millisecondsSinceEpoch}',
          userId: 'user_test',
          type: PassType.day,
          startDate: expiryDate.subtract(const Duration(days: 1)),
          expiryDate: expiryDate,
          isActive: true,
          price: 5.00,
          ridesUsed: 0,
          createdAt: DateTime.now(),
        );

        expect(pass.isExpired, isTrue);
      }
    });

    test('8.10 Property 8: expired pass allows new purchase', () async {
      // Feature: bike-rental-pass-booking, Property 8: Expired Pass Allows New Purchase
      store.users.add(
        User(
          id: 'user_can_repurchase',
          email: 'repurchase@example.com',
          name: 'Repurchase User',
          activePassId: null,
          createdAt: DateTime.now(),
        ),
      );

      store.passes.add(
        Pass(
          id: 'old_pass',
          userId: 'user_can_repurchase',
          type: PassType.day,
          startDate: DateTime.now().subtract(const Duration(days: 3)),
          expiryDate: DateTime.now().subtract(const Duration(days: 2)),
          isActive: true,
          price: 5.00,
          ridesUsed: 1,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      );

      await viewModel.initialize(userId: 'user_can_repurchase');
      viewModel.selectPassType(PassType.monthly);
      final success = await viewModel.purchaseSelectedPass();

      expect(success, isTrue);
      expect(viewModel.activePass, isNotNull);
      expect(viewModel.activePass!.type, PassType.monthly);
    });
  });
}
