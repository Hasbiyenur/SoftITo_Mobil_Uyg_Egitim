void main(){
  //
  final List<String> aktifMikroservisler=[
    "auth-service:v2.1",
    "gateway-services:v1.9",
    "payment-processor:v3.0",
  ];
  aktifMikroservisler.add("telemetry-collector:v1.0");
  print("Aktif servisler: (${aktifMikroservisler.length} adet): $aktifMikroservisler");

  //sabit uzunluktaki liste(fixed-length)
  final List<String> cekirdekYukDengeleyiciler=List.filled(
    4, 
    "Port-kapalı",
    growable: false
  );
  cekirdekYukDengeleyiciler[0]="LB-NODE-01; 192.168.1.10 (Online)";
  cekirdekYukDengeleyiciler[1]="LB-NODE-02; 192.168.1.11 (Online)";
  //cekirdekYukDengeleyiciler.add="LB-NODE-05;"; //HATA: fixed-length listeye eleman eklenemez
  print("Çekirdek Yük Dengeleyicileci Partları: $cekirdekYukDengeleyiciler");

  //Programatik List Üretici
  final List<String> kubernetsPodlari=List.generate(
    13, 
    (index)=>"pod-node-eu-west-${index+1} [Ram:16GB, CPU:4 Cores]",
  );
  print("Oluşturulan K8s Podları: $kubernetsPodlari");

  //Değiştirilemez List
  final List<String> guvenlikDuvariPortlari=List.unmodifiable([
    "22/TCP (SSH)",
    "443/TCP (HTTPS)",
    "6443/TCP (K8s-API)",
  ]);
  //guvenlikDuvariPortlari[0]="80/TCP"; //Hata cannot modify an unmodifieable list
  print("Güvenlik Duvarı Korumalı Portları: $guvenlikDuvariPortlari");
}