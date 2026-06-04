double pendingAmount({
  required double planPrice,
  required double amountPaid,
}) {
  final pending = planPrice - amountPaid;
  return pending < 0 ? 0 : pending;
}

int? renewalDaysLeft(String? endDateRaw, {DateTime? now}) {
  if (endDateRaw == null) return null;
  final endDate = DateTime.tryParse(endDateRaw);
  if (endDate == null) return null;
  final reference = now ?? DateTime.now();
  return endDate.difference(reference).inDays.clamp(0, 999);
}

bool isPaymentDue(String status) {
  final s = status.toLowerCase();
  return s == 'due' || s == 'partial';
}
