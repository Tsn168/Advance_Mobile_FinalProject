import 'package:get_it/get_it.dart';
import 'repositories/base/pass_repository.dart';
import 'repositories/base/station_repository.dart';
import 'repositories/base/bike_repository.dart';
import 'repositories/base/booking_repository.dart';
import 'repositories/mock/mock_pass_repository.dart';
import 'repositories/mock/mock_station_repository.dart';
import 'repositories/mock/mock_bike_repository.dart';
import 'repositories/mock/mock_booking_repository.dart';

final getIt = GetIt.instance;

/// Set up Dependency Injection
/// Call this in main.dart before runApp()
void setupServiceLocator() {
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
