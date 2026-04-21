import 'package:flutter/material.dart';
import '../../../../model/pass/pass.dart';

class SubscriptionCard extends StatelessWidget {
  final Pass? activePass;

  const SubscriptionCard({super.key, this.activePass});

  @override
  Widget build(BuildContext context) {
    if (activePass == null) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.info_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text(
                'No Active Subscription',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Purchase a pass to start riding!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to plans (handled by parent context navigation)
                },
                child: const Text('View Plans'),
              ),
            ],
          ),
        ),
      );
    }

    return _buildActivePass(activePass!);
  }

  Widget _buildActivePass(Pass pass) {
    // Calculate progress (time-based)
    final totalDays = pass.type.durationDays;
    final remainingDays = pass.remainingDays;
    final elapsedDays = totalDays - remainingDays;
    // Ensure we don't divide by zero and clamp between 0.0 and 1.0
    final progress = totalDays > 0 
        ? (elapsedDays / totalDays).clamp(0.0, 1.0) 
        : 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2196F3).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pass.type.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Active until ${pass.expiryDate.day}/${pass.expiryDate.month}/${pass.expiryDate.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$remainingDays days left',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% used',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.blue.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${pass.ridesUsed} rides taken with this pass',
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Colors.blue.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
