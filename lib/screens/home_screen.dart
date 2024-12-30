import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/service_provider.dart';
import '../providers/scanner_provider.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  @override
  Widget build(BuildContext context) {
    final serviceProviders = ref.watch(serviceProvidersProvider);
    final scannedText = ref.watch(scannedTextProvider);
    final selectedProvider = ref.watch(selectedServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          // QR Code Scanner inside rounded rectangle
          Align(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20), // Rounded corners
              child: Container(
                width: 350, // Width of the scanner area
                height: 250, // Height of the scanner area
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: MobileScanner(
                  onDetect: (barcode, args) {
                    if (barcode.rawValue != null) {
                      final scannedCode = barcode.rawValue!;
                      ref.read(scannedTextProvider.notifier).state = scannedCode;

                      // Extract the phone number using regex
                      String phoneNumber = _extractPhoneNumber(scannedCode);

                      // Dial the number with the selected provider's dialing code
                      if (selectedProvider != null && phoneNumber.isNotEmpty) {
                        String dialingCode = selectedProvider.dialingCode.replaceAll('<scanned_number>', phoneNumber);
                        _dialNumber(dialingCode);
                      }
                    } else {
                      print('Failed to scan QR code');
                    }
                  },
                  allowDuplicates: false, // Ensure QR code is only processed once
                   // Adjust camera facing if necessary
                ),
              ),
            ),
          ),

          // Display Scanned Text under the Camera View
          Positioned(
            bottom: 150, // Position the text above the bottom
            left: 0,
            right: 0,
            child: Center(
              child: scannedText == null || scannedText.isEmpty
                  ? Text(
                'Scan a QR code to see the result',
                style: TextStyle(color: Colors.black, fontSize: 16, fontStyle: FontStyle.italic),
              )
                  : Text(
                'Scanned Text: $scannedText',
                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Service provider selection widget
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  _showServiceProviderModal(context, ref, serviceProviders);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blueAccent, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  elevation: 5, // Shadow for modern look
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.network_cell, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      selectedProvider != null
                          ? 'Selected: ${selectedProvider.name}' // Display the selected provider
                          : 'Select Service Provider',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Extract phone number from QR code string using regex
  String _extractPhoneNumber(String qrCode) {
    final regex = RegExp(r'(\d{10,15})'); // Regex to capture a 10 to 15 digit number
    final match = regex.firstMatch(qrCode);
    if (match != null) {
      return match.group(0) ?? '';
    }
    return '';
  }

  // Method to dial the number using the selected service provider's dialing code
  void _dialNumber(String dialingCode) async {
    final url = Uri.parse('tel:$dialingCode');
    if (await canLaunchUrl(url.toString() as Uri)) {
      await launchUrl(url.toString() as Uri);
    } else {
      throw 'Could not dial the number';
    }
  }

  // Method to show the service provider selection modal
  void _showServiceProviderModal(
      BuildContext context, WidgetRef ref, List<ServiceProvider> serviceProviders) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 250, // Modal height
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Select Service Provider',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: serviceProviders.length,
                    itemBuilder: (context, index) {
                      final provider = serviceProviders[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: InkWell(
                          onTap: () {
                            ref.read(selectedServiceProvider.notifier).state = provider;
                            Navigator.pop(context); // Close the modal
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            child: Row(
                              children: [
                                ClipOval(
                                  child: Image.asset(
                                    provider.logoUrl,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    provider.name,
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
