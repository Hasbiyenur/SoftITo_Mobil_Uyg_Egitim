1. Widget Tree
    * İskelet
    * İmmutable(değişmez)
    * Çok ucuz (hafif)
    * Saniyede 60-120 kez çöpe atılıp yeniden üretilir (eşit değilse çöpe atıp yeniler, eşit değilse element günceller)
    * Ekranda çizim yapmaz
    * Sadece şablon sunar

2. Element Tree
    * Yöetici & Yaşayan omurga
    * Mutable (durumu ve referanslı hafızada canlı tutar değişir.)
    * Widget ile renderobject arasındaki koordinatördür. (organizasyonu sunar)

//canUpdate

static bool canUpdate(Widget oldWidget, Widget newWidget){
    return oldWidget.runtimeType=newWidget.runtimeType && oldWidget.ket==newWidget.key;
}

