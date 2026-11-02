Const
1) Ne işe yarar: İçine girilen değerleri derleme zamınında tek bir kere yazılarak değişmez olarak üretir.
2) Neden kullanılır: Bir widget const olarak tanımlanırsa setState olduğunda flutter bu widget'ı yeniden üretmez CPU ve pil tasarrufu sağlar.

final
1) Ne işe yarar: Çalışma zamanında değeri bir kez atanan ve sonrasında referansı asla değiştirilmeyen değişkenler
const ve final farkı: const derlenirken bilinmek zorunda (const pi=3.14) final ise çalışma zamanında belirlenebilri ( final saat = DateTime.now()) ---Model sınıflarında alanlar her zaman final olmalıdır.

late
1) Ne işe yarar: değişen tanımlandığı anda değil, ilk kullanıldığında veya initState anında başlatılacağı zaman kullanılır.

required
1) Ne işe yarar: İsimlendirilmiş parametrelerde o parametrenin(değişken)girilmesi zorunlu tutulur. Yoksa hata verir.

@override
1) Ne işe yarar: Alt sınıfın üst sınıftan devraldığı metodu ezdiğini belirtir.
2) Faydası: Eğer üst metod adını yanlış yazarsanız (örnek builds yazarsanız) derleyici @override sayesinde bunu anında hata olarak yakalar.


Null-aware operatörleri (? ?? !)
?. - place?.title -> eğer null hata vermez  direkt null olarak döner
?? - if null: final id = state.ıserId ?? 10; -> Sol taraf null ise sağdaki (hardcore olan değer) otomatik olarak atanır.
! (null/force): final id = state.userId ! -> Bu kod derleyiciye "Bana guven bu o anda kesinlikle null değil" der. Eğer null gelirse uygulama anında çöker. (ÇOK DİKKATLİ KULLANILMALI)

Spread operatörü(...)
1) Ne işe yarar: bir listenin elemanlarının tek tek çıkartıp bulunduğu üst listenin içine ekler. Column ve viewList içinde dinamik kart dizinin kullanmak için en temiz yöntemdir.
...listeAdi.map((p)=>_buildCard(p))


initState()
1) Ne zaman çalışır: Widget ağaca fiziksel olarak ilk başladığında yalnızca 1 kere çalışır.
2) Ne yapar: ScfrollController başlatmaları ve ilk api istekleri burada kurulur.
3) Kural: İçind doğrudan BuildContext ile Navigator çağrılmaz çünkü widget ağaca tam oturmamıştır.

didChangeDependencies()
1) Ne işe yarar: initState()'ten hemen sonra ve widget dinlendiği bir (örnek: Theme.of (context)) değiştiğinde otomatik tektikler.
2) Ne yapar: BuildContext güvenli bir şekilde erişerek tema veya ekran boyutu bağımlılıkları ile ilgili ilk yüklemeler burada yapılır.

build(BuildContext)
1) Ne zaman çalışır: Sayfa ilk açıldığında, setState() çağrıldığında veya üst widget yeni bir inşa ağaç boyama geldiğinde sayesinde defalarca çalışır.
2) Kural: build() metodu tamamen saf olmalıdır. Asla içinde setState() api isteği ya da controller başlatma yapılmamalıdır. Sadece UI döndürür.

dispose()
1) Ne zaman çalışır: Widget hafızadan atılmadan hemen önce son bir kez çalışır.
2) Ne yapar: _controller.dispose() stream dinleyicilerin iptalleri burada yapılır. super.dispose()un mutlaka son satırda çalıştırılması gerekir.

setState()
1) Arka planda ne yapar: State'in bağlı olduğu StatefulElement nesnesine "Ben değiştim, build et" sinyali yollar.
2) Nerede kullanılır: Sayfa genelini çizdirmez. Sadece onu dinleyen küçük ValueListenableBuilder'a sinyal gönderilir.

ValueNotifier<T>
1) Arka planda ne iş yapar. ChangeNotifier sınıfında türer. Belleğinde tek bir nesne referansı tutar(T _value)
2) Tetikleme Değer atandığında (set value(T value)), eğer yeni değer eski değere eşit değilse (value!=newValue), kayıtlı olan fonksiyonu çağrılır. (addListener(() {}))

InheritedWidget
1) Ne yapar: Widget ağacında alttaki childların, aradaki onlarca widgeti baypas ederek, üst widgetin verisine(state'ine) doğrudan erişmesini sağlayan soyur bir widgettir.  

Material 3 Tasarım Dili Renk algoritması ve temalar

primary: Ana marka rengi
onPrimary: Ana rengin üstüne yazılacak yazı rengi ( okunabilirlik açısından)
primaryContainer: Ana rengin yumuşak pastel arkaplan tonu
onPrimaryContainer: Ana rengin yumuşak pastel arkaplan tonunun üstüne yazılacak yazı (okunabilirlik açısından)
surface: Sayfa arka plan tuvali
onSurface: Sayfa üstündeki ana metin rengi
outlineVariant: İnce sınır ve ayrol çizgilerinin rengi

ThemeMode.system
color:Colors.black.withOpacity(186)// kesinlikle 1 ila 255 sayıları arasında tam sayı olarak girilmelidir. **Bu kullanım güncelde istenmiyor**

color:Colors.black.withValues(alpha: 186/255)// double sayı olarak girilmelidir **Güncel ve doğru yöntemdir**

Arayüz Düzen ve Liste Bileşenleri

Expanded ve Flexible
Expanded: Kalan bol alanın TAMAMINI kaplamaya zorlar.
Flexible: Kalan bol alanı paylaştırır. (flex:1, flex:2)
Flex: Yan yana  iki expanded varsa birine flex2, diğerine flex 1 verir. Bu sayede ekran boyutuna göre otomatik olarak ayarlar.

Stack ve Positioned
1) Ne yapar: Widget'ları z ekseninde üst üste bindirir.
Positioned: Yalnızca bir Stack içinde çalışır.
top: 10, right:10 vererek bir resmin sağ üst köşesine bildirim rozeti eklememizi sağlar.

