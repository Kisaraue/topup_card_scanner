import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/service_provider.dart';
import '../providers/scanner_provider.dart';

class DialerScreen extends ConsumerWidget {
  const DialerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scannedText = ref.watch(scannedTextProvider);
    final serviceProviders = ref.watch(serviceProvidersProvider);
    final selectedProvider = ref.watch(selectedServiceProvider);

    Future<void> _dialNumber(String formattedNumber) async {
      final url = 'tel:$formattedNumber';
      if (await canLaunchUrl(url as Uri)) {
        await launchUrl(url as Uri);
      } else {
        throw 'Could not launch $url';
      }
    }

    String getFormattedNumber(String number, ServiceProvider? provider) {
      if (provider == null) return number;
      return provider.dialingCode.replaceAll('<scanned_number>', number);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Top-up Dialer')),
      body: Center(
        child: scannedText == null
            ? Text('No QR Code Scanned')
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Scanned Number: $scannedText',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            DropdownButton<ServiceProvider>(
              hint: Text('Select Service Provider'),
              value: selectedProvider,
              items: serviceProviders.map((provider) {
                return DropdownMenuItem(
                  value: provider,
                  child: Text(provider.name),
                );
              }).toList(),
              onChanged: (newProvider) {
                ref.read(selectedServiceProvider.notifier).state =
                    newProvider;
              },
            ),
            SizedBox(height: 20),
            if (selectedProvider != null)
              ElevatedButton(
                onPressed: () {
                  final formattedNumber = getFormattedNumber(
                      scannedText, selectedProvider);
                  _dialNumber(formattedNumber);
                },
                child: Text('Dial Now'),
              ),
          ],
        ),
      ),
    );
  }
}
