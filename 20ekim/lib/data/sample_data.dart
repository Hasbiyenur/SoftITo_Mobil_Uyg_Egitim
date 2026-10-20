import 'package:flutter/material.dart';

/// Girişimcilik Rehberi Konu Modeli
class GuideTopic {
  final String id;
  final String title;
  final String shortDescription;
  final String detailedContent;
  final IconData icon;
  final List<String> keyPoints;

  const GuideTopic({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.detailedContent,
    required this.icon,
    required this.keyPoints,
  });
}

/// Demo Mentor Profili Modeli
class MentorProfile {
  final String id;
  final String name;
  final String title;
  final String field;
  final String bio;
  final List<String> experienceHighlights;
  final String advice;
  final Color badgeColor;

  const MentorProfile({
    required this.id,
    required this.name,
    required this.title,
    required this.field,
    required this.bio,
    required this.experienceHighlights,
    required this.advice,
    required this.badgeColor,
  });
}

/// Hukuki Bilgi Konusu Modeli
class LegalTopic {
  final String id;
  final String title;
  final String summary;
  final String details;
  final IconData icon;
  final List<String> warnings;

  const LegalTopic({
    required this.id,
    required this.title,
    required this.summary,
    required this.details,
    required this.icon,
    required this.warnings,
  });
}

/// Demo Avukat Profili Modeli
class LawyerProfile {
  final String id;
  final String name;
  final String field;
  final String description;
  final String demoNote;

  const LawyerProfile({
    required this.id,
    required this.name,
    required this.field,
    required this.description,
    this.demoNote = 'Kurgusal / Demo Danışman Profili (Gerçek kişi değildir)',
  });
}

/// Destek ve Teşvik Kurumu Modeli
class SupportInstitution {
  final String id;
  final String name;
  final String shortName;
  final String description;
  final String targetAudience;
  final String officialWebsite;
  final IconData icon;
  final List<String> samplePrograms;
  final String disclaimer;

  const SupportInstitution({
    required this.id,
    required this.name,
    required this.shortName,
    required this.description,
    required this.targetAudience,
    required this.officialWebsite,
    required this.icon,
    required this.samplePrograms,
    this.disclaimer = 'Güncel başvuru koşulları ve tarihler için resmi web sitesini inceleyiniz.',
  });
}

/// Yatırımcılık Konusu Modeli
class InvestorTopic {
  final String id;
  final String title;
  final String summary;
  final String details;
  final IconData icon;
  final List<String> keyPoints;

  const InvestorTopic({
    required this.id,
    required this.title,
    required this.summary,
    required this.details,
    required this.icon,
    required this.keyPoints,
  });
}

/// Demo Yatırımcı Profili Modeli
class InvestorProfile {
  final String id;
  final String name;
  final String interestField;
  final String investmentStage;
  final String description;
  final String advice;
  final String demoTag;
  final Color badgeColor;

  const InvestorProfile({
    required this.id,
    required this.name,
    required this.interestField,
    required this.investmentStage,
    required this.description,
    required this.advice,
    this.demoTag = 'Demo Yatırımcı Profili (Kurgusal)',
    this.badgeColor = const Color(0xFF0288D1),
  });
}

