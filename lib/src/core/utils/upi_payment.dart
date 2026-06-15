import 'package:flutter/foundation.dart';

class UpiPayment {
  UpiPayment._();

  static String buildUri({
    required String upiId,
    required String payeeName,
    required double amount,
    String? note,
    String currency = 'INR',
  }) {
    final params = <String, String>{
      'pa': upiId.trim(),
      'pn': payeeName.trim(),
      'am': amount.toStringAsFixed(2),
      'cu': currency,
      if (note != null && note.trim().isNotEmpty) 'tn': note.trim(),
    };

    final query = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return 'upi://pay?$query';
  }
}
