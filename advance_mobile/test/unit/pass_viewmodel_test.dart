import 'package:advance_mobile/model/pass/pass.dart';
import 'package:advance_mobile/data/repositories/mock_data_store.dart';
import 'package:advance_mobile/data/repositories/pass/pass_repository_mock.dart';
import 'package:advance_mobile/data/repositories/user/user_repository_mock.dart';
import 'package:advance_mobile/ui/screens/plans/view_model/pass_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PassViewModel', () {
    late MockDataStore store;
    late PassViewModel viewModel;
    late MockUserRepository userRepository;

    setUp(() {
      store = MockDataStore();
      userRepository = MockUserRepository(store);
      viewModel = PassViewModel(MockPassRepository(store), userRepository);
    });

    test('initialize loads available and active pass', () async {
      await viewModel.initialize();

      expect(viewModel.availablePasses, isNotEmpty);
      expect(viewModel.userPasses, isNotEmpty);
      expect(viewModel.hasActivePass, isTrue);
      expect(viewModel.activePass?.type, PassType.monthly);
    });

    test('purchaseSelectedPass fails when no pass type selected', () async {
      await viewModel.initialize();

      final success = await viewModel.purchaseSelectedPass();

      expect(success, isFalse);
      expect(viewModel.errorMessage, contains('Please select a pass type'));
    });

    test(
      'purchaseSelectedPass creates new active pass and updates user',
      () async {
        await viewModel.initialize();
        viewModel.selectPassType(PassType.annual);

        final success = await viewModel.purchaseSelectedPass();
        final currentUser = await userRepository.getCurrentUser();

        expect(success, isTrue);
        expect(viewModel.activePass, isNotNull);
        expect(viewModel.activePass?.type, PassType.annual);
        expect(currentUser?.activePassId, equals(viewModel.activePass?.id));
        expect(viewModel.userPasses.length, greaterThanOrEqualTo(2));
      },
    );
  });
}
