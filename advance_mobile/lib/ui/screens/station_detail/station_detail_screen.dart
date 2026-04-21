import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/app_constants.dart';
import '../../../model/bike/bike.dart';
import '../../../model/station/station.dart';
import '../../../service_locator.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../../widgets/bike/bike_card.dart';
import '../booking_confirmation/booking_confirmation_screen.dart';
import '../map/view_model/booking_viewmodel.dart';
import '../plans/view_model/pass_viewmodel.dart';
import 'view_model/station_detail_view_model.dart';

class StationDetailScreen extends StatefulWidget {
  const StationDetailScreen({
    super.key,
    required this.stationId,
  });

  final String stationId;

  @override
  State<StationDetailScreen> createState() => _StationDetailScreenState();
}

class _StationDetailScreenState extends State<StationDetailScreen> {
  StationDetailViewModel? _viewModel;
  var _ownsViewModel = false;
  var _hasRequestedInitialLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_viewModel != null) {
      return;
    }

    final provided = context.read<StationDetailViewModel?>();
    if (provided != null) {
      _viewModel = provided;
      _ownsViewModel = false;
    } else {
      _viewModel = getIt<StationDetailViewModel>();
      _ownsViewModel = true;
    }

    if (!_hasRequestedInitialLoad) {
      _hasRequestedInitialLoad = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _viewModel?.loadStationDetails(widget.stationId);
      });
    }
  }

  @override
  void dispose() {
    if (_ownsViewModel) {
      _viewModel?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel;
    if (viewModel == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screen = Consumer<StationDetailViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {},
              ),
              title: const Text(
                'KINETIC',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              actions: const [
                Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFFE3F2FD),
                    child: Icon(Icons.person, size: 18, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'View Available Bike',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF78909C),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(child: _buildBody(context, viewModel)),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 1,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                if (index == 1) {
                  return;
                }
                Navigator.of(context).maybePop();
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.directions_bike),
                  label: 'Bike',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet),
                  label: 'Wallet',
                ),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
          );
        },
    );

    if (_ownsViewModel) {
      return ChangeNotifierProvider<StationDetailViewModel>.value(
        value: viewModel,
        child: screen,
      );
    }

    return screen;
  }

  Widget _buildBody(BuildContext context, StationDetailViewModel viewModel) {
    if (viewModel.state == AppState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.state == AppState.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                viewModel.errorMessage ?? 'Failed to load station details',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: () => viewModel.refreshBikes(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final station = viewModel.station;
    if (station == null) {
      return const Center(child: Text('Station not found'));
    }

    final listEntries = _buildSlotEntries(station, viewModel);
    if (listEntries.isEmpty) {
      return const Center(child: Text('No bike slots available'));
    }

    return RefreshIndicator(
      onRefresh: viewModel.refreshBikes,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: listEntries.length,
        itemBuilder: (context, index) {
          final entry = listEntries[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: entry.bike != null
                ? BikeCard(
                    slotNumber: entry.slotNumber,
                    bikeModel: entry.bike!.model,
                    condition: entry.bike!.condition.displayName,
                    isAvailable: entry.bike!.isAvailable,
                    onBook: () => _onBikeTap(context, viewModel, station, entry.bike!),
                  )
                : Card(
                    color: AppColors.grey200,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          const Icon(Icons.crop_free, color: AppColors.grey600),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            'Slot #${entry.slotNumber} - Empty',
                            style: const TextStyle(
                              color: AppColors.grey600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  List<_SlotEntry> _buildSlotEntries(
    Station station,
    StationDetailViewModel viewModel,
  ) {
    final entries = <_SlotEntry>[];

    for (final bike in viewModel.availableBikes) {
      entries.add(_SlotEntry(slotNumber: bike.slotNumber, bike: bike));
    }

    for (final bike in viewModel.unavailableBikes) {
      entries.add(_SlotEntry(slotNumber: bike.slotNumber, bike: bike));
    }

    final usedSlots = viewModel.bikes.map((bike) => bike.slotNumber).toSet();
    for (var slot = 1; slot <= station.totalSlots; slot++) {
      if (!usedSlots.contains(slot)) {
        entries.add(_SlotEntry(slotNumber: slot));
      }
    }

    entries.sort((a, b) {
      int rank(_SlotEntry e) {
        if (e.bike == null) {
          return 2;
        }
        return e.bike!.isAvailable ? 0 : 1;
      }

      final rankDiff = rank(a).compareTo(rank(b));
      if (rankDiff != 0) {
        return rankDiff;
      }
      return a.slotNumber.compareTo(b.slotNumber);
    });

    return entries;
  }

  void _onBikeTap(
    BuildContext context,
    StationDetailViewModel viewModel,
    Station station,
    Bike bike,
  ) {
    viewModel.selectBike(bike.id);

    final bookingViewModel = context.read<BookingViewModel>();
    final passViewModel = context.read<PassViewModel>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiProvider(
          providers: [
            ChangeNotifierProvider<BookingViewModel>.value(
              value: bookingViewModel,
            ),
            ChangeNotifierProvider<PassViewModel>.value(value: passViewModel),
          ],
          child: BookingConfirmationScreen(station: station, bike: bike),
        ),
      ),
    );
  }
}

class _SlotEntry {
  const _SlotEntry({required this.slotNumber, this.bike});

  final int slotNumber;
  final Bike? bike;
}