/// Sabit Örnek Veriler (In-memory Mock Data)
class SampleData {
  // 1. Girişimcilik Rehberi Konuları
  static const List<GuideTopic> guideTopics = [
    GuideTopic(
      id: 'nedir',
      title: 'Girişimcilik Nedir?',
      shortDescription:
          'Mevcut bir problemi tespit edip, değer üreten ve sürdürülebilir bir iş modeline dönüştürme sürecidir.',
      detailedContent:
          'Girişimcilik; sadece şirket kurmak değil, belirsizlikler altında yenilikçi çözümler üreterek risk alabilme ve toplum için katma değer sağlama yetkinliğidir. Başarılı bir girişim, pazarın gerçek bir ihtiyacına hitap eder.',
      icon: Icons.lightbulb_outline,
      keyPoints: [
        'Problem ve pazar uyumu en temel başarı faktörüdür.',
        'Hata yapmaktan korkmadan hızlı deneme ve öğrenme kültürü esastır.',
        'Sermaye kadar takım çalışması ve icraat gücü belirleyicidir.',
      ],
    ),
    GuideTopic(
      id: 'fikir',
      title: 'İş Fikri Oluşturma',
      shortDescription:
          'Günlük hayattaki sancılı noktaları (pain points) gözlemleyerek uygulanabilir çözümler tasarlayın.',
      detailedContent:
          'En iyi iş fikirleri genellikle kurucunun bizzat deneyimlediği veya yakından gözlemlediği sorunlardan doğar. Fikrinizi hayata geçirmeden önce potansiyel müşterilerle konuşup varsayımlarınızı doğrulamalısınız.',
      icon: Icons.psychology_outlined,
      keyPoints: [
        'Müşteri görüşmeleri (müşteri keşfi) yapın.',
        'Rakipleri analiz edin ancak doğrudan kopyalamak yerine ayrışın.',
        'Fikrinizi bir cümleyle açık ve sade şekilde ifade edebilin.',
      ],
    ),
    GuideTopic(
      id: 'is_plani',
      title: 'Basit İş Planı & Kanvas',
      shortDescription:
          'Tek sayfalık Yalın Kanvas (Lean Canvas) ile hipotezlerinizi hızlıca haritalandırın.',
      detailedContent:
          'Geleneksel 50 sayfalık iş planları yerine günümüz girişimcileri Yalın Kanvas tercih etmektedir. Müşteri kesiti, değer teklifi, gelir modelleri ve maliyet kalemleri tek bir sayfada görselleştirilir.',
      icon: Icons.dashboard_customize_outlined,
      keyPoints: [
        'Temel Değer Teklifi: Müşteri neden sizi seçmeli?',
        'Gelir Akışları: Abonelik, tek seferlik satış veya komisyon modelleri.',
        'Kanal Stratejisi: Müşteriye hangi yollarla ulaşacaksınız?',
      ],
    ),
    GuideTopic(
      id: 'sirket_kurma',
      title: 'Şirket Kurmaya Genel Bakış',
      shortDescription:
          'Fikrinizi faturalandırabilir ve yasal bir zemine oturtmanın temel aşamaları.',
      detailedContent:
          'Bir şirketi kurmadan önce MVP (Minimum Uygulanabilir Ürün) aşamasında ilk doğrulamayı yapmak genellikle tavsiye edilir. Şirketleşme kararı alındığında şahıs veya limited gibi uygun tüzel kişilik seçilir.',
      icon: Icons.business_outlined,
      keyPoints: [
        'Erken aşamada mali müşavir desteği kritik önem taşır.',
        'Vergi levhası, oda kaydı ve e-imza gibi bürokratik adımlar tamamlanır.',
        'Ortaklık payları ve vesting kuralları baştan yazılı olmalıdır.',
      ],
    ),
  ];

