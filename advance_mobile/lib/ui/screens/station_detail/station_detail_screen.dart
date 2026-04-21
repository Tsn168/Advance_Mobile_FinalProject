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
import '../../states/navigation_state.dart';
import 'view_model/station_detail_view_model.dart';

class StationDetailScreen extends StatefulWidget {
  const StationDetailScreen({super.key, required this.stationId});

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
            leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
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
            currentIndex: context.watch<NavigationState>().currentTabIndex,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              final navState = context.read<NavigationState>();
              if (index == navState.currentTabIndex) {
                Navigator.of(context).maybePop();
                return;
              }
              navState.setTab(index);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
              BottomNavigationBarItem(
                icon: Icon(Icons.card_membership),
                label: 'Plans',
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
          
          if (entry.isEmptySummary) {
            return Card(
              color: const Color(0xFFF1F8E9),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFC5E1A5)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Color(0xFF558B2F)),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      '${entry.emptyCount} Empty Slots Available',
                      style: const TextStyle(
                        color: Color(0xFF33691E),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (entry.bike != null) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: BikeCard(
                slotNumber: entry.slotNumber ?? 0,
                bikeModel: entry.bike!.model,
                condition: entry.bike!.condition.displayName,
                isAvailable: entry.bike!.isAvailable,
                onBook: () =>
                    _onBikeTap(context, viewModel, station, entry.bike!),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<_SlotEntry> _buildSlotEntries(
    Station station,
    StationDetailViewModel viewModel,
  ) {
    final entries = <_SlotEntry>[];

    // Added available bikes
    for (final bike in viewModel.availableBikes) {
      entries.add(_SlotEntry(slotNumber: bike.slotNumber, bike: bike));
    }

    // Add empty slots summary
    final emptyCount = viewModel.emptySlots;
    if (emptyCount > 0) {
      entries.add(_SlotEntry(isEmptySummary: true, emptyCount: emptyCount));
    }

    // Sort bikes by slot number, but keep summary at the bottom
    entries.sort((a, b) {
      if (a.isEmptySummary) return 1;
      if (b.isEmptySummary) return -1;
      return (a.slotNumber ?? 0).compareTo(b.slotNumber ?? 0);
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
          child: BookingConfirmationScreen(
            station: station,
            bike: bike,
            onBikeUnavailable: () async {
              if (!mounted) {
                return;
              }
              await viewModel.refreshBikes();
            },
          ),
        ),
      ),
    );
  }
}

class _SlotEntry {
  const _SlotEntry({
    this.slotNumber,
    this.bike,
    this.isEmptySummary = false,
    this.emptyCount = 0,
  });

  final int? slotNumber;
  final Bike? bike;
  final bool isEmptySummary;
  final int emptyCount;
}
