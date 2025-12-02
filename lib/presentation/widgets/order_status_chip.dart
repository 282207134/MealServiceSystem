import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/order_model.dart';

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({
    super.key,
    required this.status,
  });

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status.displayName),
      backgroundColor: _statusBackground(status),
      labelStyle: TextStyle(
        color: _statusTextColor(status),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Color _statusBackground(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.orderPending.withOpacity(0.2);
      case OrderStatus.confirmed:
        return AppColors.orderConfirmed.withOpacity(0.2);
      case OrderStatus.preparing:
        return AppColors.orderPreparing.withOpacity(0.2);
      case OrderStatus.ready:
        return AppColors.orderReady.withOpacity(0.2);
      case OrderStatus.completed:
        return AppColors.orderCompleted.withOpacity(0.2);
      case OrderStatus.cancelled:
        return AppColors.orderCancelled.withOpacity(0.2);
    }
  }

  Color _statusTextColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.orderPending;
      case OrderStatus.confirmed:
        return AppColors.orderConfirmed;
      case OrderStatus.preparing:
        return AppColors.orderPreparing;
      case OrderStatus.ready:
        return AppColors.orderReady;
      case OrderStatus.completed:
        return AppColors.orderCompleted;
      case OrderStatus.cancelled:
        return AppColors.orderCancelled;
    }
  }
}
