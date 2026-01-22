import 'package:flutter/material.dart';
import '../../utils/validators.dart';
import '../services/payment_service.dart';

/// A simple donation page that lets the user enter any desired amount and
/// proceed to Razorpay checkout using `PaymentService`.
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

    // Parse amount (allow commas and trim)
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
      final result = await _paymentService.openCheckout(
        amount: amount,
        contact: _contactController.text.trim(),
        email: _emailController.text.trim(),
        timeout: const Duration(minutes: 5),
      );

      if (result != null) {
        // Payment success
        if (!mounted) return;
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Payment successful'),
            content: Text('Payment ID: ${result.paymentId}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Timeout or cancelled
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment timed out or was cancelled')),
        );
      }
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
                  final cleaned = v.trim().replaceAll(',', '');
                  final val = double.tryParse(cleaned);
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
                // Email
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final email = v.trim();
                  final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
                  if (!emailRegex.hasMatch(email)) return 'Enter a valid email';
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
