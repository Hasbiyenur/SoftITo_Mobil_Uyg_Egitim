import '../models/motivation_message.dart';

/// İnternet bağlantısı olmaksızın çalışan yerel Türkçe motivasyon cümleleri havuzu.
/// Cümleler suçlayıcı veya baskı oluşturucu değil; destekleyici, nazik ve cesaretlendiricidir.
class LocalMotivationMessages {
  LocalMotivationMessages._();

  /// Maskotun periyodik veya dokunulduğunda gösterdiği genel motivasyon cümleleri
  static const List<MotivationMessage> generalMessages = [
    MotivationMessage(
      id: 'local_gen_01',
      text: 'Küçük bir adım da ilerlemedir.',
      category: 'general',
    ),
    MotivationMessage(
      id: 'local_gen_02',
      text: 'Kendi hızında devam et, her çaba kıymetlidir.',
      category: 'general',
    ),
    MotivationMessage(
      id: 'local_gen_03',
      text: 'Bugün kendin için güzel bir şey yapabilirsin.',
      category: 'general',
    ),
    MotivationMessage(
      id: 'local_gen_04',
      text: 'Her gün yeni bir başlangıç fırsatıdır.',
      category: 'general',
    ),
    MotivationMessage(
      id: 'local_gen_05',
      text: 'İstikrar, büyük değişimlerin anahtarıdır.',
      category: 'general',
    ),
    MotivationMessage(
      id: 'local_gen_06',
      text: 'Zorlandığında derin bir nefes al ve devam et.',
      category: 'general',
    ),
    MotivationMessage(
      id: 'local_gen_07',
      text: 'Bugünkü gayretin yarınki huzurundur.',
      category: 'general',
    ),
    MotivationMessage(
      id: 'local_gen_08',
      text: 'Harika gidiyorsun, kendine haksızlık etme.',
      category: 'general',
    ),
    MotivationMessage(
      id: 'local_gen_09',
      text: 'Büyük dağlar küçük adımlarla aşılır.',
      category: 'general',
    ),
    MotivationMessage(
      id: 'local_gen_10',
      text: 'Alışkanlıkların geleceğini şekillendiriyor.',
      category: 'general',
    ),
    MotivationMessage(
      id: 'local_gen_11',
      text: 'Bugün sadece bugünün görevine odaklan.',
      category: 'general',
    ),
    MotivationMessage(
      id: 'local_gen_12',
      text: 'Gelişim zaman alır, acele etme ve tadını çıkar.',
      category: 'general',
    ),
    MotivationMessage(
      id: 'local_gen_13',
      text: 'Kendine verdiğin sözü tutmak en güzel ödül.',
      category: 'general',
    ),
    MotivationMessage(
      id: 'local_gen_14',
      text: 'Bir görevi bitirmek tüm günün enerjisini değiştirir.',
      category: 'general',
    ),
    MotivationMessage(
      id: 'local_gen_15',
      text: 'Senin için en doğru zaman tam şu an.',
      category: 'general',
    ),
    MotivationMessage(
      id: 'local_gen_16',
      text: 'Süreklilik yetenekten daha güçlüdür.',
      category: 'general',
    ),
    MotivationMessage(
      id: 'local_gen_17',
      text: 'Damlaya damlaya göl olur; her adım değerlidir.',
      category: 'general',
    ),
    MotivationMessage(
      id: 'local_gen_18',
      text: 'Bugün kendine bir iyilik yap ve hedefini hatırla.',
      category: 'general',
    ),
    MotivationMessage(
      id: 'local_gen_19',
      text: 'Sabır ve şefkatle yoluna devam et.',
      category: 'general',
    ),
    MotivationMessage(
      id: 'local_gen_20',
      text: 'Gözünde büyütme, sadece başla gerisi gelir.',
      category: 'general',
    ),
    MotivationMessage(
      id: 'local_gen_21',
      text: 'Düzenli adımlar her zaman hedefe ulaştırır.',
      category: 'general',
    ),
    MotivationMessage(
      id: 'local_gen_22',
      text: 'Kendinle yarış, dününden bir adım önde olman yeterli.',
      category: 'general',
    ),
    MotivationMessage(
      id: 'local_gen_23',
      text: 'Hedefine sadık kal, filizler zamanla büyür.',
      category: 'general',
    ),
  ];

  /// Görev başarıyla tamamlandığında üstten kayan kutlama cümleleri
  static const List<MotivationMessage> completionMessages = [
    MotivationMessage(
      id: 'local_comp_01',
      text: 'Bir adım daha attın, harika!',
      category: 'completion',
    ),
    MotivationMessage(
      id: 'local_comp_02',
      text: 'Tebrikler! Bir görevi daha başarıyla tamamladın.',
      category: 'completion',
    ),
    MotivationMessage(
      id: 'local_comp_03',
      text: 'İstikrarın meyvesini veriyor, aynen böyle devam!',
      category: 'completion',
    ),
    MotivationMessage(
      id: 'local_comp_04',
      text: 'Kendine verdiğin sözü tuttun. Bravo!',
      category: 'completion',
    ),
    MotivationMessage(
      id: 'local_comp_05',
      text: 'Hedefine bir adım daha yaklaştın, harikasın!',
      category: 'completion',
    ),
    MotivationMessage(
      id: 'local_comp_06',
      text: 'Harika bir tamamlama! Gurur duyabilirsin.',
      category: 'completion',
    ),
  ];
}
