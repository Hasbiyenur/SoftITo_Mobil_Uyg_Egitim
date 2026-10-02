//mini challenge

mixin YuzmeYetisi {
  void dalis() {
    print("Su altına daldı.");
  }
}

class Denizci with YuzmeYetisi {
  final String ad;

  Denizci({required this.ad});
}

void main() {
  final denizci = Denizci(ad: "Denizci");
  denizci.dalis();
}