omport 'package:get_it/get_it.dart';
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
  // TODO: Switch to real repositories once Firebase is set up

  getIt.registerSingleton<IPassRepository>(MockPassRepository());

  getIt.registerSingleton<IStationRepository>(MockStationRepository());

  getIt.registerSingleton<IBikeRepository>(MockBikeRepository());

  getIt.registerSingleton<IBookingRepository>(MockBookingRepository());

  // TODO: Add ViewModels here after they are created
  // Example:
  // getIt.registerSingleton<PassViewModel>(
  //   PassViewModel(getIt<IPassRepository>()),
  // );
}
