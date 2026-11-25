import 'package:flutter/material.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../data/models/orders_history_model.dart';

String ordersText(BuildContext context, String ar, String en) =>
    isArabic(context) ? ar : en;
String orderStatusText(BuildContext context, OrderHistoryItem order) {
  if (order.statusValue.trim().toLowerCase() == 'invoiced') {
    return ordersText(context, 'تم إصدار الفاتورة', 'Invoiced');
  }
  if (isArabic(context) && order.statusLabel.isNotEmpty) {
    return order.statusLabel;
  }
  const names = {
    'new': ['جديد', 'New'],
    'pending': ['بانتظار إسناد فني', 'Awaiting technician'],
    'assigned': ['تم إسناد فني', 'Technician assigned'],
    'on_the_way': ['الفني في الطريق', 'Technician on the way'],
    'in_progress': ['جاري التنفيذ', 'In progress'],
    'completed': ['مكتمل', 'Completed'],
    'complete': ['مكتمل', 'Completed'],
    'finished': ['مكتمل', 'Completed'],
    'closed': ['مغلق', 'Closed'],
    'delivered': ['تم التسليم', 'Delivered'],
    'cancelled': ['ملغي', 'Cancelled'],
    'canceled': ['ملغي', 'Cancelled'],
    'rejected': ['مرفوض', 'Rejected'],
  };
  if (order.statusValue.isEmpty && order.statusLabel.isEmpty) {
    return ordersText(context, 'غير محدد', 'Unknown');
  }
  final value = names[order.statusValue.toLowerCase()];
  return value == null
      ? (order.statusLabel.isNotEmpty ? order.statusLabel : order.statusValue)
      : ordersText(context, value[0], value[1]);
}
