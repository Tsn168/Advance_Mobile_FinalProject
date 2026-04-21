import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/app_constants.dart';
import '../../../model/bike/bike.dart';
import '../../../model/station/station.dart';
import '../../states/navigation_state.dart';
import '../map/view_model/booking_viewmodel.dart';
import '../plans/plans_screen.dart';
import '../plans/view_model/pass_viewmodel.dart';
import '../../../widgets/common/custom_card.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/pass_badge.dart';
import '../../theme/app_colors.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({
    super.key,
    required this.station,
    required this.bike,
  });

  final Station station;
  final Bike bike;

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  BookingFlowStatus? _lastFlowStatus;
  String? _lastErrorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final bookingViewModel = context.read<BookingViewModel>();
      bookingViewModel.prepareBooking(
        bikeId: widget.bike.id,
        stationId: widget.station.id,
        slotNumber: widget.bike.slotNumber,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BookingViewModel, PassViewModel>(
      builder: (context, bookingViewModel, passViewModel, _) {
        _handleFlowStateChanges(bookingViewModel);

        final isProcessing = bookingViewModel.state == AppState.loading ||
            bookingViewModel.flowStatus == BookingFlowStatus.checkingPass ||
            bookingViewModel.flowStatus == BookingFlowStatus.booking;

        return Scaffold(
          appBar: AppBar(title: const Text('Confirm Booking')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBookingSummaryCard(),
                  const SizedBox(height: 16),
                  _buildAuthorizationSection(
                    bookingViewModel: bookingViewModel,
                    passViewModel: passViewModel,
                    isProcessing: isProcessing,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingSummaryCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text('Station: ${widget.station.name}'),
          const SizedBox(height: 6),
          Text('Bike: #${widget.bike.id}'),
          const SizedBox(height: 6),
          Text('Slot: ${widget.bike.slotNumber}'),
          const SizedBox(height: 6),
          Text('Model: ${widget.bike.model}'),
          const SizedBox(height: 6),
          Text('Condition: ${widget.bike.condition.displayName}'),
        ],
      ),
    );
  }

  Widget _buildAuthorizationSection({
    required BookingViewModel bookingViewModel,
    required PassViewModel passViewModel,
    required bool isProcessing,
  }) {
    final hasPass = passViewModel.hasActivePass;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Authorization',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (hasPass)
            _buildHasPassSection(passViewModel, bookingViewModel, isProcessing)
          else
            _buildNoPassSection(bookingViewModel, passViewModel, isProcessing),
        ],
      ),
    );
  }

  Widget _buildHasPassSection(
    PassViewModel passViewModel,
    BookingViewModel bookingViewModel,
    bool isProcessing,
  ) {
    final activePass = passViewModel.activePass;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PassBadge(
          badgeType: PassBadgeType.active,
          label: 'Active Pass',
          isActive: true,
        ),
        if (activePass != null) ...[
          const SizedBox(height: 12),
          Text('Type: ${activePass.type.displayName}'),
          const SizedBox(height: 4),
          Text('Expires: ${_formatDate(activePass.expiryDate)}'),
        ],
        const SizedBox(height: 16),
        CustomButton(
          label: 'Confirm Booking',
          onPressed: () => _onConfirmBookingTap(bookingViewModel),
          isLoading: isProcessing,
        ),
      ],
    );
  }

  Widget _buildNoPassSection(
    BookingViewModel bookingViewModel,
    PassViewModel passViewModel,
    bool isProcessing,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PassBadge(
          badgeType: PassBadgeType.inactive,
          label: 'No Active Pass',
          isActive: false,
        ),
        const SizedBox(height: 12),
        const Text('Purchase a single ticket or go to plans to continue.'),
        const SizedBox(height: 16),
        CustomButton(
          label: 'Purchase Single Ticket',
          icon: Icons.confirmation_num,
          onPressed: () => _onPurchaseSingleTicketTap(bookingViewModel, passViewModel),
          isLoading: isProcessing,
        ),
        const SizedBox(height: 8),
        CustomButton(
          label: 'Go to Plans',
          backgroundColor: AppColors.grey200,
          textColor: AppColors.grey800,
          onPressed: () => _onGoToPlansTap(passViewModel),
          isLoading: isProcessing,
        ),
      ],
    );
  }

  Future<void> _onConfirmBookingTap(BookingViewModel bookingViewModel) async {
    await bookingViewModel.confirmBooking();
  }

  Future<void> _onPurchaseSingleTicketTap(
    BookingViewModel bookingViewModel,
    PassViewModel passViewModel,
  ) async {
    final success = await bookingViewModel.purchaseSingleTicketAndBook();
    if (success) {
      await passViewModel.loadUserPasses();
    }
  }

  Future<void> _onGoToPlansTap(PassViewModel passViewModel) async {
    try {
      context.read<NavigationState>().goToPlans();
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    } catch (_) {
      // NavigationState may not be provided in isolated widget tests.
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<PassViewModel>.value(
          value: passViewModel,
          child: const PlansScreen(),
        ),
      ),
    );
  }

  void _handleFlowStateChanges(BookingViewModel bookingViewModel) {
    final flowStatus = bookingViewModel.flowStatus;
    final message = bookingViewModel.errorMessage;

    if (_lastFlowStatus == flowStatus && _lastErrorMessage == message) {
      return;
    }

    _lastFlowStatus = flowStatus;
    _lastErrorMessage = message;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (flowStatus == BookingFlowStatus.booked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking confirmed successfully.'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      }

      if (flowStatus == BookingFlowStatus.failed && message != null) {
        final lowerMessage = message.toLowerCase();
        final isRaceCondition =
            lowerMessage.contains('no longer available') ||
                lowerMessage.contains('not available');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFFD32F2F),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                context.read<BookingViewModel>().confirmBooking();
              },
            ),
          ),
        );

        if (isRaceCondition && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day/${date.year}';
  }
}
