import 'package:get_it/get_it.dart';

import 'data/repositories/bike/bike_repository.dart';
import 'data/repositories/bike/bike_repository_mock.dart';
import 'data/repositories/booking/booking_repository.dart';
import 'data/repositories/booking/booking_repository_mock.dart';
import 'data/repositories/mock_data_store.dart';
import 'data/repositories/pass/pass_repository.dart';
import 'data/repositories/pass/pass_repository_mock.dart';
import 'data/repositories/station/station_repository.dart';
import 'data/repositories/station/station_repository_mock.dart';
import 'data/repositories/user/user_repository.dart';
import 'data/repositories/user/user_repository_mock.dart';
import 'ui/screens/home/view_model/booking_viewmodel.dart';
import 'ui/screens/map/view_model/bike_viewmodel.dart';
import 'ui/screens/map/view_model/map_viewmodel.dart';
import 'ui/screens/plans/view_model/pass_viewmodel.dart';
import 'ui/states/app_state.dart';
import 'ui/states/navigation_state.dart';

final getIt = GetIt.instance;

/// Set up Dependency Injection
/// Call this in main.dart before runApp()
Future<void> setupServiceLocator() async {
  if (getIt.isRegistered<AppState>()) {
    return;
  }

  getIt.registerLazySingleton<MockDataStore>(() => MockDataStore());
  getIt.registerLazySingleton<AppState>(() => AppState());
  getIt.registerLazySingleton<NavigationState>(() => NavigationState());

  // Register Mock Repositories (for development/testing)
  // Replace with Firebase repositories when backend is ready
  getIt.registerLazySingleton<IPassRepository>(
    () => MockPassRepository(getIt<MockDataStore>()),
  );

  getIt.registerLazySingleton<IStationRepository>(
    () => MockStationRepository(getIt<MockDataStore>()),
  );

  getIt.registerLazySingleton<IBikeRepository>(
    () => MockBikeRepository(getIt<MockDataStore>()),
  );

  getIt.registerLazySingleton<IBookingRepository>(
    () => MockBookingRepository(getIt<MockDataStore>()),
  );

  getIt.registerLazySingleton<IUserRepository>(
    () => MockUserRepository(getIt<MockDataStore>()),
  );

  // Register ViewModels
  getIt.registerFactory<PassViewModel>(
    () => PassViewModel(getIt<IPassRepository>(), getIt<IUserRepository>()),
  );

  getIt.registerFactory<MapViewModel>(
    () => MapViewModel(getIt<IStationRepository>()),
  );

  getIt.registerFactory<BikeViewModel>(
    () => BikeViewModel(getIt<IBikeRepository>()),
  );

  getIt.registerFactory<BookingViewModel>(
    () =>
        BookingViewModel(getIt<IBookingRepository>(), getIt<IPassRepository>()),
  );
}
