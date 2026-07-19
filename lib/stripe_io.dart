import 'package:flutter_stripe/flutter_stripe.dart';

Future<void> initStripe() async {
  Stripe.publishableKey =
      'pk_test_51TnO0A7TpZVzLqUn7gkDK2KO7IISMne8hXTvU5psJ5R8zpZXjxMCSrvoH5ogjgcyJ8OvCspxNih4RroIqXE4iIhi00mLliLyj3';
  await Stripe.instance.applySettings();
}
