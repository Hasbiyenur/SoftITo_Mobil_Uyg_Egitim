// setState() bulunduğu State nesnesinin build() metotunu baştan aşağı tekrsar tetikler.
// Scaffold appbar tabbar ve eğer varsa 20 tane container baştan hesaplanır

import 'package:flutter/material.dart'; //dosyadaki özellikler bu dosyada da kullanılmasını sağlar içine aktarılır
import 'package:go_router/go_router.dart'; //go_rotuer işlemleri yapılması için çağrılır

class SepetKontrolu {
  static final SepetKontrolu ornek = SepetKontrolu._dahili(); // ornek değişkeni sınıfa ait olup nesneye ait olmamasını sağlar. final ile bir kez oluşturulur bir daha oluşturulmaz.
  SepetKontrolu._dahili(); //Sınıfın kendi içinden çağrılan özel (private) bir yapıcı metodudur (Constructor)

  final ValueNotifier<int> urunSayisi = ValueNotifier<int>(
    0,
  ); //urunsayısının kolayca güncellenmesini sağlar tüm fonksiyonu değil.

  void sepeteEkle() {
    urunSayisi.value++; //çalıştırıldığında değer 1 artacal
  }

  void sepetSifirla() {
    urunSayisi.value = 0; //çalıştırıldığında değer sıfırlanacak
  }
}

final GoRouter uygulamaRotalari = GoRouter(
  //sayfalar arası geçişi sağlayan pakettir
  initialLocation:
      '/anasayfa', //başlangıçta açılan veya gösterilen ilk sayfayı belirler
  routes: [
    ShellRoute(
      // ekranın değişip navbar gibi sabit kalan bölümlerin sabit kalmasını sağlayan yapıdır
      builder: (BuildContext context, GoRouterState state, Widget child) {
        //shellroutela beraber gelip sayfa oluşturma fonksiyonudur.
        return AnaKasaEkrani(ekranGovdesi: child);
      },
      routes: [
        //sayfaların adres tanımlamalarını sağlayan parametredir
        GoRoute(
          path: '/anasayfa',
          builder: (context, state) => AnaSayfaEkrani(),
        ),
        GoRoute(path: '/vitrin', builder: (context, state) => VitrinEkrani()),
        GoRoute(path: '/profil', builder: (context, state) => ProfilEkrani()),
      ],
    ),
  ],
);

class AnaKasaEkrani extends StatelessWidget {
  // anakasaekranı classı stateless widget sayesinde içindeki veriler fonksiyonlar sabit kalır değiştirilemez.
  final Widget ekranGovdesi;
  const AnaKasaEkrani({super.key, required this.ekranGovdesi});

  @override
  Widget build(BuildContext context) {
    // uygulamanın temel yapısı kurulur. Widgetların ekranda nasıl nerede duracağını takip eder.
    return Scaffold(
      body: ekranGovdesi,
      bottomNavigationBar: NavigationBar(
        //alttaki sabit barı oluşturur
        selectedIndex: _aktifIndexiBul(
          context,
        ), //seçilen butonun seçildiğini gösterir
        onDestinationSelected: (yeniIndeks) {
          //butona basıldığında çalıştırır
          if (yeniIndeks == 1)
            context.go(
              '/vitrin',
            ); //seçilen indeksin hangi sayfaya yönlendireceğini belirler
          if (yeniIndeks == 2) context.go('/profil');
        },
        destinations: [
          //menü barlarını oluştururken liste halinde tutulmasını sağlar
          const NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Anasayfa',
          ), // kullanıcının basacağı butonu tanımlar
          const NavigationDestination(icon: Icon(Icons.store), label: 'Vitrin'),
          NavigationDestination(
            icon: ValueListenableBuilder<int>(
              valueListenable: SepetKontrolu.ornek.urunSayisi,
              builder: (context, sayi, child) {
                return Badge(
                  //bildiri güncelleme gibi görünen küçük belirteçtir
                  label: Text('$sayi'),
                  isLabelVisible: sayi > 0,
                  child: Icon(Icons.person),
                );
              },
            ),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  int _aktifIndexiBul(BuildContext context) {
    //seçili olan butonu hesaplar
    final String konum = GoRouterState.of(context).uri.toString(); //basılan butonun adresine bakıp uri çalıştırıp ona göre seçilen adresteki sayfaya yönlendirme yapar
    if (konum.startsWith('/profil')) return 1; //eğer profil sayfasında başlarsa index 1e yönlendirir, değilse ilk indekse 0a yönlendirir
    return 0;
  }
}

class AnaSayfaEkrani extends StatelessWidget {
  //ekran sınıfları oluşturulur. uygulamada sayfa olarak kullanılıyor.
  const AnaSayfaEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anasayfa')),
      body: Center(child: const Text('Bir şeyler..')), //ekrana yazı yazdırılır
    );
  }
}

class VitrinEkrani extends StatelessWidget {
  //üstteki ile aynı, sayfa oluşturur
  const VitrinEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Canlı Vitrin (ValueNotifier)')),
      body: Center(
        child: ElevatedButton.icon(
          // hafif 3 boyutlu bir buton oluşturur
          onPressed: () {
            SepetKontrolu.ornek
                .sepeteEkle(); //butona basıldığında sepeteekle işlemi yapılır
          },
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Sepete Ürün Ekle (+1)'), //icon ve yazı eklenir
        ),
      ),
    );
  }
}

class ProfilEkrani extends StatelessWidget {
  //üstteki ile aynı, sayfa oluşturur
  const ProfilEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kullanıcı Profili')),
      body: Center(
        child: TextButton(
          onPressed: () => SepetKontrolu.ornek.sepetSifirla(),
          child: const Text('Sepeti Temizle (0 Yap)'),
        ),
      ),
    );
  }
}