  // 2. Demo Mentor Profilleri (Tamamen kurgusaldır)
  static const List<MentorProfile> mentors = [
    MentorProfile(
      id: 'mentor_1',
      name: 'Dr. Selin Yılmaz (Demo)',
      title: 'Yazılım & SaaS Stratejisti',
      field: 'Teknoloji ve Ürün Yönetimi',
      bio:
          'B2B yazılım ve yapay zeka ürünlerinde 12 yıllık kurgusal girişimcilik tecrübesi bulunmaktadır. Erken aşama ürün-pazar uyumu konularında rehberlik etmektedir.',
      experienceHighlights: [
        '2 kurgusal B2B SaaS girişiminin kurucu ortaklığı',
        'Yalın ürün geliştirme (Lean Startup) mentörlüğü',
        'Tohum öncesi yatırım hazırlığı',
      ],
      advice:
          'Ürününüzü mükemmelleştirmek için aylarca gizli kalmayın; müşterinin eline en sade sürümü verip geri bildirim toplayın.',
      badgeColor: Color(0xFF1E88E5),
    ),
    MentorProfile(
      id: 'mentor_2',
      name: 'Murat Can Aksoy (Demo)',
      title: 'Büyüme & Pazarlama Danışmanı',
      field: 'Büyüme (Growth) & Pazara Giriş',
      bio:
          'E-ticaret ve mobil uygulama kullanıcı kazanımı stratejileri üzerine kurgulanmış örnek mentordur. Performans pazarlaması ve elde tutma odaklıdır.',
      experienceHighlights: [
        'Düşük bütçeli büyüme korsanlığı (Growth Hacking)',
        'Müşteri yaşam boyu değeri (LTV) optimizasyonu',
        'Topluluk odaklı büyüme taktikleri',
      ],
      advice:
          'Trafik satın almak yerine organik olarak ağızdan ağıza yayılabilecek bir müşteri deneyimi inşa edin.',
      badgeColor: Color(0xFF43A047),
    ),
    MentorProfile(
      id: 'mentor_3',
      name: 'Zeynep Kaya Demir (Demo)',
      title: 'Finansman & Yatırım Rehberi',
      field: 'Girişim Finansmanı',
      bio:
          'Erken aşama melek yatırım ağları ve nakit akışı yönetimi konularında kurgusal örnek uzman profili. Nakit yakma hızını kontrol etme konusunda deneyimlidir.',
      experienceHighlights: [
        'Finansal projeksiyon ve birim ekonomi (Unit Economics)',
        'Pitch Deck (Yatırımcı Sunumu) hazırlığı',
        'Değerleme ve hisse dağıtım kurgusu',
      ],
      advice:
          'Kârlılık veya sürdürülebilir nakit akışı olmayan bir büyüme, ilk krizde girişiminizi riske sokar.',
      badgeColor: Color(0xFFFB8C00),
    ),
    MentorProfile(
      id: 'mentor_4',
      name: 'Emre Öztürk (Demo)',
      title: 'Donanım & Derin Teknoloji Danışmanı',
      field: 'Ar-Ge ve Prototipleme',
      bio:
          'IoT ve akıllı cihaz alanında kurgusal mühendislik mentoru. Prototip üretiminden seri üretime geçişteki adımları aktarır.',
      experienceHighlights: [
        'Hızlı prototipleme ve 3D modelleme',
        'Tedarik zinciri ve komponent seçimi',
        'Patentlenebilirlik araştırması',
      ],
      advice:
          'Fiziksel bir ürün yapıyorsanız tedarik gecikmelerini ve maliyet tamponlarını daima plana ekleyin.',
      badgeColor: Color(0xFF8E24AA),
    ),
  ];

