import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_provider.dart';

final scannedTextProvider = StateProvider<String?>((ref) => null);

// Updated serviceProvidersProvider with the logoUrl field
final serviceProvidersProvider = Provider<List<ServiceProvider>>((ref) {
  return [
    ServiceProvider(
      name: 'Dialog',
      dialingCode: '*#<scanned_number>#',
      logoUrl: 'assets/images/dialog.jpg',
    ),
    ServiceProvider(
      name: 'Mobitel',
      dialingCode: '#<scanned_number>#',
      logoUrl: 'assets/images/mobitel.jpg',
    ),
    ServiceProvider(
      name: 'Hutch',
      dialingCode: '*<scanned_number>#',
      logoUrl: 'assets/images/hutch.png',
    ),
    ServiceProvider(
      name: 'Airtel',
      dialingCode: '123<scanned_number>#',
      logoUrl: 'assets/images/airtel.png',
    ),
  ];
});

// Selected Service Provider
final selectedServiceProvider = StateProvider<ServiceProvider?>((ref) => null);
