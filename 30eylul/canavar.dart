abstract class Canavar {
  final String canavar;

  Canavar({required this.canavar});

  void kukre();
}

class Kurt extends Canavar {
  Kurt({required super.canavar});

  @override
  void kukre() {
    print("$canavar uluyor: Auuuu");
  }
}

class Ejderha extends Canavar {
  Ejderha({required super.canavar});

  @override
  void kukre() {
    print("$canavar kükürüyor: Roarrr");
  }
}

void canavarKukremeleri(List<Canavar> canavarlar) {
  for (var t in canavarlar) {
    t.kukre();
  }
}
void main() {
  final List<Canavar> canavarlar = [
    Kurt(canavar: "Gölge Kurt"),
    Ejderha(canavar: "Ateş Ejderhası"),
  ];

  canavarKukremeleri(canavarlar);
}