  // 3. Hukuki Destek Konuları ve Demo Avukatlar
  static const List<LegalTopic> legalTopics = [
    LegalTopic(
      id: 'sirket_turleri',
      title: 'Şirket Türleri Karşılaştırması',
      summary:
          'Şahıs Şirketi, Limited Şirket (Ltd. Şti.) ve Anonim Şirket (A.Ş.) arasındaki temel farklar.',
      details:
          'Şahıs şirketi düşük maliyetle birkaç saatte kurulabilir ancak kurucu tüm mal varlığıyla sorumludur. Limited şirket 1 veya daha çok ortakla kurulabilir, prestijlidir. Anonim şirket ise hisse devrinde vergi avantajları ve yatırım alma kolaylığı ile büyüme hedefleyen teknoloji girişimlerinin ilk tercihidir.',
      icon: Icons.account_balance_outlined,
      warnings: [
        'Buradaki bilgiler yalnızca genel bilgilendirme amaçlıdır.',
        'Resmi kuruluş işlemlerinde serbest muhasebeci mali müşavire danışınız.',
      ],
    ),
    LegalTopic(
      id: 'sozlesmeler',
      title: 'Temel Girişim Sözleşmeleri',
      summary:
          'Ortaklık Sözleşmesi (Founders Agreement) ve Gizlilik Anlaşması (NDA).',
      details:
          'Girişimlerin en büyük dağılma nedenlerinden biri ortaklar arasındaki belirsizliktir. Ortaklık sözleşmesinde roller, hisse hakediş (vesting) süreleri ve ayrılma senaryoları mutlaka yazılı olmalıdır. Fikri mülkiyetin girişime devri baştan garanti altına alınmalıdır.',
      icon: Icons.description_outlined,
      warnings: [
        'İnternetten indirilen şablonlar her duruma uyum sağlamaz.',
        'Ortaklık haklarını korumak için yazılı ve imzalı belge düzenleyin.',
      ],
    ),
    LegalTopic(
      id: 'marka_tescili',
      title: 'Marka ve Fikri Mülkiyet Tescili',
      summary:
          'TÜRKPATENT nezdinde marka, patent ve faydalı model koruması.',
      details:
          'Uygulamanızın adını, logosunu ve özgün sloganını TÜRKPATENT üzerinde tescil ettirmek, başkalarının aynı isimle pazara girmesini engeller. Alan adı (domain) veya sosyal medya hesabının alınmış olması tek başına yasal marka koruması sağlamaz.',
      icon: Icons.verified_user_outlined,
      warnings: [
        'Tescil süreci itiraz ve bülten yayın aşamalarını içerir.',
        'Benzer isim araştırmasını başvuru yapmadan önce mutlaka gerçekleştirin.',
      ],
    ),
  ];

  static const List<LawyerProfile> lawyers = [
    LawyerProfile(
      id: 'lawyer_1',
      name: 'Av. Burak Demirtaş (Demo)',
      field: 'Bilişim & KVKK Hukuku',
      description:
          'Kullanıcı sözleşmeleri, çerez politikaları, KVKK ve SaaS lisans sözleşmeleri üzerine kurgusal uzman profili.',
    ),
    LawyerProfile(
      id: 'lawyer_2',
      name: 'Av. Hande Arslan (Demo)',
      field: 'Şirketler & Fikri Mülkiyet Hukuku',
      description:
          'Kurucular arası pay sahipliği sözleşmeleri, yatırım turları ve marka tescil süreçlerinde kurgusal danışmanlık örneği.',
    ),
  ];

  // 4. Destek ve Teşvik Kurumları
  static const List<SupportInstitution> supports = [
    SupportInstitution(
      id: 'kosgeb',
      name: 'Küçük ve Orta Ölçekli İşletmeleri Geliştirme İdaresi Başkanlığı',
      shortName: 'KOSGEB',
      description:
          'Girişimcilerin iş kurma ve işletmelerini büyütmelerine yönelik hibe ve geri ödemeli finansman destekleri sunar.',
      targetAudience:
          'Yeni girişimciler, KOBİ\'ler, geleneksel ve ileri girişimciler.',
      officialWebsite: 'www.kosgeb.gov.tr',
      icon: Icons.account_balance,
      samplePrograms: [
        'Girişimci Destek Programı (Kuruluş ve Personel Desteği)',
        'Ar-Ge, Ür-Ge ve İnovasyon Destek Programı',
        'KOBİ Gelişim Destek Programı (KOBİGEL)',
      ],
    ),
    SupportInstitution(
      id: 'tubitak',
      name: 'Türkiye Bilimsel ve Teknolojik Araştırma Kurumu',
      shortName: 'TÜBİTAK',
      description:
          'Teknoloji ve yenilik odaklı iş fikirlerinin ticari ürüne dönüşmesini sağlayan ön kuluçka ve hibe destekleri sağlar.',
      targetAudience:
          'Üniversite öğrencileri, akademisyenler, teknoloji tabanlı girişimler.',
      officialWebsite: 'www.tubitak.gov.tr',
      icon: Icons.biotech,
      samplePrograms: [
        'TÜBİTAK 1512 BİGG (Bireysel Genç Girişim) Çekirdek Sermaye Desteği',
        'TÜBİTAK 1507 KOBİ Ar-Ge Başlangıç Destek Programı',
        'TÜBİTAK 1501 Sanayi Ar-Ge Projeleri Destekleme Programı',
      ],
    ),
    SupportInstitution(
      id: 'kalkinma',
      name: 'Kalkınma Ajansları & Teknoparklar',
      shortName: 'Bölgesel Ajanslar & TGB',
      description:
          'Bölgesel kalkınma destekleri, kuluçka merkezleri ve teknoloji geliştirme bölgelerinde vergi/SGK muafiyetleri sunar.',
      targetAudience:
          'Yazılım, donanım ve yüksek teknoloji üreten şirketler.',
      officialWebsite: 'www.sanayi.gov.tr',
      icon: Icons.domain,
      samplePrograms: [
        'Teknokent Vergi ve SGK İstisnaları',
        'Bölgesel Girişim Hızlandırma Programları',
        'Ücretsiz Kuluçka Ofis ve Altyapı Desteği',
      ],
    ),
  ];

