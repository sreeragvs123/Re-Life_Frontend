// lib/utils/validators.dart

class Validators {
  /// Universal validator
  /// type: "name", "email", "password", "mobile", "quantity", "bloodGroup", "place", "age"
  static String? validate({
    required String value,
    required String type,
    int? minLength,
    int? maxLength,
    int? exactLength,
    int? minValue,
    int? maxValue,
  }) {
    value = value.trim();

    if (value.isEmpty) return 'This field is required';

    switch (type) {
      case 'name':
      case 'place':
        minLength ??= 2;
        if (value.length < minLength) {
          return 'Must be at least $minLength characters';
        }
        return null;

      case 'email':
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
        return null;

      case 'password':
        minLength ??= 5;
        if (value.length < minLength) {
          return 'Password must be at least $minLength characters';
        }
        return null;

      case 'mobile':
        final numeric = RegExp(r'^[0-9]+$');
        exactLength ??= 10;
        if (!numeric.hasMatch(value)) return 'Only digits allowed';
        if (value.length != exactLength) {
          return 'Mobile number must be $exactLength digits';
        }
        return null;

      case 'quantity':
        final numVal = int.tryParse(value);
        minValue ??= 1;
        if (numVal == null || numVal < minValue) {
          return 'Enter valid quantity (>= $minValue)';
        }
        if (maxValue != null && numVal > maxValue) {
          return 'Quantity must be <= $maxValue';
        }
        return null;

      case 'age':
        final age = int.tryParse(value);
        if (age == null) return 'Enter valid number';
        if (age < 1 || age > 120) return 'Enter realistic age (1-120)';
        return null;

      case 'bloodGroup':
        const validGroups = ['A+','A-','B+','B-','AB+','AB-','O+','O-'];
        if (!validGroups.contains(value.toUpperCase())) {
          return 'Enter valid blood group (A+, O-, etc.)';
        }
        return null;

      default:
        return null;
    }
  }
}