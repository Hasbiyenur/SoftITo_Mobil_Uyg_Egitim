enum Kategori {
  hepsi('Tümü', 'H'),
  elektronik('Elektronik', 'E'),
  giyim('Giyim', 'G'),
  ayakkabi('Ayakkabı', 'A'),
  aksesuar('Aksesuar', 'Ak');

  final String baslik;
  final String ikon;

  const Kategori(this.baslik, this.ikon);
}
