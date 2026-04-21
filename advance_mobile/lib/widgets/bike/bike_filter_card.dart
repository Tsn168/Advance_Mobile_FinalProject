import 'package:flutter/material.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_dimensions.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/theme/app_text_styles.dart';
import '../common/custom_button.dart';

class BikeFilterCard extends StatefulWidget {
  final Function(String, String) onFilterChanged;

  const BikeFilterCard({Key? key, required this.onFilterChanged})
    : super(key: key);

  @override
  State<BikeFilterCard> createState() => _BikeFilterCardState();
}

class _BikeFilterCardState extends State<BikeFilterCard> {
  String selectedCondition = 'All';
  String selectedAvailability = 'All';

  final List<String> conditions = ['All', 'Excellent', 'Good', 'Fair'];
  final List<String> availabilities = ['All', 'Available', 'Booked'];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Bikes',
              style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Condition Filter
            Text(
              'Condition',
              style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              children: conditions.map((condition) {
                final isSelected = selectedCondition == condition;
                return ChoiceChip(
                  label: Text(condition),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selectedCondition = condition;
                    });
                    widget.onFilterChanged(
                      selectedCondition,
                      selectedAvailability,
                    );
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.grey700,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Availability Filter
            Text(
              'Availability',
              style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              children: availabilities.map((availability) {
                final isSelected = selectedAvailability == availability;
                return ChoiceChip(
                  label: Text(availability),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selectedAvailability = availability;
                    });
                    widget.onFilterChanged(
                      selectedCondition,
                      selectedAvailability,
                    );
                  },
                  selectedColor: AppColors.success,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.grey700,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Reset Button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                label: 'Reset Filters',
                onPressed: () {
                  setState(() {
                    selectedCondition = 'All';
                    selectedAvailability = 'All';
                  });
                  widget.onFilterChanged('All', 'All');
                },
                backgroundColor: AppColors.grey300,
                textColor: AppColors.grey700,
                height: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
