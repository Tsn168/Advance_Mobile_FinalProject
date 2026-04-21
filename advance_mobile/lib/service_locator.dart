import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/repositories/bike/bike_repository.dart';
import 'data/repositories/bike/bike_repository_firebase.dart';
import 'data/repositories/bike/bike_repository_mock.dart';
import 'data/repositories/booking/booking_repository.dart';
import 'data/repositories/booking/booking_repository_firebase.dart';
import 'data/repositories/booking/booking_repository_mock.dart';
import 'data/repositories/mock_data_store.dart';
import 'data/repositories/pass/pass_repository.dart';
import 'data/repositories/pass/pass_repository_firebase.dart';
import 'data/repositories/pass/pass_repository_mock.dart';
import 'services/error_handler.dart';
import 'data/repositories/station/station_repository.dart';
import 'data/repositories/station/station_repository_firebase.dart';
import 'data/repositories/station/station_repository_mock.dart';
import 'data/repositories/user/user_repository.dart';
import 'data/repositories/user/user_repository_firebase.dart';
import 'data/repositories/user/user_repository_mock.dart';
import 'services/firebase_service.dart';
import 'ui/screens/home/view_model/booking_viewmodel.dart';
import 'ui/screens/map/view_model/bike_viewmodel.dart';
import 'ui/screens/map/view_model/map_viewmodel.dart';
import 'ui/screens/plans/view_model/pass_viewmodel.dart';
import 'ui/screens/station_detail/view_model/station_detail_view_model.dart';
import 'ui/states/app_state.dart';
import 'ui/states/navigation_state.dart';
import 'services/local_storage_service.dart';

final getIt = GetIt.instance;

/// Set up Dependency Injection
/// Call this in main.dart before runApp()
Future<void> setupServiceLocator() async {
  if (getIt.isRegistered<MockDataStore>()) {
    return;
  }

  final useFirebaseRepositories = FirebaseService.canUseFirebaseRepositories;

  getIt.registerLazySingleton<MockDataStore>(() => MockDataStore());
  getIt.registerLazySingleton<AppState>(() => AppState());
  getIt.registerLazySingleton<NavigationState>(() => NavigationState());

  // Local Storage Service (Async initialization)
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<LocalStorageService>(
    LocalStorageService(sharedPrefs),
  );

  if (useFirebaseRepositories) {
    getIt.registerLazySingleton<IPassRepository>(() => PassRepositoryFirebase());
    getIt.registerLazySingleton<IStationRepository>(
      () => StationRepositoryFirebase(),
    );
    getIt.registerLazySingleton<IBikeRepository>(() => BikeRepositoryFirebase());
    getIt.registerLazySingleton<IBookingRepository>(
      () => BookingRepositoryFirebase(),
    );
    getIt.registerLazySingleton<IUserRepository>(() => UserRepositoryFirebase());
  } else {
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
  }

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

  getIt.registerFactory<StationDetailViewModel>(
    () => StationDetailViewModel(
      getIt<IBikeRepository>(),
      getIt<IStationRepository>(),
    ),
  );

  getIt.registerFactory<BookingViewModel>(
    () =>
        BookingViewModel(getIt<IBookingRepository>(), getIt<IPassRepository>()),
  );
}
