import 'package:flutter/material.dart';
import '../models/payment.dart';          // ⭐ NEW
import '../api/payment_api.dart';         // ⭐ NEW
import '../services/payment_service.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({Key? key}) : super(key: key);

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _paymentService = PaymentService();

  bool _loading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _paymentService.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final raw = _amountController.text.trim().replaceAll(',', '');
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount > 0')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // ── Step 1: Open Razorpay checkout ─────────────────────────────────────
      final result = await _paymentService.openCheckout(
        amount: amount,
        contact: _contactController.text.trim(),
        email: _emailController.text.trim(),
        timeout: const Duration(minutes: 5),
      );

      if (result == null) {
        // Timeout or cancelled — don't save anything
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment timed out or was cancelled')),
        );
        return;
      }

      // ── Step 2: Save the payment record to backend ──────────────────────────
      try {
        await PaymentApi.createPayment(
          Payment(
            razorpayPaymentId: result.paymentId ?? '',
            amount: amount,
            contact: _contactController.text.trim(),
            email: _emailController.text.trim(),
            status: 'SUCCESS',
          ),
        );
      } catch (_) {
        // Backend save failed — payment still succeeded on Razorpay,
        // so just log silently and don't block the success dialog
      }

      // ── Step 3: Show success dialog ─────────────────────────────────────────
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Payment Successful'),
          content: Text('Payment ID: ${result.paymentId}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donate to Re-Life')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter the amount you want to donate (in ₹)',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (e.g. 499.00)',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter an amount';
                  final val = double.tryParse(v.trim().replaceAll(',', ''));
                  if (val == null || val <= 0) return 'Enter a valid amount > 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contact (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
                  if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Donate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}