ListView.builder
Klasik ListView(children:[...],) içindeki örnek vermek gerekirse 10.00 elemanın tamamını daha sayfa açılmadan belleğe yükler ve doğal olarak telefon donar.
ListView.builder ise Geri Dönüşümlü Görünüm alanı mantığını kullanarak ekranda sadece o an eğer 5 kart görünecek ise sadece 5 kartı ram belleğe yükler. Kullanıcı aşağıya kaydırdıkça yukarı kalanlar bellekten düşürülüp altta kalanlar bellere taze olarak yeni olarak üretilir.

shrinkWrap: true
Bir ListView başka bir dikey kaydırıcının (singleChildScrollView) içine konulursa Vertical viewport hatası verir
shrinkWrap true verilerek bu çözülebilir ancak: Listview'un sonsuza kayma (sonsuz scroll) özelliği kaybolur.
**Sadece 3 5 elemanınız varsa bunu kullanmalısınız**

Inkwell ve Gesture Detector
GestureDetector: Tıklama çift tıklama sürükleme olaylarını yakalar ama görsel hiçbir tepki VERMEZ.
Inkwell: Tıklandığı an parmağın altından dışa doğru yayılan bir su dalgası efekti verir.

Önemli Kural: Inkwell'in arkasından mutlaka bir material widget olmak zorundadır. Aksi takdirde su dalgası arkadaki tuvali göremediği için hiç bir şekilde görünmez.


Form Mimarisi

GlobalKey<FormState>

Widget içindeki Form düğümüne doğrudan dışardan erişilemiyor. Bu yüzden Widget'in en üstüne koyduğumuz globalKey değişkeni sayesinde formun Validate (geçerli) durumunu ve içindeki değerleri (Değişkenleri) dışarıdan okuyoruz.

_formKey.currentState?.validate() çağrıldığında o formun altındaki tüm TextFromFiled validator bloklarını sırayla çalıştırır.


validator: (String ? value)

Fonksiyonda bir hata bulursa geriye String olarak hata metni gönderir. Bu metin otomatik olarak kırmızı renkli ve inputun altında belirir. Eğer veri geçerliyse null döner. Flutter için bu alanda hata yok demektir. Null gelmesi.


Animasyon Motoru

AnimatedContainer: Genişlik yükseklik padding margin border renk ve gölge oynatır.
AnimatedOpacity: 0.0 ile 1.0 arasında yumuşakça soldurur
AnimatedScale: Widget merkezinden dışarıya doğru büyütüp küçültür
AnimatedAlign: Widget kutunun içinde sağdan sola yukarıdan aşağıya karşı konumunu değiştirir.


Curves
İvmelenme Karakterleri

Curves.linear: Sabit hız (robotik hareketler)
Curves.easeInout: Yavaş Başlar ortada hızlanır yavaşça durur.
Curves.bounceOut: Hedefe çarptığında top gibi 2 3 kez yaylanarak seker.
Curves.elasticOut: Lastik gibi ileri geri titreyerek yerine oturur.

Gorouter

ShellRoute: Alt sayfalara geçiş yapıldığında altta sabit kalan tabbar ve appbar'ı oluşturmak için kullanılır.
gorouter: sayfa geçişlerini yöneten bir navigasyon kütüphanesidir.

context.go('/profile): Route yönlendirmesidir. Rota tablosunda hiyerarşiyi takip eder sayfayı temizleyebilir.

context.push('/profil/5): Stack yönlendirmesidir. Kullanıcı nereden gelirse gelsin mevcut sayfanın tepesine yeni bir katman ekler ve dönüş sayfası için bir geri ok butonu ekler

context.pop() sayfanın en üstteki yığınını kapatır.

state.pathParameters["id"]: Gorouter içinde tanımladığımız /:id yapılarına erişmek için kullanılır

/profil?user=berat
state.uri.queryParameters["user"]: Opsiyonellik filtreleme ya da zamanlarında kullanılır.

Cihaz İçin Yerel Depolama Mimarileri

SharedPreferences: 
Küçük kullanıcı ayarları
Düşük güvenilirlik
Okuma yazma hızları: Okuma hızı orta / yazma hızı yavaş

FlutterSecureStorage: 
Şifre, token vb. saklama
En yüksek güvence
Okuma yazma hızları: Orta


Hive/Isar: 
Yüksek performanslı nesne depolama
Orta (isteğe bağlı şifreleme açılabilir)
Okuma yazma hızları: Aşırı hızlı