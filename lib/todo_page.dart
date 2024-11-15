import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'movie.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  List<Film> _films = [];
  List<Film> _filteredFilms = [];

  @override
  void initState() {
    super.initState();
    _refreshFilmList();
  }

  void _refreshFilmList() async {
    final data = await _dbHelper.readFilms();
    setState(() {
      _films = data;
      _filteredFilms = data;
    });
  }

  void _searchFilm(String query) {
    final results = _films.where((film) {
      final judulLower = film.judul.toLowerCase();
      final queryLower = query.toLowerCase();
      return judulLower.contains(queryLower);
    }).toList();

    setState(() {
      _filteredFilms = results;
    });
  }

  void _addOrUpdateFilm([Film? film]) {
    if (film != null) {
      _judulController.text = film.judul;
      _deskripsiController.text = film.deskripsi;
    } else {
      _judulController.clear();
      _deskripsiController.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(film == null ? 'Tambah Film' : 'Edit Film'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _judulController,
              decoration: InputDecoration(labelText: 'Judul'),
            ),
            TextField(
              controller: _deskripsiController,
              decoration: InputDecoration(labelText: 'Deskripsi'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final judul = _judulController.text;
              final deskripsi = _deskripsiController.text;

              if (film == null) {
                await _dbHelper.createFilm(Film(judul: judul, deskripsi: deskripsi));
              } else {
                film.judul = judul;
                film.deskripsi = deskripsi;
                await _dbHelper.updateFilm(film);
              }
              Navigator.of(context).pop();
              _refreshFilmList();
            },
            child: Text(film == null ? 'Tambah' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  void _deleteFilm(int id) async {
    await _dbHelper.deleteFilm(id);
    _refreshFilmList();
  }

  void _toggleSelesai(Film film) async {
    film.selesaiDitonton = !film.selesaiDitonton;
    await _dbHelper.updateFilm(film);
    _refreshFilmList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aplikasi List Film'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Film',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _searchFilm,
            ),
            SizedBox(height: 10),
            // List of Films
            Expanded(
              child: ListView.builder(
                itemCount: _filteredFilms.length,
                itemBuilder: (context, index) {
                  final film = _filteredFilms[index];
                  return ListTile(
                    title: Text(film.judul),
                    subtitle: Text(film.deskripsi),
                    leading: Checkbox(
                      value: film.selesaiDitonton,
                      onChanged: (_) => _toggleSelesai(film),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Update Icon
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _addOrUpdateFilm(film),
                        ),
                        // Delete Icon
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteFilm(film.id!),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Delete Completed Button
            ElevatedButton(
              onPressed: () async {
                final completedFilms = _films.where((film) => film.selesaiDitonton).toList();
                for (var film in completedFilms) {
                  await _dbHelper.deleteFilm(film.id!);
                }
                _refreshFilmList();
              },
              child: Text('Hapus yang Selesai'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 189, 234, 250)),
            ),
          ],
        ),
      ),
      // Floating Button to Add New Film
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateFilm(),
        child: Icon(Icons.add),
      ),
    );
  }
}
