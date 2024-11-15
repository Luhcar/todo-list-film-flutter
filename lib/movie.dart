class Film {
  int? id;
  String judul;
  String deskripsi;
  bool selesaiDitonton;

  Film({this.id, required this.judul, required this.deskripsi, this.selesaiDitonton = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'selesaiDitonton': selesaiDitonton ? 1 : 0,
    };
  }

  factory Film.fromMap(Map<String, dynamic> map) {
    return Film(
      id: map['id'],
      judul: map['judul'],
      deskripsi: map['deskripsi'],
      selesaiDitonton: map['selesaiDitonton'] == 1,
    );
  }
}