  // 5. Temel Yatırımcılık Konuları
  static const List<InvestorTopic> investorTopics = [
    InvestorTopic(
      id: 'melek_yatirimci',
      title: 'Melek Yatırımcı (Angel Investor)',
      summary:
          'Kendi kişisel birikimleriyle erken aşama (tohum/tohum öncesi) girişimlere sermaye ve mentorluk sağlayan bireysel yatırımcılardır.',
      details:
          'Melek yatırımcılar genellikle daha önce girişim kurup satmış veya kurumsal hayatın üst kademelerinde yer almış deneyimli profesyonellerdir. Yalnızca para değil; sektör bağlantıları, müşteri ağı (smart money) ve stratejik rehberlik de sunarlar.',
      icon: Icons.person_pin_circle_outlined,
      keyPoints: [
        'Genellikle ilk prototip / MVP aşamasında devreye girerler.',
        'Karar alma süreçleri kurumsal fonlara göre çok daha hızlıdır.',
        'Yatırım karşılığında şirketten belirli bir oranda azınlık hissesi alırlar.',
      ],
    ),
    InvestorTopic(
      id: 'girisim_sermayesi',
      title: 'Girişim Sermayesi (Venture Capital - VC)',
      summary:
          'Kurumsal ve bireysel yatırımcılardan topladıkları fonları yüksek büyüme potansiyeli taşıyan teknoloji şirketlerine yatıran profesyonel fonlardır.',
      details:
          'VC fonları genellikle kanıtlanmış bir ürün-pazar uyumu ve düzenli gelir akışı yakalamış girişimlere ölçeklenme (Scale-up) aşamasında yatırım yaparlar. 10x-100x getiri potansiyeli ararlar ve yönetim kurulunda söz hakkı talep ederler.',
      icon: Icons.pie_chart_outline,
      keyPoints: [
        'Tohum sonrası (Seed), Seri A, Seri B gibi ileri turlara liderlik ederler.',
        'Kapsamlı hukuki ve finansal inceleme (Due Diligence) yaparlar.',
        'Hedefleri belirli bir süre sonra halka arz (IPO) veya satın alma (Exit) ile çıkış yapmaktır.',
      ],
    ),
    InvestorTopic(
      id: 'pitch_deck',
      title: 'Yatırımcı Sunumu (Pitch Deck)',
      summary:
          'Girişimin problemini, çözümünü, pazar büyüklüğünü ve finansal hedeflerini 10-15 slaytta özetleyen görsel sunumdur.',
      details:
          'Yatırımcılar yüzlerce başvuru aldıkları için sunumun ilk 2 dakikada dikkat çekmesi gerekir. Karmaşık teknik detaylar yerine net problem, farklılaşan değer önerisi, ekip gücü ve büyüme çekişi (traction) öne çıkarılmalıdır.',
      icon: Icons.slideshow_outlined,
      keyPoints: [
        '10/20/30 kuralı: 10 slayt, 20 dakika süre, en az 30 punto yazı boyutu.',
        'Problem, Çözüm, Pazar Büyüklüğü, İş Modeli ve Ekip vazgeçilmez slaytlardır.',
        'Yatırım miktarı ve bu kaynağın nasıl kullanılacağı (Use of Funds) açıkça belirtilmelidir.',
      ],
    ),
    InvestorTopic(
      id: 'hibe_vs_yatirim',
      title: 'Devlet Desteği (Hibe) vs. Öz Sermaye Yatırımı',
      summary:
          'Hibe kaynaklarında hisse verilmez ve geri ödeme istenmez; özel yatırımcılarda ise sermaye karşılığı ortaklık payı (hisse) devredilir.',
      details:
          'KOSGEB ve TÜBİTAK gibi devlet destekleri sermayesiz girişimciler için hisse sulanması (dilution) olmadan Ar-Ge yapma imkanı verir. Özel melek ve VC yatırımları ise daha hızlı sermaye, küresel açılma ve stratejik ortaklık ağı getirir ancak kurucunun şirketteki hisse payı azalır.',
      icon: Icons.compare_arrows_outlined,
      keyPoints: [
        'Devlet Hibesi: Hisse kaybı yok, bürokratik raporlama ve fatura şartı var.',
        'Yatırımcı Sermayesi: Şirket hissesi devredilir, hızlı büyüme ve mentörlük desteği sağlanır.',
        'En ideal senaryo: Erken aşamada hibe ile prototip üretip, büyüme aşamasında VC yatırımı almaktır.',
      ],
    ),
  ];

