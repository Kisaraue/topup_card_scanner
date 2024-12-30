class ServiceProvider {
  final String name;
  final String dialingCode;
  final String logoUrl; // New field for the logo

  ServiceProvider({
    required this.name,
    required this.dialingCode,
    required this.logoUrl, // Include logoUrl in the constructor
  });
}

