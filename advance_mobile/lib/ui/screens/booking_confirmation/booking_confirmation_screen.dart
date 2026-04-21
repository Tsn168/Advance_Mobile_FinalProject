import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/app_constants.dart';
import '../../../model/bike/bike.dart';
import '../../../model/station/station.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../home/view_model/booking_viewmodel.dart';
import '../plans/plans_screen.dart';
import '../plans/view_model/pass_viewmodel.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({
    super.key,
    required this.station,
    required this.bike,
    this.onBikeUnavailable,
  });

  final Station station;
  final Bike bike;
  final Future<void> Function()? onBikeUnavailable;

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
          appBar: AppBar(
        title: const Text('Confirm Booking'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
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
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Summary',
              style: AppTextStyles.h5,
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
      ),
    );
  }

  Widget _buildAuthorizationSection({
    required BookingViewModel bookingViewModel,
    required PassViewModel passViewModel,
    required bool isProcessing,
  }) {
    final hasPass = passViewModel.hasActivePass;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Authorization',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 12),
            if (isProcessing) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
            ],
            if (hasPass)
              _buildHasPassSection(passViewModel, bookingViewModel, isProcessing)
            else
              _buildNoPassSection(bookingViewModel, passViewModel, isProcessing),
          ],
        ),
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
        Row(
          children: const [
            Icon(
              Icons.verified,
              color: Color(0xFF2E7D32),
              semanticLabel: 'Pass verified',
            ),
            SizedBox(width: 8),
            Text(
              'Active Pass',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
        if (activePass != null) ...[
          const SizedBox(height: 8),
          Text('Type: ${activePass.type.displayName}'),
          const SizedBox(height: 4),
          Text('Expires: ${_formatDate(activePass.expiryDate)}'),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isProcessing
                ? null
                : () => _onConfirmBookingTap(bookingViewModel),
            child: const Text('Confirm Booking'),
          ),
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
        Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFF57C00)),
            SizedBox(width: 8),
            Text(
              'No Active Pass',
              style: TextStyle(
                color: Color(0xFFF57C00),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Purchase a single ticket or go to plans to continue.'),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isProcessing
                ? null
                : () => _onPurchaseSingleTicketTap(
                      bookingViewModel,
                      passViewModel,
                    ),
            icon: const Icon(Icons.confirmation_num),
            label: const Text('Purchase Single Ticket'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: isProcessing ? null : () => _onGoToPlansTap(passViewModel),
            child: const Text('Go to Plans'),
          ),
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
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<PassViewModel>.value(
          value: passViewModel,
          child: const PlansScreen(),
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    await passViewModel.loadUserPasses();
    final bookingViewModel = context.read<BookingViewModel>();
    await bookingViewModel.prepareBooking(
      bikeId: widget.bike.id,
      stationId: widget.station.id,
      slotNumber: widget.bike.slotNumber,
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

        if (isRaceCondition) {
          unawaited(_showBikeUnavailableDialog(message));
          return;
        }

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
      }
    });
  }

  Future<void> _showBikeUnavailableDialog(String message) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Bike Unavailable'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Back to Station'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    final callback = widget.onBikeUnavailable;
    if (callback != null) {
      await callback();
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day/${date.year}';
  }
}
