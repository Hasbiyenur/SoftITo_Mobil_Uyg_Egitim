//Spread ... ...? ve collection for kullanımı

void main(){
  print("Pipeline Kongfigürasyonu");

  final bool productionMu = true;
  final bool debugLoggingAktif = false;
  final List<String>? cloudWatchEklentileri=["datadog-agent:v7","prometheus-exporter"];
  final List<String>? geciciTestYamalari=null;
  
  final List<String> aktifPipelineAdimlari=[
    "git-chechout",
    "security-sast-scan",

    if(productionMu) "production-kms-check",
    if(debugLoggingAktif) "verbase-debug-logger" else "minified-json-logger",
    ...["docker-build","helm-chart-package"],
    ...?cloudWatchEklentileri,
    ...?geciciTestYamalari, //null olduğu için hiçbir işlem yapmaz/ çökmez de
  
  ];
  for(int i=0; i<aktifPipelineAdimlari.length; i++){
    print("Adım ${i + 1}: ${aktifPipelineAdimlari[i]}");
  }

  final List<int> izinliPortlar = [8080,8443,9090];
  final List<String> firewallGuvenlikKurallari=[
    "INGRESS-DEFAULT-DROP",
    for (var port in izinliPortlar) "ALLOW-TCP-PORT-Sport (VPC_INTERNAL)",
    "EGRESS_ALL_ALLOW",    //Sport değil $port yaz
  ];
  print("Dinamik GÜvenlik Kuralları (collection for):---");
  firewallGuvenlikKurallari.forEach((kural)=> print(" * $kural"));
}