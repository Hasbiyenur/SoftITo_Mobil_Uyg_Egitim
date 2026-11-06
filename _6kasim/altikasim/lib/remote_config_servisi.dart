import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigServisi {
  //uzaktan uygulamaya sürüm, etkinlik gibi güncelleme geldiğinde çalışması için.
  final FirebaseRemoteConfig _rc = FirebaseRemoteConfig.instance;

  Future<void> baslat() async {
    await _rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval:
            Duration.zero, //cache önbelleği 0 olarak oluşturduk
      ),
    );
    await _rc.setDefaults(const {
      'kampanya_aktif': false,
      'kampanya_menti': 'Bugün beratta kampanya var 3 kere ders anlatacka',
      'zorunlu_surum': '1.0.1',
    }); // internet olmadığında

    await _rc.fetchAndActivate();
  }

  bool get kampanyaAktifMi => _rc.getBool('kampanya_aktif');
  String get kampanyaMetni => _rc.getString('kampanya_metni');
  String get zorunluSurum => _rc.getString('zorunlu_surum');
}
