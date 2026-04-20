import 'package:flutter/material.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/theme/app_text_styles.dart';
import '../common/custom_card.dart';

enum PaymentMethod { creditCard, debitCard, applePay, googlePay, wallet }

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final String? cardNumber;
  final String? holderName;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodCard({
    Key? key,
    required this.method,
    this.cardNumber,
    this.holderName,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  String get methodLabel {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
      case PaymentMethod.wallet:
        return 'Wallet';
    }
  }

  IconData get methodIcon {
    switch (method) {
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.debitCard:
        return Icons.credit_card;
      case PaymentMethod.applePay:
        return Icons.apple;
      case PaymentMethod.googlePay:
        return Icons.payment;
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet;
    }
  }

  Color get borderColor {
    return isSelected ? AppColors.primary : AppColors.grey300;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomCard(
        border: Border.all(color: borderColor, width: isSelected ? 2 : 1.5),
        backgroundColor: isSelected
            ? AppColors.primary.withOpacity(0.05)
            : AppColors.white,
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: methodIcon == Icons.apple
                    ? AppColors.black
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  methodIcon,
                  color: methodIcon == Icons.apple
                      ? AppColors.white
                      : AppColors.primary,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    methodLabel,
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (cardNumber != null)
                    Text(
                      cardNumber!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  if (holderName != null)
                    Text(
                      holderName!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.grey600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Selection Radio
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.grey400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
