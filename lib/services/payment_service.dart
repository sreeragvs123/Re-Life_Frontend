import 'dart:async';  // import asynchronous programming tools

import 'package:flutter/material.dart'; // UI and utility import
import 'package:razorpay_flutter/razorpay_flutter.dart'; // provide access to razorpay_APi

/// A small wrapper around the `razorpay_flutter` plugin that provides a
/// Future-based `openCheckout` API and safer handling of responses.



class PaymentService {
  late final Razorpay _razorpay; // this is a private keyword - intialised later but only once(this is to make the variable immutable)


  static const String razorpayKey =
      String.fromEnvironment('RAZORPAY_KEY', defaultValue: 'rzp_test_RJsrBHFxuUDEVX'); // API key

  Completer<PaymentSuccessResponse?>? _completer;

  PaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess); // make a call back on second arument if first argument returns the desired output
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  /// Opens the Razorpay checkout and returns a [Future] that completes with
  /// the [PaymentSuccessResponse] on success, throws on error, or returns
  /// `null` if the operation times out.
  ///
  /// Callers should `await` this method to know the outcome.
  Future<PaymentSuccessResponse?> openCheckout({
    required double amount,
    String contact = '',
    String email = '',
    Duration timeout = const Duration(minutes: 5),
  }) async {
    if (amount <= 0) {
      return Future.error(ArgumentError.value(amount, 'amount', 'Must be > 0'));
    }

    if (_completer != null && !_completer!.isCompleted) {
      return Future.error(StateError('A checkout is already in progress'));
    }

    _completer = Completer<PaymentSuccessResponse?>();

    final options = {
      'key': razorpayKey,
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'Re-Life',
      'description': 'Donation Payment',
      'prefill': {
        'contact': contact,
        'email': email,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      debugPrint('Razorpay options: $options');
      _razorpay.open(options);
    } catch (e, st) {
      debugPrint('Error opening Razorpay checkout: $e\n$st');
      if (!(_completer?.isCompleted ?? true)) {
        _completer?.completeError(e);
      }
    }

    // Return the completer's future but guard with a timeout so callers
    // won't wait forever if something goes wrong.
    try {
      final result = await _completer!.future.timeout(timeout, onTimeout: () {
        if (!(_completer?.isCompleted ?? true)) {
          _completer?.complete(null);
        }
        return null;
      });
      return result;
    } finally {
      // cleanup so future calls can create a new completer
      _completer = null;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(response);
    }
    debugPrint("Payment Successful: ${response.paymentId}");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    final err = Exception('Payment Error: ${response.code} | ${response.message}');
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError(err);
    }
    debugPrint("Payment Error: ${response.code} | ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // External wallets don't mean success — just notify and allow callers to
    // handle it via logs or UI if desired.
    debugPrint("External Wallet: ${response.walletName}");
  }

  /// Clear listeners and resources. Call from a widget's `dispose()`.
  void dispose() {
    try {
      _razorpay.clear();
    } catch (e) {
      debugPrint('Error clearing Razorpay: $e');
    }
  }
}