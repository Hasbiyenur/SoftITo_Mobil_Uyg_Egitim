/*
Future<void> fetchDashboardData() async{
  try{
    final result= await Future.wait([
      fetchUserProfile(),
      fetchAccountBalance(),
      fetchNotification(),
    ], eagerError: true);

    print("Tüm veriler geldi $result");
  } catch (e){
    print("İsteklerden biri başarısız oldu $e");
  }
}

*/

//Future: Tek bir kere veri çekileceği zaman kullanılır
//Stream: Bir boru hattı şeklinde çalışır (pipe), Zaman içinde 1 10 100 ya da sonsuz sayıda veri akışı sağlanılabilir
//örn: (Borsa fiyatı, GPS konum güncelleme, Firebase canlı dinleme) 

/*
import 'dart:async';  //devamlı akış sağlama

void main (){
  //controller oluşturma
  final controller=StreamController<int>();
  //dinleyici(listener) bağlama
  final subscription=controller.stream.listen(
    (data)=>print("yeni veri: $data"),
    onError: (err)=>print("Hata Oluştu: $err"),
    onDone: () => print("Yayın Tamamlandı"),
  );

controller.sink.add(10);
controller.sink.add(20);
controller.sink.add(30);


final boardcastStream=controller.stream.asBroadcastStream();    //aynı dinleme birden fazla yapılamadığı için hata verir
boardcastStream.listen((d) => print("UI Ekranı: $d"));
boardcastStream.listen((d) => print("Analitik ServisiEkranı: $d"));

controller.close();
}
*/