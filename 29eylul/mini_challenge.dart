void main() {
  final Set<String> bulutServisKumesi = {
    "auth-api",
    "payment-gateway",
    "reporting-worker",
  };

  final bool isProduction = true;

  final List<String> servisListesi = [
    ...bulutServisKumesi,
    if (isProduction) "vault-secret-manager",
  ];

  print("Servislerin listesi:");
  for (final servis in servisListesi) {
    print("$servis");
  }
}