  // 6. Kurgusal Demo Yatırımcı Profilleri
  static const List<InvestorProfile> investors = [
    InvestorProfile(
      id: 'inv_1',
      name: 'Kerem Aras (Demo Melek Yatırımcı)',
      interestField: 'B2B SaaS, Üretken Yapay Zeka & Bulut Teknolojileri',
      investmentStage: 'Tohum Öncesi (Pre-seed) ve Erken Aşama',
      description:
          'Eski yazılım kurucusu, 8 yıllık kurgusal melek yatırımcılık tecrübesi. B2B yazılım ve otomasyon alanında ölçeklenebilir fikirler geliştiren teknik kurucu ekipleri destekler.',
      advice:
          'Erken aşamada yatırımcıya sunum yaparken en değerli varlığınız fikriniz değil, ekibinizin hızlı öğrenme ve icraat kabiliyetidir.',
      badgeColor: Color(0xFF1E88E5),
    ),
    InvestorProfile(
      id: 'inv_2',
      name: 'Aylin Çetin (Demo VC Fon Yöneticisi)',
      interestField: 'Fintek, Gömülü Finans ve Dijital Pazar Yerleri',
      investmentStage: 'Tohum (Seed) ve Seri A',
      description:
          'Kurgusal Girişim Sermayesi (VC) yatırım komitesi üyesi. Kanıtlanmış kullanıcı ilgisi (traction), net müşteri kazanım maliyeti (CAC) ve sürdürülebilir birim ekonomiye sahip girişimlere odaklanır.',
      advice:
          'Bize gelirken yalnızca pazarın büyüklüğünü değil, o pazardan müşteriyi hangi maliyetle ve nasıl ikna edeceğinizi net rakamlarla gösterin.',
      badgeColor: Color(0xFF2E7D32),
    ),
    InvestorProfile(
      id: 'inv_3',
      name: 'Bora Tan (Demo Erken Aşama Yatırımcısı)',
      interestField: 'Yeşil Dönüşüm, İklim Teknolojileri & Akıllı Tarım',
      investmentStage: 'Kuluçka ve Tohum Aşaması (Seed Stage)',
      description:
          'Sürdürülebilirlik ve etki yatırımı (impact investing) odaklı kurgusal bireysel yatırımcı. Çevresel katma değer üreten ve regülasyon uyumu yüksek projelere ilgi duyar.',
      advice:
          'Hem karlı bir iş modeli hem de dünyayı daha iyi bir yer yapacak ölçülebilir bir etki yaratabileceğinizi kanıtlayın.',
      badgeColor: Color(0xFFF57C00),
    ),
  ];
}
